--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   batch.lua
-- @brief  lua_test 批量过滤与执行 (a / 1.x / 1.1.x; kthread + kmcache)
-- @note   约定 **klua-test-design**
-- @history 修改历史
--  \n 2026 创建文件
--]]


local M = {}


function M.is_batch_filter(filter)
	if filter == nil or filter == "" then
		return false
	end

	if filter == "a" or filter == "all" then
		return true
	end

	local n = #filter

	if n >= 2 and filter:sub(n - 1, n) == ".x" then
		return true
	end

	local dot = filter:find(".", 1, true)
	if dot then
		local dot2 = filter:find(".", dot + 1, true)

		if dot2 == nil and dot > 1 and filter:sub(dot + 1) ~= "" then
			return true
		end
	end

	return false
end


function M.doc_id_match_filter(doc_id, filter)
	if filter == nil or filter == "" then
		return true
	end

	if doc_id == nil then
		return false
	end

	if filter == "a" or filter == "all" then
		return true
	end

	local n = #filter

	if n >= 2 and filter:sub(n - 1, n) == ".x" then
		if n == 3 and filter:sub(2, 2) == "." then
			return doc_id:sub(1, 2) == filter:sub(1, 2)
		end

		local prefix = filter:sub(1, n - 1)

		if #doc_id >= #prefix and doc_id:sub(1, #prefix) == prefix then
			return true
		end

		return false
	end

	local dot = filter:find(".", 1, true)

	if dot then
		local dot2 = filter:find(".", dot + 1, true)

		if dot2 == nil and dot > 1 and filter:sub(dot + 1) ~= "" then
			if doc_id == filter then
				return true
			end

			if #doc_id > n and doc_id:sub(n + 1, n + 1) == "." and doc_id:sub(1, n) == filter then
				return true
			end

			return false
		end
	end

	return doc_id == filter
end


function M.omit_case(item, filter)
	if filter == "a" or filter == "all" then
		return false
	end

	if not M.doc_id_match_filter(item.doc_id, filter) then
		return true, "NO_MATCH"
	end

	return false
end


local function _report_skipped(skipped)
	local out = {}

	for _, row in ipairs(skipped) do
		if row.reason ~= "NO_MATCH" then
			out[#out + 1] = row
		end
	end

	return out
end


function M.select_cases(case_list, filter)
	local selected = {}
	local skipped = {}

	for _, item in ipairs(case_list) do
		local omit, reason = M.omit_case(item, filter)

		if omit then
			skipped[#skipped + 1] = { item = item, reason = reason }
		else
			selected[#selected + 1] = item
		end
	end

	return selected, skipped
end


local function _result_key(doc_id)
	return "lua_test.batch." .. doc_id
end


local function _case_line(label, name)
	if name ~= nil and name ~= "" then
		return string.format("  %s  %s", label, name)
	end

	return string.format("  %s", label)
end


function M.print_summary(pass_list, fail_list, skipped)
	pass_list = pass_list or {}
	fail_list = fail_list or {}
	skipped = _report_skipped(skipped or {})

	local case_pass = #pass_list
	local case_fail = #fail_list
	local case_skip = #skipped

	print("")
	print("=== lua test report ===")
	print("")

	print(string.format("PASS (%d):", case_pass))
	if case_pass > 0 then
		for _, row in ipairs(pass_list) do
			print(_case_line(row.item.doc_id, row.item.desc))
		end
	else
		print("  (none)")
	end

	print(string.format("FAIL (%d):", case_fail))
	if case_fail > 0 then
		for _, row in ipairs(fail_list) do
			print(_case_line(row.item.doc_id, row.item.desc))
		end
	else
		print("  (none)")
	end

	print(string.format("SKIP (%d):", case_skip))
	if case_skip > 0 then
		for _, row in ipairs(skipped) do
			local name = row.reason or ""
			if row.item.desc ~= nil and row.item.desc ~= "" then
				if name ~= "" then
					name = name .. "  " .. row.item.desc
				else
					name = row.item.desc
				end
			end
			print(_case_line(row.item.doc_id, name))
		end
	else
		print("  (none)")
	end

	print(string.format("--- summary: cases pass=%d fail=%d skip=%d ---",
		case_pass, case_fail, case_skip))
end


local function _run_case_thread(doc_id, extra)
	local kthread = require("kthread")
	local kmcache = require("kmcache")
	local ktime = require("ktime")

	local result_key = _result_key(doc_id)
	local start_args = { result_key, doc_id }

	for i = 1, #extra do
		start_args[#start_args + 1] = extra[i]
	end

	local name = kthread.start("lua_test.batch_worker", true, -1, table.unpack(start_args))

	if name == nil or name == "" then
		return false, "kthread.start failed"
	end

	-- start 只等到入口脚本加载完; 须等 worker loop_once 跑完用例再 stop
	local waited = 0
	local status, passed, exit_code = kmcache.get(result_key)
	while status == nil and waited < 8000 do
		ktime.sleep(20)
		waited = waited + 20
		status, passed, exit_code = kmcache.get(result_key)
	end

	kthread.stop(name)

	if status == nil then
		return false, "no result"
	end

	return passed == true, exit_code or "?"
end


function M.run_batch(filter, case_list, prog, script, ...)
	prog = prog or "klua"
	script = script or "test.lua"

	local selected, skipped = M.select_cases(case_list, filter)
	local report_skipped = _report_skipped(skipped)

	print(string.format("batch filter: %s  run: %d  skip: %d", filter, #selected, #report_skipped))

	for _, row in ipairs(report_skipped) do
		local label = row.item.doc_id
		if row.item.desc ~= nil and row.item.desc ~= "" then
			label = label .. "  " .. row.item.desc
		end
		print(string.format("[SKIP] %s (%s)", label, row.reason or "?"))
	end

	if #selected == 0 then
		print("batch: no runnable cases")
		require("ksys").exit()
		return
	end

	local extra = { ... }
	local fail = 0
	local pass = 0
	local pass_list = {}
	local fail_list = {}

	for _, item in ipairs(selected) do
		local passed, exit_info = _run_case_thread(item.doc_id, extra)

		if passed then
			pass = pass + 1
			pass_list[#pass_list + 1] = { item = item }
		else
			fail = fail + 1
			fail_list[#fail_list + 1] = { item = item, exit = exit_info }
		end
	end

	M.print_summary(pass_list, fail_list, skipped)

	if fail > 0 then
		require("ksys").exit(1)
	end

	require("ksys").exit(0)
end

return M
