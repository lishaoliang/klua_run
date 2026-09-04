--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_1.lua
-- @brief  写不存在文件 CREAT (2.4.1)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "vfs_open"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local work, image_path, err = mount_common.setup_mounted_rw("2.4.1")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.drive_path(1, "/kpfs_lt_new.txt")
	local data = "new file data\n"

	local ok_exist = mount_common.access_ok(path, "f")
	if ok_exist then
		mount_common.umount()
		mount_common.fail(TAG, "target file already exists")
		return
	end

	local ok, err_w = mount_common.write_file(path, data, "w")
	if not ok then
		mount_common.umount()
		mount_common.fail(TAG, err_w)
		return
	end

	local read_back = mount_common.read_file(path)
	if read_back ~= data then
		mount_common.umount()
		mount_common.fail(TAG, "readback mismatch")
		return
	end

	local rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	mount_common.pass(TAG)
end

return M
