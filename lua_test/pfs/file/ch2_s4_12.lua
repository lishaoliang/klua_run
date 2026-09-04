--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_12.lua
-- @brief  fsync �־û� umount ���� (2.4.12, UMOUNT_FLOW)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "vfs_fsync"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.12")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_fsync.txt")
	local payload = "fsync data\n"

	local f = vfs.open(path, "w")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	f:write(payload)
	local rc, msg = f:fsync()
	if rc ~= 0 then
		f:close()
		mount_common.fail(TAG, "fsync rc=" .. tostring(rc))
		return
	end

	f:close()

	rc, msg = mount_common.vfs_umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc))
		return
	end

	rc, msg = mount_common.vfs_mount(image_path, "r")
	if rc ~= 0 then
		mount_common.fail(TAG, "remount rc=" .. tostring(rc))
		return
	end

	local data = mount_common.read_file(path)
	if data ~= payload then
		mount_common.fail(TAG, "data lost after fsync")
		return
	end

	rc, msg = mount_common.vfs_umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "final umount rc=" .. tostring(rc))
		return
	end

	mount_common.pass(TAG)
end

return M
