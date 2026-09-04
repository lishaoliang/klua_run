--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_4.lua
-- @brief  mtd.mkfs ubifs (2.6.4)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_mkfs_ubifs"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")

	local work, err = mtd_common.setup_work("2.6.4")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local path, err_raw = mtd_common.raw_create(work, "flash.img")
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local rc, msg = mtd.mkfs(path, { fs = "ubifs" })
	if rc ~= 0 then
		mtd_common.fail(TAG, "mkfs rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok, err_v = mtd_common.verify_mounted_fs(path, "ubifs")
	if not ok then
		mtd_common.fail(TAG, err_v)
		return
	end

	mtd_common.pass(TAG)
end

return M
