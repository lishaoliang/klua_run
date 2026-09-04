--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_9.lua
-- @brief  truncate ��չ (2.4.9)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "truncate_extend"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.9")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_ext.bin")
	local base = "BASE"

	local f = vfs.open(path, "w+")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	f:write(base)
	local s = #base
	local rc, msg = f:truncate(s * 2)
	if rc ~= 0 then
		f:close()
		mount_common.fail(TAG, "truncate rc=" .. tostring(rc))
		return
	end

	f:seek(s, "set")
	f:write("EXT")
	f:seek(0, "set")
	local head = f:read(s)
	f:seek(s, "set")
	local ext = f:read(3)
	f:close()

	if head ~= base or ext ~= "EXT" then
		mount_common.fail(TAG, "content mismatch")
		return
	end

	local rc_u, msg_u = mount_common.vfs_umount()
	if rc_u ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc_u))
		return
	end

	mount_common.pass(TAG)
end

return M
