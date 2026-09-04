--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   probe/ch2_s1_4.lua
-- @brief  kpfs.image + disk.mkpt/mkfs + kpfs.probe.fs 烟测
-- @note   须 libkpfs 插件; arm64 镜像不超过 paths.max_image_bytes()
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local fsutil = require("lua_test.util.fsutil")
local common = require("lua_test.pfs.make.common")
local report = require("lua_test.report")

local M = {}

local TAG = "probe.fs"


local function _image_size_str()
	local size_mb = 4
	if paths.is_arm64_target() then
		size_mb = 2
	end
	return tostring(size_mb) .. "M"
end


function M.run(...)
	if common.require_kpfs() == nil then
		return
	end

	local image = require("kpfs.image")
	local disk = require("kpfs.disk")
	local probe = require("kpfs.probe")

	local work = paths.case_dir("2.1.4")
	local ok_dir, err_dir = fsutil.ensure_dir(work)
	if not ok_dir then
		common.fail(TAG, "mkdir " .. tostring(err_dir))
		return
	end

	local image_path = paths.join(work, "fs.vhdx")
	local size_str = _image_size_str()

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
		fs = "fat32",
	})
	if rc ~= 0 then
		common.fail(TAG, "disk.mkpt rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = disk.mkfs(image_path, {
		fs = "fat32",
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

	local mount_ok = false
	local part_count = info.part_count or 0

	if part_count > 0 then
		local part = (info.parts or {})[1]
		if part ~= nil and part.mount_ok == true then
			mount_ok = true
		end
	else
		local bare = info.bare_fs
		if bare ~= nil and bare.mount_ok == true then
			mount_ok = true
		end
	end

	if not mount_ok then
		common.fail(TAG, "mount_ok is not true")
		return
	end

	print("  probe part_count:", part_count)
	print("  probe mount_ok: true")
	common.pass()
end

return M
