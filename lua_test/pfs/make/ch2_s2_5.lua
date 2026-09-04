--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   make/ch2_s2_5.lua
-- @brief  kpfs.image + disk.mkpt + probe.part (2.2.5)
-- @note   须 libkpfs 插件
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local common = require("lua_test.pfs.make.common")
local report = require("lua_test.report")

local M = {}

local TAG = "mkpt"


function M.run(...)

	if common.require_kpfs() == nil then
		return
	end

	local image = require("kpfs.image")
	local disk = require("kpfs.disk")
	local probe = require("kpfs.probe")

	local work, err = common.setup_work("2.2.5")
	if work == nil then
		common.fail(TAG, err)
		return
	end

	local image_path = paths.join(work, "mkpt.vhdx")
	local size_str = common.dynamic_size_str()

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

	local info, rc2, msg2 = probe.part(image_path)
	if rc2 ~= 0 then
		common.fail(TAG, "probe.part rc=" .. tostring(rc2) .. " " .. tostring(msg2))
		return
	end

	if info.scheme ~= "gpt" then
		common.fail(TAG, "scheme=" .. tostring(info.scheme))
		return
	end

	local part_count = info.part_count or 0
	if part_count < 1 then
		common.fail(TAG, "part_count=" .. tostring(part_count))
		return
	end

	local parts = info.parts or {}
	for i, part in ipairs(parts) do
		if part.fs_type ~= nil or part.mount_ok ~= nil or part.mount_err ~= nil then
			common.fail(TAG, "parts[" .. tostring(i) .. "] has FS fields")
			return
		end
	end

	print("  probe scheme:", info.scheme)
	print("  probe part_count:", part_count)

	common.pass()
end

return M
