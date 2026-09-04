--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_2.lua
-- @brief  opendir Ŀ¼ö�� (2.5.2)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "path_opendir"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.2")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local dir_path = mount_common.vfs_path(1, "/kpfs_lt_dir")
	local rc, msg = vfs.mkdir(dir_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir rc=" .. tostring(rc))
		return
	end

	local ok, err_w = mount_common.write_file(mount_common.vfs_path(1, "/kpfs_lt_dir/item.txt"), "i\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local d = vfs.opendir(dir_path)
	if not mount_common.is_userdata(d) then
		mount_common.fail(TAG, "opendir failed")
		return
	end

	local found = false
	local ent = d:readdir()
	while ent ~= nil do
		if ent.name == "item.txt" then
			found = true
			if ent.type ~= "file" then
				d:close()
				mount_common.fail(TAG, "type not file")
				return
			end
		end
		ent = d:readdir()
	end

	d:close()

	if not found then
		mount_common.fail(TAG, "item.txt not found")
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
