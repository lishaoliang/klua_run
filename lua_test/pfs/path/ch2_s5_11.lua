--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_11.lua
-- @brief  ????????????? (2.5.11)
-- @history ??????
--  \n 2026 ???????
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "opendir_full"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.11")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local sub = mount_common.vfs_path(1, "/kpfs_lt_sub")
	local rc, msg = vfs.mkdir(sub)
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir sub rc=" .. tostring(rc))
		return
	end

	for i = 1, 3 do
		local ok, err_w = mount_common.write_file(sub .. "/f" .. tostring(i) .. ".txt", "f\n", "w")
		if not ok then
			mount_common.fail(TAG, err_w)
			return
		end
	end

	rc, msg = vfs.mkdir(sub .. "/d1")
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir d1 rc=" .. tostring(rc))
		return
	end

	rc, msg = vfs.mkdir(sub .. "/d2")
	if rc ~= 0 then
		mount_common.fail(TAG, "mkdir d2 rc=" .. tostring(rc))
		return
	end

	local root_d = vfs.opendir(mount_common.vfs_path(1, "/"))
	if not mount_common.is_userdata(root_d) then
		mount_common.fail(TAG, "opendir root failed")
		return
	end

	local root_count = 0
	local ent = root_d:readdir()
	while ent ~= nil do
		root_count = root_count + 1
		ent = root_d:readdir()
	end
	root_d:close()

	if root_count < 1 then
		mount_common.fail(TAG, "root empty")
		return
	end

	local sub_d = vfs.opendir(sub)
	if not mount_common.is_userdata(sub_d) then
		mount_common.fail(TAG, "opendir sub failed")
		return
	end

	local files = 0
	local dirs = 0
	ent = sub_d:readdir()
	while ent ~= nil do
		if ent.type == "file" then
			files = files + 1
			local arc = vfs.access(sub .. "/" .. ent.name, "f")
			if arc ~= 0 then
				sub_d:close()
				mount_common.fail(TAG, "file access failed for " .. tostring(ent.name))
				return
			end
		elseif ent.type == "dir" then
			dirs = dirs + 1
			local arc = vfs.access(sub .. "/" .. ent.name, "d")
			if arc ~= 0 then
				sub_d:close()
				mount_common.fail(TAG, "dir access failed for " .. tostring(ent.name))
				return
			end
		end
		ent = sub_d:readdir()
	end
	sub_d:close()

	if files < 3 or dirs < 2 then
		mount_common.fail(TAG, "sub enum files=" .. files .. " dirs=" .. dirs)
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
