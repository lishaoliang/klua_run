--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_6.lua
-- @brief  open ģʽ r+ / a / a+ (2.4.6)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "open_mode"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.6")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_mode.txt")

	local f = vfs.open(path, "r+")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "r+ open failed")
		return
	end

	f:write("mode")
	f:close()

	local fa = vfs.open(path, "a")
	if not mount_common.is_userdata(fa) then
		mount_common.fail(TAG, "a open failed")
		return
	end

	local pos = fa:tell()
	fa:write("+append")
	fa:close()

	local fap = vfs.open(path, "a+")
	if not mount_common.is_userdata(fap) then
		mount_common.fail(TAG, "a+ open failed")
		return
	end

	local data = fap:read(64)
	fap:close()

	if data == nil or data:sub(1, 4) ~= "mode" then
		mount_common.fail(TAG, "a+ read mismatch")
		return
	end

	if pos ~= nil and pos < 4 then
		mount_common.fail(TAG, "append tell not at end")
		return
	end

	local rc, msg = mount_common.vfs_umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc))
		return
	end

	mount_common.pass(TAG)
end

return M
