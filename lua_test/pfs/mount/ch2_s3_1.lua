--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_1.lua
-- @brief  kpfs.mount / umount 烟测 (2.3.1)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "mount"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local work, err = mount_common.setup_work("2.3.1")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.prepare_gpt_exfat(work, "mount.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	print("  work:", work)
	print("  image:", image_path)

	local rc, msg = mount_common.mount(image_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rc=" .. tostring(rc) .. " " .. tostring(msg))
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
