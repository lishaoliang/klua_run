--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_19.lua
-- @brief  raw.create 非对齐 size 负例 (2.6.19)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_raw_neg"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")

	local work, err = mtd_common.setup_work("2.6.19")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local path = paths.join(work, "bad.bin")
	local rc, msg = mtd.raw.create({
		path = path,
		size = 1000,
		force = true,
	})
	if rc == 0 then
		mtd_common.fail(TAG, "non-aligned size succeeded")
		return
	end

	mtd_common.pass(TAG)
end

return M
