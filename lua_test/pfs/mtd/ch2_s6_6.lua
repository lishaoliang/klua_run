--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_6.lua
-- @brief  mtd.ubi.create (2.6.6)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_ubi"

local DEFAULT_LEB_SIZE = 128 * 1024
local DEFAULT_LEB_COUNT = 64


local function _file_size(path)
	local fh = io.open(path, "rb")
	if fh == nil then
		return nil
	end

	local data = fh:read("*a")
	fh:close()
	return #data
end


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")

	local work, err = mtd_common.setup_work("2.6.6")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local path1 = paths.join(work, "ubi.img")
	local rc, msg = mtd.ubi.create({
		path = path1,
		force = true,
	})
	if rc ~= 0 then
		mtd_common.fail(TAG, "ubi default rc=" .. tostring(rc))
		return
	end

	local nbytes1 = _file_size(path1)
	local want1 = DEFAULT_LEB_SIZE * DEFAULT_LEB_COUNT
	if nbytes1 == nil or nbytes1 ~= want1 then
		mtd_common.fail(TAG, "ubi default size=" .. tostring(nbytes1) .. " want=" .. tostring(want1))
		return
	end

	local path2 = paths.join(work, "ubi2.img")
	rc, msg = mtd.ubi.create({
		path = path2,
		force = true,
		leb_size = DEFAULT_LEB_SIZE,
		leb_count = DEFAULT_LEB_COUNT,
	})
	if rc ~= 0 then
		mtd_common.fail(TAG, "ubi explicit rc=" .. tostring(rc))
		return
	end

	local nbytes2 = _file_size(path2)
	if nbytes2 == nil or nbytes2 ~= want1 then
		mtd_common.fail(TAG, "ubi explicit size=" .. tostring(nbytes2) .. " want=" .. tostring(want1))
		return
	end

	mtd_common.pass(TAG)
end

return M
