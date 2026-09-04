--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_13.lua
-- @brief  mtd.mkfs yaffs (2.6.13)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_mkfs_yaffs"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")

	local work, err = mtd_common.setup_work("2.6.13")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local path, err_raw = mtd_common.raw_create(work, "flash.img")
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local rc, msg = mtd.mkfs(path, { fs = "yaffs2" })
	if rc ~= 0 then
		mtd_common.fail(TAG, "mkfs rc=" .. tostring(rc))
		return
	end

	local fs_type, rc2, msg2 = mtd_common.probe_fs_type(path)
	if fs_type == nil or (fs_type ~= "yaffs" and fs_type ~= "yaffs2") then
		mtd_common.fail(TAG, "fs_type=" .. tostring(fs_type))
		return
	end

	mtd_common.pass(TAG)
end

return M
