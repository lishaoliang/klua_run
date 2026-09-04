--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   test_disk.lua
-- @brief  固定虚拟盘 M/N/P 槽位路径 (klua_run/tmp/test_disk/disks)
-- @note   约定 **workspace-test-disk**; mount 盘名与槽位同名 M/N/P
--         **只读探测**: 2.1 probe 禁止对 M/N/P 做 mkpt/mkfs/mkvol; 2.4/2.5 vfs 可 mount 写文件 (必要时 mkfs)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local kenv = require("kenv")
local paths = require("lua_test.paths")
local fsutil = require("lua_test.util.fsutil")

local M = {}

local SLOT_FILE = {
	M = "m.vhdx",
	N = "n.vhd",
	P = "p.qcow2",
}

M.SLOTS = { "M", "N", "P" }

--- 槽位分区设计 (test_disk setup 落盘)
M.SLOT_LAYOUT = {
	M = { scheme = "gpt", part_count = 4 },
	N = { scheme = "mbr", part_count = 2 },
	P = { scheme = "gpt", part_count = 2 },
}


--- 槽位镜像真源路径 (优先 TEST_DISK_M/N/P 环境变量)
function M.disk_path(slot)
	slot = slot or "M"
	local env = os.getenv("TEST_DISK_" .. slot)
	if env ~= nil and env ~= "" then
		return env
	end

	local file = SLOT_FILE[slot]
	if file == nil then
		return nil
	end

	local root = kenv.base_path() .. "tmp/test_disk/disks"
	return paths.join(root, file)
end


--- mount 盘名 (与槽位字母一致)
function M.drive_name(slot)
	return slot or "M"
end


--- 分区盘符路径前缀, eg. M1:
function M.drive_prefix(slot, part_index)
	part_index = part_index or 1
	return M.drive_name(slot) .. tostring(part_index) .. ":"
end


function M.part_count(slot)
	local layout = M.SLOT_LAYOUT[slot]
	if layout == nil then
		return 1
	end
	return layout.part_count or 1
end


function M.scheme(slot)
	local layout = M.SLOT_LAYOUT[slot]
	if layout == nil then
		return "gpt"
	end
	return layout.scheme or "gpt"
end


--- 槽位镜像文件是否存在
function M.disk_exists(slot)
	local path = M.disk_path(slot)
	if path == nil or path == "" then
		return false
	end
	return fsutil.exists(path)
end


--- 固定盘分区表前置: 镜像存在且 probe.part 布局符合 SLOT_LAYOUT
-- @return ok boolean
-- @return err string|nil
-- @return info table|nil  probe.part 载荷 (ok 时)
function M.check_partition_layout(slot, min_parts)
	local path = M.disk_path(slot)
	if path == nil or path == "" then
		return false, "unknown test_disk slot " .. tostring(slot)
	end
	if not fsutil.exists(path) then
		return false, "slot " .. slot .. " image missing: " .. path
			.. " (run klua_run/tmp/test_disk/setup.ps1 -CreateOnly or setup --partition)"
	end

	local ok_kpfs, _ = pcall(require, "kpfs")
	if not ok_kpfs then
		return false, "kpfs not loaded"
	end

	local probe = require("kpfs.probe")
	local info, rc, msg = probe.part(path)
	if rc ~= 0 then
		return false, "probe.part slot " .. slot .. " rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	local expect_scheme = M.scheme(slot)
	local actual_scheme = info.scheme or "none"
	if actual_scheme ~= expect_scheme then
		return false, "slot " .. slot .. " scheme mismatch: expect " .. expect_scheme
			.. ", got " .. tostring(actual_scheme) .. " (run test_disk setup --partition)"
	end

	local want = min_parts or M.part_count(slot)
	local actual_count = info.part_count or 0
	if actual_count < want then
		return false, "slot " .. slot .. " part_count " .. tostring(actual_count)
			.. " < " .. tostring(want) .. " (run test_disk setup --partition)"
	end

	return true, nil, info
end


--- 固定盘是否合法槽位字母
function M.is_slot(slot)
	return SLOT_FILE[slot] ~= nil
end

return M
