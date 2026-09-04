--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   path/ch2_s5_5.lua
-- @brief  copy ����<->�� @ ·�� (2.5.5)
-- @history �޸���ʷ
--  \n 2026 �����ļ�
--]]


local paths = require("lua_test.paths")
local mount_common = require("lua_test.pfs.mount.common")

local M = {}
local TAG = "copy_host"


function M.run(...)

	if mount_common.require_kpfs() == nil then
		return
	end

	local vfs = require("kpfs.vfs")

	local slot, image_path, err = mount_common.setup_mounted_rw("2.5.5")
	if slot == nil then
		mount_common.fail(TAG, err)
		return
	end

	local local_bin = paths.join(work, "local.bin")
	local local_out = paths.join(work, "local_out.bin")
	local payload = string.rep("H", 128)

	local fh = io.open(local_bin, "wb")
	if fh == nil then
		mount_common.fail(TAG, "create local.bin")
		return
	end

	fh:write(payload)
	fh:close()

	local vol_path = mount_common.vfs_path(1, "/kpfs_lt_host.bin")
	local rc, msg = vfs.copy("@." .. local_bin, vol_path)
	if rc ~= 0 then
		rc, msg = vfs.copy("@" .. local_bin, vol_path)
	end
	if rc ~= 0 then
		mount_common.fail(TAG, "host->vol rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	rc, msg = vfs.copy(vol_path, "@." .. local_out)
	if rc ~= 0 then
		rc, msg = vfs.copy(vol_path, "@" .. local_out)
	end
	if rc ~= 0 then
		mount_common.fail(TAG, "vol->host rc=" .. tostring(rc))
		return
	end

	local fh2 = io.open(local_out, "rb")
	if fh2 == nil then
		mount_common.fail(TAG, "open local_out")
		return
	end

	local out_data = fh2:read("*a")
	fh2:close()

	if out_data ~= payload then
		mount_common.fail(TAG, "host roundtrip mismatch")
		return
	end

	rc, msg = mount_common.vfs_umount()
	if rc ~= 0 then
		mount_common.fail(TAG, "umount rc=" .. tostring(rc))
		return
	end

	mount_common.pass(TAG)
end

return M
