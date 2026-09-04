--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_7.lua
-- @brief  mtd.mkvol squashfs (2.6.7)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_mkvol_squashfs"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")

	local work, err = mtd_common.setup_work("2.6.7")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local tree, err_tree = mtd_common.write_tree(work, "tree")
	if tree == nil then
		mtd_common.fail(TAG, err_tree)
		return
	end

	local path, err_raw = mtd_common.raw_create(work, "flash.img")
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local rc, msg = mtd.mkvol(path, { fs = "squashfs", src = tree })
	if rc ~= 0 then
		mtd_common.fail(TAG, "mkvol rc=" .. tostring(rc))
		return
	end

	local data, err_read = mtd_common.read_hello(path)
	if data == nil then
		mtd_common.fail(TAG, err_read)
		return
	end

	mtd_common.pass(TAG)
end

return M
