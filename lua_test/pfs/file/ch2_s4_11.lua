--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_11.lua
-- @brief  f:error() �������ѯ (2.4.11)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "vfs_error"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.11")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_err.txt")
	local ok, err_w = mount_common.write_file(path, "ok\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local f = vfs.open(path, "r")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	f:read(2)
	local rc, msg = f:error()
	if rc ~= 0 then
		f:close()
		mount_common.fail(TAG, "error after ok read rc=" .. tostring(rc))
		return
	end

	f:close()

	local rc_u, msg_u = mount_common.vfs_umount()
	if rc_u ~= 0 then
		mount_common.fail(TAG, "umount rw rc=" .. tostring(rc_u))
		return
	end

	rc_u, msg_u = mount_common.vfs_mount(image_path)
	if rc_u ~= 0 then
		mount_common.fail(TAG, "mount ro rc=" .. tostring(rc_u))
		return
	end

	local fr = vfs.open(path, "r")
	if not mount_common.is_userdata(fr) then
		mount_common.fail(TAG, "open ro read failed")
		return
	end

	local _, wrc = fr:write("x")
	if wrc == nil or wrc == 0 then
		fr:close()
		mount_common.fail(TAG, "write on ro mount should fail")
		return
	end

	rc, msg = fr:error()
	if rc == 0 then
		fr:close()
		mount_common.fail(TAG, "f:error should report write failure")
		return
	end

	fr:close()

	rc_u, msg_u = mount_common.vfs_umount()
	if rc_u ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc_u))
		return
	end

	mount_common.pass(TAG)
end

return M
