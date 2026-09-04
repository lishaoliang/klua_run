--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_1.lua
-- @brief  mtd.raw.create (2.6.1)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local common = require("lua_test.pfs.make.common")
local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_raw"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local work, err = mtd_common.setup_work("2.6.1")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local size_str = mtd_common.mtd_size_str()
	local path, err_raw = mtd_common.raw_create(work, "raw.bin", size_str, true)
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local fh = io.open(path, "rb")
	if fh == nil then
		mtd_common.fail(TAG, "open raw.bin")
		return
	end

	local data = fh:read("*a")
	fh:close()

	local nbytes = #data
	if nbytes == 0 or (nbytes % 512) ~= 0 then
		mtd_common.fail(TAG, "size not 512 aligned: " .. tostring(nbytes))
		return
	end

	local want_bytes = common.size_str_to_bytes(size_str)
	if want_bytes ~= nil and nbytes ~= want_bytes then
		mtd_common.fail(TAG, "size=" .. tostring(nbytes) .. " want=" .. tostring(want_bytes))
		return
	end

	mtd_common.pass(TAG)
end

return M
