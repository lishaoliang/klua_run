--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/ch2_s6_20.lua
-- @brief  mtd.mkvol 多分区 + label (2.6.20)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mtd_common = require("lua_test.pfs.mtd.common")

local M = {}
local TAG = "mtd_mkvol_multi"


function M.run(...)

	if mtd_common.require_kpfs() == nil then
		return
	end

	local mtd = require("kpfs.mtd")
	local mount_common = require("lua_test.pfs.mount.common")

	local work, err = mtd_common.setup_work("2.6.20")
	if work == nil then
		mtd_common.fail(TAG, err)
		return
	end

	local tree1, err1 = mtd_common.write_tree(work, "tree1", "tree1\n")
	local tree2, err2 = mtd_common.write_tree(work, "tree2", "tree2\n")
	if tree1 == nil or tree2 == nil then
		mtd_common.fail(TAG, tostring(err1) .. " " .. tostring(err2))
		return
	end

	local path, err_raw = mtd_common.raw_create(work, "multi.img", "8M")
	if path == nil then
		mtd_common.fail(TAG, err_raw)
		return
	end

	local rc, msg = mtd.mkvol(path, {
		{ fs = "squashfs", src = tree1, label = "V1" },
		{ fs = "jffs2", src = tree2, label = "V2", jffs2_erase_size = 65536 },
	})
	if rc ~= 0 then
		mtd_common.fail(TAG, "mkvol multi rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local rc_m, msg_m = mtd_common.mount_flash(path, "r")
	if rc_m ~= 0 then
		mtd_common.fail(TAG, "mount rc=" .. tostring(rc_m))
		return
	end

	local data1 = mount_common.read_file(mtd_common.drive_path("/hello.txt"))
	if data1 == nil or data1 ~= "tree1\n" then
		mtd_common.umount_flash()
		mtd_common.fail(TAG, "part1 read mismatch")
		return
	end

	local data2 = mount_common.read_file(mtd_common.drive_path_part(2, "/hello.txt"))
	mtd_common.umount_flash()

	if data2 == nil or data2 ~= "tree2\n" then
		mtd_common.fail(TAG, "part2 read mismatch")
		return
	end

	mtd_common.pass(TAG)
end

return M
