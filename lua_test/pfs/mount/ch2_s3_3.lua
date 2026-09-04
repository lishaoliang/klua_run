--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/ch2_s3_3.lua
-- @brief  只读挂载下写 (2.3.3)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "ro_write"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local work, err = mount_common.setup_work("2.3.3")
	if work == nil then
		mount_common.fail(TAG, err)
		return
	end

	local image_path, err_img = mount_common.prepare_gpt_exfat(work, "ro.vhdx")
	if image_path == nil then
		mount_common.fail(TAG, err_img)
		return
	end

	local rc, msg = mount_common.mount(image_path)
	if rc ~= 0 then
		mount_common.fail(TAG, "mount rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	local path = mount_common.drive_path(1, "/kpfs_lt_ro.txt")
	for _, mode in ipairs({ "w", "w+" }) do
		local f = vfs.open(path, mode)
		if mount_common.is_userdata(f) then
			f:close()
			mount_common.umount()
			mount_common.fail(TAG, "open " .. mode .. " succeeded on ro mount")
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
