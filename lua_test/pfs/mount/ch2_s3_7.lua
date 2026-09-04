--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_7.lua
-- @brief  mount opts offset / sector_size (2.3.7)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "mount_opts"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local work, err = mount_common.setup_work("2.3.7")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.prepare_bare_exfat(work, "bare.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local rc, msg = mount_common.mount(image_path, { offset = 0 })
	if rc ~= 0 then
		mount_common.fail(TAG, "mount offset rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local ok = mount_common.access_ok(mount_common.drive_path(1, "/"), "f")
	if not ok then
		mount_common.fail(TAG, "access failed after offset mount")
		return
	end

	rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = mount_common.mount(image_path, "r", { sector_size = 512 })
	if rc ~= 0 then
		mount_common.fail(TAG, "mount sector_size rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	ok = mount_common.access_ok(mount_common.drive_path(1, "/hello.txt"), "f")
	if not ok then
		mount_common.fail(TAG, "access hello failed")
		return
	end

	rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount2 rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	mount_common.pass(TAG)
end

return M
