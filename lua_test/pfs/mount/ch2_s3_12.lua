--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_12.lua
-- @brief  损坏卷 mount 失败 (2.3.12, SINGLE_ONLY)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local paths = require("lua_test.paths")
local mount_common = require("lua_test.pfs.mount.common")
local common = require("lua_test.pfs.make.common")

local M = {}
local TAG = "bad_vol"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local work, err = mount_common.setup_work("2.3.12")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.create_vhdx(work, "bad.vhdx", common.dynamic_size_str())
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local fh = io.open(image_path, "r+b")
	if fh == nil then
		mount_common.fail(TAG, "open bad image")
		return
	end

	fh:write(string.rep("\0", 4096))
	fh:close()

	local rc, msg = mount_common.mount(image_path)
	if rc == 0 then
		mount_common.umount()
		mount_common.fail(TAG, "mount should fail on bad volume")
		return
	end

	print("  mount failed as expected rc=" .. tostring(rc) .. " " .. tostring(msg))
	mount_common.pass(TAG)
end

return M
