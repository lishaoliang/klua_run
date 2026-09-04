--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_4.lua
-- @brief  覆盖写已存在文件 (2.4.4)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "vfs_write"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.4")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_over.txt")

	local ok, err_w = mount_common.write_file(path, "original\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	ok, err_w = mount_common.write_file(path, "replaced\n", "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local data = mount_common.read_file(path)
	if data ~= "replaced\n" then
		mount_common.fail(TAG, "readback mismatch")
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
