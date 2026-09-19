--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   registry.lua
-- @brief  lua_test 用例注册与分发 (doc_id + 语义 id + 批量 a/1.x/1.1.x); 用例表见 registry_ch*.lua
-- @note   约定 **klua-test-design**; 第1章 klbui, 第2章 kpfs, 第3章 klb
--  \n item.ui=true 时单条先保证 wlua 宿主 (lua_test.klbui.ui)
--  \n UI 页面模块可无 run(); 由 ui.run({ page = mod }) 开窗
-- @history 修改历史
--  \n 2026 创建文件
--]]


local batch = require("lua_test.batch")

local M = {}

local function _chapter_dir()
	local src = debug.getinfo(1, "S").source

	if src:sub(1, 1) == "@" then
		src = src:sub(2)
	end

	return (src:gsub("[^/\\]+$", ""))
end


local function _load_chapter(file)
	return dofile(_chapter_dir() .. file)
end

local CHAPTER_MODULES = {
	_load_chapter("registry_ch1.lua"),
	_load_chapter("registry_ch2.lua"),
	_load_chapter("registry_ch3.lua"),
}

local CHAPTER_TITLE = {}
local CASE_LIST = {}

for _, ch in ipairs(CHAPTER_MODULES) do
	CHAPTER_TITLE[ch.chapter] = ch.title

	for _, item in ipairs(ch.cases) do
		CASE_LIST[#CASE_LIST + 1] = item
	end
end

local ALIAS = {}


local function _build_alias()
	for _, item in ipairs(CASE_LIST) do
		ALIAS[item.doc_id] = item

		for _, id in ipairs(item.ids) do
			ALIAS[id] = item
		end
	end
end

_build_alias()


local function _doc_id_key(doc_id)
	local parts = {}

	for part in string.gmatch(doc_id, "[^.]+") do
		parts[#parts + 1] = tonumber(part) or 0
	end

	return parts
end


local function _cmp_doc_id(a, b)
	local pa = _doc_id_key(a.doc_id)
	local pb = _doc_id_key(b.doc_id)
	local n = #pa

	if #pb > n then
		n = #pb
	end

	for i = 1, n do
		local va = pa[i] or 0
		local vb = pb[i] or 0

		if va ~= vb then
			return va < vb
		end
	end

	return false
end


function M.resolve(case_id)
	return ALIAS[case_id]
end


function M.canonical_id(item)
	if item.ids and item.ids[1] then
		return item.ids[1]
	end

	return item.doc_id
end


function M.list_cases()
	local list = {}

	for _, item in ipairs(CASE_LIST) do
		list[#list + 1] = item
	end

	table.sort(list, _cmp_doc_id)
	return list
end


function M.is_batch_filter(filter)
	return batch.is_batch_filter(filter)
end


function M.run_batch(filter, prog, script, ...)
	batch.run_batch(filter, M.list_cases(), prog, script, ...)
end


function M.print_help(prog, script)
	prog = prog or "klua"
	script = script or "test.lua"

	print(string.format("usage: %s %s <doc_id|semantic id> [args...]", prog, script))
	print(string.format("       %s %s <a|all|1.x|1.1.x|2.x|2.1.x|3.x|3.1.x>  batch (a=all; N.x=chapter; N.M.x=section)", prog, script))
	print(string.format("       %s %s list", prog, script))
	print("")
	print("cases:")

	local chapter = nil

	for _, item in ipairs(M.list_cases()) do
		if chapter ~= item.chapter then
			chapter = item.chapter
			print("")
			print(CHAPTER_TITLE[chapter] or ("Chapter " .. tostring(chapter)))
		end

		local alias = ""
		local batch_tag = ""

		if #item.ids > 1 then
			local parts = {}

			for i = 2, #item.ids do
				parts[#parts + 1] = item.ids[i]
			end

			alias = "  (" .. table.concat(parts, ", ") .. ")"
		end

		if item.batch_ok == false then
			batch_tag = "  [SINGLE_ONLY]"
		end

		local ui_tag = ""
		if item.ui then
			ui_tag = "  [UI]"
		end

		print(string.format("  %-8s  %-18s%s%s%s  %s", item.doc_id, M.canonical_id(item), alias, batch_tag, ui_tag, item.desc))
	end
end


function M.run(case_id, ...)
	local item = M.resolve(case_id)

	if not item then
		print("unknown case:", case_id)
		M.print_help()
		require("ksys").exit(1)
		return
	end

	require("lua_test.report").set_case(item.doc_id, item.desc)

	if item.ui then
		local ui = require("lua_test.klbui.ui")
		if not ui.ensure_host() then
			return
		end
	end

	local ok, mod = pcall(require, item.mod)

	if not ok then
		print("require failed:", item.mod, mod)
		require("ksys").exit(1)
		return
	end

	if type(mod.run) == "function" then
		mod.run(...)
		return
	end

	if item.ui then
		require("lua_test.klbui.ui").run({
			page = mod,
		})
		return
	end

	print("case has no run():", item.mod)
	require("ksys").exit(1)
end

return M
