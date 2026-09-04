--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_12.lua
-- @brief  多分区 mtd.mkfs (2.6.12)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_mkfs_multi"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")

	local work, err = mtd_common.setup_work("2.6.12")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local path, err_raw = mtd_common.raw_create(work, "multi.img", "8M")
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local rc, msg = mtd.mkfs(path, {
		{ fs = "squashfs" },
		{ fs = "jffs2", size = "4M" },
	})
	if rc ~= 0 then
		mtd_common.fail(TAG, "mkfs multi rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok1, err1 = mtd_common.verify_mounted_fs(path, "squashfs")
	if not ok1 then
		mtd_common.fail(TAG, "part1 " .. tostring(err1))
		return
	end

	local fs2, rc2, msg2 = mtd_common.probe_fs_type_part(path, 2)
	if fs2 == nil or fs2 ~= "jffs2" then
		mtd_common.fail(TAG, "part2 fs_type=" .. tostring(fs2) .. " rc=" .. tostring(rc2))
		return
	end

	mtd_common.pass(TAG)
end

return M
