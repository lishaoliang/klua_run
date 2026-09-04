--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_6.lua
-- @brief  copy ����� (2.5.6); �̶��� N (MBRx2)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "copy_cross"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_dual_rw("2.5.6")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local src = mount_common.vfs_path(1, "/kpfs_lt_a.txt")
	local dst = mount_common.vfs_path(2, "/kpfs_lt_b.txt")
	local payload = "cross part\n"

	local ok, err_w = mount_common.write_file(src, payload, "w")
	if not ok then
		mount_common.fail(TAG, err_w)
		return
	end

	local rc, msg = vfs.copy(src, dst)
	if rc ~= 0 then
		mount_common.fail(TAG, "copy rc=" .. tostring(rc))
		return
	end

	local data = mount_common.read_file(dst)
	if data ~= payload then
		mount_common.fail(TAG, "dst mismatch")
		return
	end

	local src_data = mount_common.read_file(src)
	if src_data ~= payload then
		mount_common.fail(TAG, "src missing after copy")
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
