--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_8.lua
-- @brief  path ���� (2.5.8)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "path_neg"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.8")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local dup_path = mount_common.vfs_path(1, "/kpfs_lt_dup")
	local rc, msg = vfs.mkdir(dup_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir dup rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.mkdir(dup_path)
	if rc == 0 then
		mount_common.fail(TAG, "duplicate mkdir succeeded")
		return
	end

	rc, msg = vfs.mkdir(mount_common.vfs_path(1, "/kpfs_lt_no_parent/child"))
	if rc == 0 then
		mount_common.fail(TAG, "mkdir without parent succeeded")
		return
	end

	rc, msg = vfs.mkdir(mount_common.vfs_path(1, "/kpfs_lt_full"))
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir full rc=" .. tostring(rc))
		return
	end

	local ok, err_w = mount_common.write_file(mount_common.vfs_path(1, "/kpfs_lt_full/inner.txt"), "x", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	rc, msg = vfs.rmdir(mount_common.vfs_path(1, "/kpfs_lt_full"))
	if rc == 0 then
		mount_common.fail(TAG, "rmdir non-empty succeeded")
		return
	end

	rc, msg = vfs.unlink(dup_path)
	if rc == 0 then
		mount_common.fail(TAG, "unlink on dir succeeded")
		return
	end

	local exist_file = mount_common.vfs_path(1, "/kpfs_lt_exist.txt")
	ok, err_w = mount_common.write_file(exist_file, "e\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	rc, msg = vfs.rename(exist_file, dup_path)
	if rc == 0 then
		mount_common.fail(TAG, "rename to existing dir succeeded")
		return
	end

	local exist_file2 = mount_common.vfs_path(1, "/kpfs_lt_exist2.txt")
	ok, err_w = mount_common.write_file(exist_file2, "e2\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	rc, msg = vfs.rename(exist_file, exist_file2)
	if rc == 0 then
		mount_common.fail(TAG, "rename to existing file succeeded")
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
