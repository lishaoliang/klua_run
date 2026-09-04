--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_3.lua
-- @brief  seek / tell / truncate (2.4.3)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "vfs_seek"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.3")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_seek.bin")
	local payload = "ABCDEFGHIJ"

	local f = vfs.open(path, "w+")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	local nbytes, rc, msg = f:write(payload)
	if rc ~= nil and rc ~= 0 then
		f:close()
		mount_common.fail(TAG, "write rc=" .. tostring(rc))
		return
	end

	local pos, rc_t = f:tell()
	if rc_t ~= nil and rc_t ~= 0 then
		f:close()
		mount_common.fail(TAG, "tell failed")
		return
	end

	if pos ~= #payload then
		f:close()
		mount_common.fail(TAG, "tell pos=" .. tostring(pos))
		return
	end

	local pos2, rc_s = f:seek(0, "set")
	if rc_s ~= nil and rc_s ~= 0 then
		f:close()
		mount_common.fail(TAG, "seek set failed")
		return
	end

	local head = f:read(4)
	if head ~= "ABCD" then
		f:close()
		mount_common.fail(TAG, "read after seek mismatch")
		return
	end

	rc, msg = f:truncate(4)
	if rc ~= 0 then
		f:close()
		mount_common.fail(TAG, "truncate rc=" .. tostring(rc))
		return
	end

	f:seek(0, "set")
	local tail = f:read(8)
	if tail ~= "ABCD" then
		f:close()
		mount_common.fail(TAG, "tail after truncate")
		return
	end

	f:flush()
	f:fsync()
	f:close()

	local rc_u, msg_u = mount_common.vfs_umount()
	if rc_u ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc_u))
		return
	end

	mount_common.pass(TAG)
end

return M
