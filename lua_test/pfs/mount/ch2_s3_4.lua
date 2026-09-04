--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_4.lua
-- @brief  显式 umount 流程 (2.3.4, UMOUNT_FLOW)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "umount_flow"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local work, err = mount_common.setup_work("2.3.4")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.prepare_gpt_exfat(work, "umount.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local path = mount_common.drive_path(1, "/kpfs_lt_umount.txt")

	local rc, msg = mount_common.mount(image_path, "rw")
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rw rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok, err_w = mount_common.write_file(path, "umount flow\n")
	if not ok then
		mount_common.umount()
		mount_common.fail(TAG, "preset " .. tostring(err_w))
		return
	end

	local f = vfs.open(path, "r")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	rc, msg = mount_common.umount()
	if rc == 0 then
		print("  note: umount with open handle succeeded (implementation)")
	else
		print("  umount busy rc=" .. tostring(rc) .. " " .. tostring(msg))
	end

	f:close()

	rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount after close rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = mount_common.mount(image_path, "r")
	if rc ~= 0 then
		mount_common.fail(TAG, "remount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local data = mount_common.read_file(path)
	if data ~= "umount flow\n" then
		mount_common.fail(TAG, "readback mismatch")
		return
	end

	rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "final umount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	mount_common.pass(TAG)
end

return M
