--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   make/ch2_s2_6.lua
-- @brief  kpfs.image + disk.mkpt/mkfs + probe.fs (2.2.6)
-- @note   须 libkpfs 插件
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local common = require("lua_test.pfs.make.common")
local report = require("lua_test.report")

local M = {}

local TAG = "mkfs"


function M.run(...)

	if common.require_kpfs() == nil then
		return
	end

	local image = require("kpfs.image")
	local disk = require("kpfs.disk")
	local probe = require("kpfs.probe")

	local work, err = common.setup_work("2.2.6")
	if work == nil then
		common.fail(TAG, err)
		return
	end

	local image_path = paths.join(work, "mkfs.vhdx")
	local size_str = common.exfat_disk_size_str()

	report.print_disk_path(image_path)
	print("  size:", size_str)

	local rc, msg = image.create(image_path, {
		type = "vhdx",
		size = size_str,
		layout = "dynamic",
	})
	if rc ~= 0 then
		common.fail(TAG, "image.create rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = disk.mkpt(image_path, {
		scheme = "gpt",
		fs = "exfat",
	})
	if rc ~= 0 then
		common.fail(TAG, "disk.mkpt rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = disk.mkfs(image_path, {
		fs = "exfat",
	})
	if rc ~= 0 then
		common.fail(TAG, "disk.mkfs rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local info, rc2, msg2 = probe.fs(image_path)
	if rc2 ~= 0 then
		common.fail(TAG, "probe.fs rc=" .. tostring(rc2) .. " " .. tostring(msg2))
		return
	end

	if not common.probe_mount_ok(info) then
		common.fail(TAG, "mount_ok is not true")
		return
	end

	print("  probe part_count:", info.part_count or 0)
	print("  probe mount_ok: true")

	common.pass()
end

return M
