--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_5.lua
-- @brief  �򿪲�����·������ (2.4.5)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "open_enoent"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.5")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local f = vfs.open(mount_common.vfs_path(1, "/kpfs_lt_nope.txt"), "r")
	if mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open succeeded on missing file")
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
