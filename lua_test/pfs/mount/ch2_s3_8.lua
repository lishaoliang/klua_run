--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_8.lua
-- @brief  remount 单分区 (2.3.8); case_dir 临时 MBRx2 镜像
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "remount_part"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local work, err = mount_common.setup_work("2.3.8")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	mount_common.umount()

	local image_path, err_img = mount_common.prepare_temp_mbr_dual_exfat(work, "remount_part.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local rc, msg = mount_common.mount(image_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = mount_common.remount_part(2, "rw")
	if rc ~= 0 then
		mount_common.umount()
		mount_common.fail(TAG, "remount part2 rw rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local f1 = vfs.open(mount_common.drive_path(1, "/kpfs_lt_p1.txt"), "w")
	if mount_common.is_userdata(f1) then
		mount_common.umount()
		mount_common.fail(TAG, "T1 write still allowed")
		return
	end

	local ok, err_w = mount_common.write_file(mount_common.drive_path(2, "/kpfs_lt_p2.txt"), "p2")
	if not ok then
		mount_common.umount()
		mount_common.fail(TAG, "T2 write failed: " .. tostring(err_w))
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
