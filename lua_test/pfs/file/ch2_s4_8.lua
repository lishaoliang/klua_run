--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_8.lua
-- @brief  ���ļ� CREAT (2.4.8)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "vfs_empty"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.8")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_empty.txt")

	local f = vfs.open(path, "w")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open w failed")
		return
	end

	f:close()

	local rc, msg = vfs.access(path, "f")
	if rc ~= 0 then
		mount_common.fail(TAG, "access failed rc=" .. tostring(rc))
		return
	end

	local data = mount_common.read_file(path)
	if data ~= "" then
		mount_common.fail(TAG, "non-empty file")
		return
	end

	rc, msg = vfs.unlink(path)
	if rc ~= 0 then
		mount_common.fail(TAG, "unlink rc=" .. tostring(rc))
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
