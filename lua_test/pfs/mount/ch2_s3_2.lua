--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_2.lua
-- @brief  remount 只读<->读写 (2.3.2)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "remount"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local work, err = mount_common.setup_work("2.3.2")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.prepare_gpt_exfat(work, "remount.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local rc, msg = mount_common.mount(image_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = mount_common.remount("rw")
	if rc ~= 0 then
		mount_common.fail(TAG, "remount rw rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok, err_w = mount_common.write_file(mount_common.drive_path(1, "/kpfs_lt_rw.txt"), "x")
	if not ok then
		mount_common.umount()
		mount_common.fail(TAG, err_w)
		return
	end

	rc, msg = mount_common.remount("r")
	if rc ~= 0 then
		mount_common.fail(TAG, "remount r rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local vfs = require("kpfs.vfs")
	local f = vfs.open(mount_common.drive_path(1, "/kpfs_lt_rw.txt"), "w")
	if mount_common.is_userdata(f) then
		mount_common.umount()
		mount_common.fail(TAG, "write after remount r succeeded")
		return
	end

	rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	mount_common.pass(TAG)
end

return M
