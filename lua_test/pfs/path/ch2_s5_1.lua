--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_1.lua
-- @brief  mkdir ����Ŀ¼д�ļ� (2.5.1)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "path_mkdir"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.1")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local rc, msg = vfs.mkdir(mount_common.vfs_path(1, "/d1/d2"))
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir rc=" .. tostring(rc))
		return
	end

	local path = mount_common.vfs_path(1, "/d1/d2/kpfs_lt_w.txt")
	local ok, err_w = mount_common.write_file(path, "nested\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local data = mount_common.read_file(path)
	if data ~= "nested\n" then
		mount_common.fail(TAG, "readback mismatch")
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
