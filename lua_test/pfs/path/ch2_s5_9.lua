--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_9.lua
-- @brief  ����� rename (2.5.9); �̶��� N (MBRx2)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "rename_cross"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_dual_rw("2.5.9")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local src_file = mount_common.vfs_path(1, "/kpfs_lt_f.txt")
	local dst_file = mount_common.vfs_path(2, "/kpfs_lt_f.txt")

	local ok, err_w = mount_common.write_file(src_file, "move\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local rc, msg = vfs.rename(src_file, dst_file)
	if rc ~= 0 then
		mount_common.fail(TAG, "file cross rename rc=" .. tostring(rc))
		return
	end

	local data = mount_common.read_file(dst_file)
	if data ~= "move\n" then
		mount_common.fail(TAG, "dst read mismatch")
		return
	end

	local ok_src = mount_common.access_ok(src_file, "f")
	if ok_src then
		mount_common.fail(TAG, "src still exists after cross rename")
		return
	end

	rc, msg = vfs.mkdir(mount_common.vfs_path(1, "/kpfs_lt_d"))
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.rename(
		mount_common.vfs_path(1, "/kpfs_lt_d"),
		mount_common.vfs_path(2, "/kpfs_lt_d"))
	if rc == 0 then
		mount_common.fail(TAG, "dir cross rename should fail")
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
