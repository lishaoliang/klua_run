--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_7.lua
-- @brief  remove �ļ�/��Ŀ¼ (2.5.7)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "path_remove"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.7")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local file_path = mount_common.vfs_path(1, "/kpfs_lt_rm.txt")
	local ok, err_w = mount_common.write_file(file_path, "rm\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local rc, msg = vfs.remove(file_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "remove file rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.access(file_path, "f")
	if rc == 0 then
		mount_common.fail(TAG, "file still accessible")
		return
	end

	rc, msg = vfs.mkdir(mount_common.vfs_path(1, "/kpfs_lt_emptydir"))
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.remove(mount_common.vfs_path(1, "/kpfs_lt_emptydir"))
	if rc ~= 0 then
		mount_common.fail(TAG, "remove dir rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.access(mount_common.vfs_path(1, "/kpfs_lt_emptydir"), "f")
	if rc == 0 then
		mount_common.fail(TAG, "dir still accessible")
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
