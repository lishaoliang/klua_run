--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   file/ch2_s4_7.lua
-- @brief  �ֿ� read(n) (2.4.7)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "read_chunk"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.4.7")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local path = mount_common.vfs_path(1, "/kpfs_lt_chunk.bin")
	local expect = string.rep("C", 8192)

	local ok, err_w = mount_common.write_file(path, expect, "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local f = vfs.open(path, "r")
	if not mount_common.is_userdata(f) then
		mount_common.fail(TAG, "open failed")
		return
	end

	local chunks = {}
	local chunk = f:read(1024)
	while chunk ~= nil and chunk ~= "" do
		chunks[#chunks + 1] = chunk
		chunk = f:read(1024)
	end

	f:close()

	local data = table.concat(chunks)
	if data ~= expect then
		mount_common.fail(TAG, "chunk read mismatch len=" .. tostring(#data))
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
