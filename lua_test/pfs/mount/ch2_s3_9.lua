--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_9.lua
-- @brief  umount 单分区 / 批量 (2.3.9); case_dir 临时 MBRx2 镜像
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "umount_part"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local kpfs = require("kpfs")

	local work, err = mount_common.setup_work("2.3.9")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	mount_common.umount()

	local image_path, err_img = mount_common.prepare_temp_mbr_dual_exfat(work, "umount_part.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local rc, msg = mount_common.mount(image_path, "rw")
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok1, err1 = mount_common.write_file(mount_common.drive_path(1, "/kpfs_lt_u1.txt"), "u1")
	local ok2, err2 = mount_common.write_file(mount_common.drive_path(2, "/kpfs_lt_u2.txt"), "u2")
	if not ok1 or not ok2 then
		mount_common.umount()
		mount_common.fail(TAG, tostring(err1) .. " " .. tostring(err2))
		return
	end

	rc, msg = kpfs.umount(mount_common.DRIVE, 1)
	if rc ~= 0 then
		mount_common.umount()
		mount_common.fail(TAG, "umount part1 rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok_t1 = mount_common.access_ok(mount_common.drive_path(1, "/kpfs_lt_u1.txt"), "f")
	local ok_t2 = mount_common.access_ok(mount_common.drive_path(2, "/kpfs_lt_u2.txt"), "f")
	if ok_t1 then
		mount_common.umount()
		mount_common.fail(TAG, "T1 still accessible after umount part1")
		return
	end

	if not ok_t2 then
		mount_common.umount()
		mount_common.fail(TAG, "T2 should still be accessible")
		return
	end

	rc, msg = kpfs.umount(mount_common.DRIVE, { 2 })
	if rc ~= 0 then
		mount_common.fail(TAG, "umount part2 rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	mount_common.pass(TAG)
end

return M
