--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_10.lua
-- @brief  �Ƿ� seek / EOF seek (2.4.10)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "seek_bad"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.10")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_seekbad.txt")

	local ok, err_w = mount_common.write_file(path, "short", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local f = vfs.open(path, "r")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	local pos, rc = f:seek(-999999, "set")
	if rc == nil or rc == 0 then
		if pos ~= nil and pos >= 0 then
			mount_common.fail(TAG, "large negative seek accepted")
			return
		end
	end

	f:seek(0, "end")
	local tail = f:read(8)
	local eof = f:eof()
	f:close()

	if tail ~= nil and tail ~= "" then
		mount_common.fail(TAG, "read after end not empty")
		return
	end

	if not eof then
		mount_common.fail(TAG, "eof not set after seek to end")
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
