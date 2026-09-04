--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_11.lua
-- @brief  mount 后 probe.all 对照 (2.3.11)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "mount_probe"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local probe = require("kpfs.probe")

	local work, err = mount_common.setup_work("2.3.11")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.prepare_gpt_exfat(work, "probe.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local rc, msg = mount_common.mount(image_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local info, rc2, msg2 = probe.all(image_path)
	if info == nil then
		mount_common.fail(TAG, "probe.all rc=" .. tostring(rc2) .. " " .. tostring(msg2))
		return
	end

	local part = (info.parts or {})[1]
	if part == nil or part.mount_ok ~= true then
		mount_common.fail(TAG, "parts[1].mount_ok not true")
		return
	end

	if part.fs_type ~= nil and part.fs_type:lower() ~= "exfat" then
		mount_common.fail(TAG, "fs_type=" .. tostring(part.fs_type))
		return
	end

	rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	mount_common.pass(TAG)
end

return M
