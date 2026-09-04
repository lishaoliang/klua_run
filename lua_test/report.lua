--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   report.lua
-- @brief  lua_test 运行时打印 (对齐 pfs_test harness)
-- @note   约定 **klua-test-design**; registry/batch_worker 须先 set_case
-- @history 修改历史
--  \n 2026 创建文件
--]]


local M = {}

local _doc_id = nil
local _desc = nil


function M.set_case(doc_id, desc)
	_doc_id = doc_id
	_desc = desc or ""
end


function M.label()
	if _doc_id == nil then
		return "?"
	end

	if _desc ~= nil and _desc ~= "" then
		return _doc_id .. "  " .. _desc
	end

	return _doc_id
end


function M.pass()
	print(string.format("[PASS] %s", M.label()))
	print("")
end


function M.fail(msg)
	if msg ~= nil and msg ~= "" then
		print(string.format("[FAIL] %s (%s)", M.label(), msg))
	else
		print(string.format("[FAIL] %s", M.label()))
	end
	print("")
end


function M.skip(msg)
	if msg ~= nil and msg ~= "" then
		print(string.format("[SKIP] %s (%s)", M.label(), msg))
	else
		print(string.format("[SKIP] %s", M.label()))
	end
	print("")
end


function M.print_disk_path(path)
	print("[disk] path=" .. tostring(path))
end


function M.print_disk_slot(slot)
	print("[disk] slot=" .. tostring(slot))
end


function M.print_disk_scheme(scheme)
	print("[disk] scheme=" .. tostring(scheme))
end


function M.print_disk_fs(fs)
	print("[disk] fs=" .. tostring(fs))
end


function M.print_disk_part_offset(off)
	print("[disk] part_offset=" .. tostring(off))
end


--- 固定盘槽位 + 已格式化分区 (2.4/2.5)
function M.print_disk_slot_formatted(slot, image_path, fs_type, count)
	M.print_disk_path(image_path)
	M.print_disk_slot(slot)

	if count ~= nil and count > 1 then
		M.print_disk_fs(tostring(fs_type) .. " x" .. tostring(count))
	else
		M.print_disk_fs(fs_type or "?")
	end
end


--- 固定盘槽位 probe 通过 (只读)
function M.print_disk_slot_probe(slot, image_path, scheme, fs_type)
	M.print_disk_path(image_path)
	M.print_disk_slot(slot)

	if scheme ~= nil and scheme ~= "" then
		M.print_disk_scheme(scheme)
	end

	M.print_disk_fs(fs_type or "?")
end

return M
