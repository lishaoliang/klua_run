--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   make/ch2_s2_2.lua
-- @brief  kpfs.image.create dynamic vhd + image.info (2.2.2)
-- @note   须 libkpfs 插件
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local common = require("lua_test.pfs.make.common")
local report = require("lua_test.report")

local M = {}

local TAG = "image.vhd"


function M.run(...)

	if common.require_kpfs() == nil then
		return
	end

	local image = require("kpfs.image")

	local work, err = common.setup_work("2.2.2")
	if work == nil then
		common.fail(TAG, err)
		return
	end

	local image_path = paths.join(work, "dyn.vhd")
	local size_str = common.dynamic_size_str()

	report.print_disk_path(image_path)
	print("  size:", size_str)

	local rc, msg = image.create(image_path, {
		type = "vhd",
		size = size_str,
		layout = "dynamic",
	})
	if rc ~= 0 then
		common.fail(TAG, "image.create rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local info, rc2, msg2 = image.info(image_path)
	if rc2 ~= 0 then
		common.fail(TAG, "image.info rc=" .. tostring(rc2) .. " " .. tostring(msg2))
		return
	end

	if info.container ~= "vhd" then
		common.fail(TAG, "container=" .. tostring(info.container))
		return
	end

	print("  info container:", info.container)

	common.pass()
end

return M
