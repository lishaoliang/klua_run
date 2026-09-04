--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   probe/ch2_s1_2.lua
-- @brief  kpfs.image + kpfs.probe 烟测 (小 vhdx)
-- @note   须 libkpfs 插件; arm64 镜像不超过 paths.max_image_bytes()
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local fsutil = require("lua_test.util.fsutil")
local common = require("lua_test.pfs.make.common")
local report = require("lua_test.report")

local M = {}

local TAG = "probe"


function M.run(...)
	if common.require_kpfs() == nil then
		return
	end

	local image = require("kpfs.image")
	local probe = require("kpfs.probe")

	local work = paths.case_dir("2.1.2")
	local ok_dir, err_dir = fsutil.ensure_dir(work)
	if not ok_dir then
		common.fail(TAG, "mkdir " .. tostring(err_dir))
		return
	end

	local image_path = paths.join(work, "tiny.vhdx")
	local size_mb = 4
	if paths.is_arm64_target() then
		size_mb = 2
	end
	local size_str = tostring(size_mb) .. "M"

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

	local info, rc2, msg2 = probe.all(image_path)
	if rc2 ~= 0 or info == nil or info.container == nil then
		common.fail(TAG, "probe.all rc=" .. tostring(rc2) .. " " .. tostring(msg2))
		return
	end

	print("  probe container:", info.container or "?")
	print("  probe parts:", #(info.parts or {}))
	common.pass()
end

return M
