--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_5.lua
-- @brief  显式 rw mount (2.3.5)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "mount_rw"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local work, err = mount_common.setup_work("2.3.5")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.prepare_gpt_exfat(work, "rw.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local rc, msg = mount_common.mount(image_path, "rw")
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rw rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok, err_w = mount_common.write_file(mount_common.drive_path(1, "/kpfs_lt_rw.txt"), "Z")
	if not ok then
		mount_common.fail(TAG, err_w)
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
