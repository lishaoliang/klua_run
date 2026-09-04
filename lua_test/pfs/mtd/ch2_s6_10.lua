--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_10.lua
-- @brief  disk.mkfs 格式化 MTD FS 禁止 (2.6.10)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_disk_mkfs_neg"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local disk = require("kpfs.disk")

	local work, err = mtd_common.setup_work("2.6.10")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local path, err_raw = mtd_common.raw_create(work, "flash.img")
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local rc, msg = disk.mkfs(path, { fs = "squashfs" })
	if rc == 0 then
		mtd_common.fail(TAG, "disk.mkfs should fail on mtd fs")
		return
	end

	local fs_type = mtd_common.probe_fs_type(path)
	if fs_type ~= nil then
		mtd_common.fail(TAG, "volume formatted after failed disk.mkfs: " .. tostring(fs_type))
		return
	end

	mtd_common.pass(TAG)
end

return M
