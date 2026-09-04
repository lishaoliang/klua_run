--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_10.lua
-- @brief  opendir ������ direrror (2.5.10)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "opendir_neg"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.10")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local d = vfs.opendir(mount_common.vfs_path(1, "/kpfs_lt_nope_dir"))
	if mount_common.is_userdata(d) then
		mount_common.fail(TAG, "opendir missing path succeeded")
		return
	end

	local file_path = mount_common.vfs_path(1, "/kpfs_lt_notdir.txt")
	local ok, err_w = mount_common.write_file(file_path, "x", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	d = vfs.opendir(file_path)
	if mount_common.is_userdata(d) then
		mount_common.fail(TAG, "opendir on file succeeded")
		return
	end

	local dir_path = mount_common.vfs_path(1, "/kpfs_lt_okdir")
	local rc, msg = vfs.mkdir(dir_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir rc=" .. tostring(rc))
		return
	end

	d = vfs.opendir(dir_path)
	if not mount_common.is_userdata(d) then
		mount_common.fail(TAG, "opendir okdir failed")
		return
	end

	local ent = d:readdir()
	while ent ~= nil do
		ent = d:readdir()
	end

	rc, msg = d:direrror()
	if rc ~= 0 then
		d:close()
		mount_common.fail(TAG, "direrror rc=" .. tostring(rc))
		return
	end

	d:close()

	rc, msg = mount_common.vfs_umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc))
		return
	end

	mount_common.pass(TAG)
end

return M
