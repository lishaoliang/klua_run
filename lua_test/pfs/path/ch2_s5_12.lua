--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_12.lua
-- @brief  UTF-8 �ļ��� (2.5.12)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "name_utf8"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.12")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local name = "kpfs_lt_����.txt"
	local path = mount_common.vfs_path(1, "/" .. name)
	local payload = "utf8\n"

	local ok, err_w = mount_common.write_file(path, payload, "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local d = vfs.opendir(mount_common.vfs_path(1, "/"))
	if not mount_common.is_userdata(d) then
		mount_common.fail(TAG, "opendir failed")
		return
	end

	local found = false
	local ent = d:readdir()
	while ent ~= nil do
		if ent.name == name then
			found = true
		end
		ent = d:readdir()
	end
	d:close()

	if not found then
		mount_common.fail(TAG, "utf8 name not in listing")
		return
	end

	local data = mount_common.read_file(path)
	if data ~= payload then
		mount_common.fail(TAG, "read mismatch")
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
