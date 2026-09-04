--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_16.lua
-- @brief  mtd.mkvol erofs 空树 (2.6.16)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_mkvol_erofs"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")

	local work, err = mtd_common.setup_work("2.6.16")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local tree, err_tree = mtd_common.write_empty_tree(work, "empty_tree")
	if tree == nil then
		mtd_common.fail(TAG, err_tree)
		return
	end

	local path, err_raw = mtd_common.raw_create(work, "flash.img")
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local rc, msg = mtd.mkvol(path, { fs = "erofs", src = tree })
	if rc ~= 0 then
		mtd_common.fail(TAG, "mkvol rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local rc_m, msg_m = mtd_common.mount_flash(path, "r")
	if rc_m ~= 0 then
		mtd_common.fail(TAG, "mount rc=" .. tostring(rc_m))
		return
	end

	mtd_common.umount_flash()
	mtd_common.pass(TAG)
end

return M
