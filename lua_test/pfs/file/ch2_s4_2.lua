--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_2.lua
-- @brief  �������ļ� (2.4.2)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "vfs_read"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.2")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_read.txt")
	local expect = "read test content\n"

	local ok, err_w = mount_common.write_file(path, expect, "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local rc, msg = mount_common.vfs_umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount preset rc=" .. tostring(rc))
		return
	end

	rc, msg = mount_common.vfs_mount(image_path, "r")
	if rc ~= 0 then
		mount_common.fail(TAG, "mount r rc=" .. tostring(rc))
		return
	end

	local f = vfs.open(path, "r")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	local chunks = {}
	local chunk = f:read(64)
	while chunk ~= nil and chunk ~= "" do
		chunks[#chunks + 1] = chunk
		chunk = f:read(64)
	end

	local eof = f:eof()
	f:close()

	local data = table.concat(chunks)
	if data ~= expect then
		mount_common.fail(TAG, "content mismatch")
		return
	end

	if not eof then
		mount_common.fail(TAG, "eof not true at EOF")
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
