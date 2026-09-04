--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_10.lua
-- @brief  重复 mount 同盘名 (2.3.10)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "mount_eexist"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local kpfs = require("kpfs")

	local work, err = mount_common.setup_work("2.3.10")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_a, err_a = mount_common.prepare_gpt_exfat(work, "a.vhdx")
	local image_b, err_b = mount_common.prepare_gpt_exfat(work, "b.vhdx")
	if image_a == nil or image_b == nil then
		mount_common.fail(TAG, tostring(err_a) .. " " .. tostring(err_b))
		return
	end

	local rc, msg = kpfs.mount(mount_common.DRIVE, image_a)
	if rc ~= 0 then
		mount_common.fail(TAG, "first mount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = kpfs.mount(mount_common.DRIVE, image_b)
	if rc == 0 then
		mount_common.fail(TAG, "second mount should fail")
		return
	end

	print("  second mount rc=" .. tostring(rc) .. " " .. tostring(msg))

	local data = mount_common.read_file(mount_common.drive_path(1, "/"))
	if data == nil then
		-- root access may fail; try list via access
		local ok = mount_common.access_ok(mount_common.drive_path(1, "/"), "f")
		if not ok then
			mount_common.fail(TAG, "original mount broken")
			return
		end
	end

	rc, msg = mount_common.umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	mount_common.pass(TAG)
end

return M
