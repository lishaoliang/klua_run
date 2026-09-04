--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_3.lua
-- @brief  path �� access/rename/unlink/rmdir (2.5.3)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "path_basic"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.3")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local rc, msg = vfs.access(mount_common.vfs_path(1, "/"), "f")
	if rc ~= 0 then
		mount_common.fail(TAG, "access root rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.mkdir(mount_common.vfs_path(1, "/kpfs_lt_x"))
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir x rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.rename(mount_common.vfs_path(1, "/kpfs_lt_x"), mount_common.vfs_path(1, "/kpfs_lt_y"))
	if rc ~= 0 then
		mount_common.fail(TAG, "rename dir rc=" .. tostring(rc))
		return
	end

	local file_path = mount_common.vfs_path(1, "/kpfs_lt_y/f.txt")
	local ok, err_w = mount_common.write_file(file_path, "f\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	rc, msg = vfs.unlink(file_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "unlink rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.rmdir(mount_common.vfs_path(1, "/kpfs_lt_y"))
	if rc ~= 0 then
		mount_common.fail(TAG, "rmdir rc=" .. tostring(rc))
		return
	end

	rc, msg = mount_common.vfs_umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc))
		return
	end

	mount_common.pass(TAG)
end

return M
