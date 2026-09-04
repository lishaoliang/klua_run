--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mount/common.lua
-- @brief  kpfs mount/vfs 用例公共辅助 (2.3-2.5)
-- @note   约定 **klua-test-design**; 2.4/2.5 vfs 走固定盘 M/N/P (**test_disk**); 2.3 mount 烟测仍用 case_dir 盘符 T
-- @history 修改历史
--  \n 2026 创建文件
--]]


local kco = require("kco")
local ksys = require("ksys")
local paths = require("lua_test.paths")
local fsutil = require("lua_test.util.fsutil")
local common = require("lua_test.pfs.make.common")
local test_disk = require("lua_test.pfs.test_disk")
local report = require("lua_test.report")

local M = {}

M.DRIVE = "T"

--- 2.4/2.5 默认固定盘: M1: (GPTx4)
M.VFS_SLOT = "M"
M.VFS_PART = 1

--- 跨分区 path 用例 (2.5.6/2.5.9): N1:/N2: (MBRx2)
M.VFS_DUAL_SLOT = "N"
M.VFS_DUAL_PARTS = 2

--- 与固定盘 N 同布局 (MBRx2), 仅作临时双分区用例参考; **非**固定盘槽位
M.LAYOUT_MBR_DUAL_PARTS = 2

--- 当前 vfs/path 用例挂载上下文 (slot + 默认分区)
M._vfs_ctx = nil


function M.is_single_run()
	return os.getenv("LUA_TEST_NO_ENVINFO") ~= "1"
end


function M.print_mount_info_diag()
	if not M.is_single_run() then
		return
	end

	local ok, kpfs = pcall(require, "kpfs")
	if not ok then
		return
	end

	local slot = M.vfs_slot()
	local name = M.slot_drive(slot)
	local info, rc, msg = kpfs.mount_info(name)

	print("  mount_info (" .. tostring(name) .. "):")
	if rc ~= 0 then
		print("    rc=" .. tostring(rc) .. " " .. tostring(msg))
		return
	end

	print("    path:", tostring(info.path))
	print("    container:", tostring(info.container), "scheme:", tostring(info.scheme),
		"part_count:", tostring(info.part_count))

	for i, part in ipairs(info.parts or {}) do
		print("    part", tostring(part.index or i),
			"mounted=" .. tostring(part.mounted),
			"mode=" .. tostring(part.mode),
			"fs=" .. tostring(part.fs_type),
			"mount_err=" .. tostring(part.mount_err),
			"offset=" .. tostring(part.part_offset))
	end
end


function M.fail(tag, msg)
	report.fail(msg)
	if M._vfs_ctx ~= nil then
		M.print_mount_info_diag()
		M.vfs_umount()
		M.vfs_clear()
	end
	ksys.exit(1)
end


function M.pass(tag)
	kco.timeout(100, function ()
		report.pass()
		ksys.exit(0)
	end)
end


function M.require_kpfs()
	return common.require_kpfs()
end


function M.is_userdata(v)
	return type(v) == "userdata" or (type(v) == "table" and getmetatable(v) ~= nil)
end


function M.setup_work(doc_id)
	return common.setup_work(doc_id)
end


function M.drive_path(part_index, rel)
	part_index = part_index or 1
	rel = rel or ""
	if rel:sub(1, 1) ~= "/" then
		rel = "/" .. rel
	end
	return M.DRIVE .. tostring(part_index) .. ":" .. rel
end


function M.vfs_begin(slot, part_index)
	M._vfs_ctx = {
		slot = slot or M.VFS_SLOT,
		part = part_index or M.VFS_PART,
	}
end


function M.vfs_clear()
	M._vfs_ctx = nil
end


--- 2.4/2.5 盘符路径; 须先 vfs_begin / setup_mounted_rw*
function M.vfs_path(part_index, rel)
	local slot = M.VFS_SLOT
	local part = part_index or M.VFS_PART

	if M._vfs_ctx ~= nil then
		slot = M._vfs_ctx.slot
		if part_index == nil then
			part = M._vfs_ctx.part
		end
	end

	return M.slot_path(slot, part, rel)
end


function M.vfs_slot()
	if M._vfs_ctx ~= nil then
		return M._vfs_ctx.slot
	end
	return M.VFS_SLOT
end


function M.vfs_mount(image_path, mode, opts)
	return M.mount_slot(M.vfs_slot(), image_path, mode, opts)
end


function M.vfs_umount(part_index)
	return M.umount_slot(M.vfs_slot(), part_index)
end


function M.slot_path(slot, part_index, rel)
	rel = rel or ""
	if rel:sub(1, 1) ~= "/" then
		rel = "/" .. rel
	end
	return test_disk.drive_prefix(slot, part_index) .. rel
end


function M.slot_drive(slot)
	return test_disk.drive_name(slot)
end


function M.create_vhdx(work, name, size_str)
	local image = require("kpfs.image")
	local image_path = paths.join(work, name)

	local rc, msg = image.create(image_path, {
		type = "vhdx",
		size = size_str,
		layout = "dynamic",
	})
	if rc ~= 0 then
		return nil, "image.create rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	return image_path
end


function M.mkpt_gpt_exfat(image_path)
	local disk = require("kpfs.disk")

	local rc, msg = disk.mkpt(image_path, {
		scheme = "gpt",
		fs = "exfat",
	})
	if rc ~= 0 then
		return false, "disk.mkpt rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	return true
end


function M.mkfs_exfat(image_path)
	local disk = require("kpfs.disk")

	local rc, msg = disk.mkfs(image_path, {
		fs = "exfat",
	})
	if rc ~= 0 then
		return false, "disk.mkfs rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	return true
end


function M.prepare_gpt_exfat(work, image_name, size_str)
	size_str = size_str or common.exfat_disk_size_str()
	local image_path, err = M.create_vhdx(work, image_name, size_str)
	if image_path == nil then
		return nil, err
	end

	local ok, err_mkpt = M.mkpt_gpt_exfat(image_path)
	if not ok then
		return nil, err_mkpt
	end

	ok, err_mkpt = M.mkfs_exfat(image_path)
	if not ok then
		return nil, err_mkpt
	end

	return image_path
end


--- case_dir 临时盘: MBRx2 + 双分区 exfat (破坏性; 盘符 T1/T2)
function M.prepare_temp_mbr_dual_exfat(work, image_name, size_str)
	size_str = size_str or common.exfat_disk_size_str()
	image_name = image_name or "dual_mbr.vhdx"

	local image_path, err = M.create_vhdx(work, image_name, size_str)
	if image_path == nil then
		return nil, err
	end

	local disk = require("kpfs.disk")

	local rc, msg = disk.mkpt(image_path, {
		scheme = "mbr",
		{ fs = "exfat" },
		{ fs = "exfat" },
	})
	if rc ~= 0 then
		return nil, "disk.mkpt rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	rc, msg = disk.mkfs(image_path, {
		{ fs = "exfat" },
		{ fs = "exfat" },
	})
	if rc ~= 0 then
		return nil, "disk.mkfs rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	print("  temp mbrx2 image:", image_path)
	return image_path
end


--- 固定盘槽位 probe 通过 (只读)
function M._print_fixed_slot_probe(slot, image_path, scheme, fs_type)
	report.print_disk_slot_probe(slot, image_path, scheme, fs_type)
end


--- 固定盘 M/N/P: probe 前 count 个分区是否已格式化 (只读, 不写盘)
function M.probe_slot_parts_fs(slot, count, fs_type)
	fs_type = fs_type or "exfat"
	local image_path = test_disk.disk_path(slot)
	if image_path == nil then
		return false, "no disk path for slot " .. tostring(slot)
	end

	local probe = require("kpfs.probe")
	local info, rc, msg = probe.all(image_path)
	if rc ~= 0 then
		return false, "probe.all slot " .. tostring(slot) .. " rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	local parts = info.parts or {}
	for i = 1, count do
		local part = parts[i]
		if not common.part_formatted(part, fs_type) then
			return false, nil
		end
	end

	return true, info
end


--- 固定盘前置: 镜像存在 + 分区表布局符合 SLOT_LAYOUT
function M.require_test_disk_slot(slot, opts)
	opts = opts or {}
	local min_parts = opts.min_parts or test_disk.part_count(slot)

	local ok, err = test_disk.check_partition_layout(slot, min_parts)
	if not ok then
		return false, err
	end

	return true, test_disk.disk_path(slot)
end


--- 固定盘前置: 布局 + 前 count 分区已格式化 (只读 probe; 不写盘)
function M.require_fixed_slot_formatted(slot, count, fs_type)
	fs_type = fs_type or "exfat"
	count = count or test_disk.part_count(slot)

	local ok_req, path_or_err = M.require_test_disk_slot(slot, { min_parts = count })
	if not ok_req then
		return false, path_or_err
	end

	local ok_fs, info = M.probe_slot_parts_fs(slot, count, fs_type)
	if not ok_fs then
		return false, "slot " .. tostring(slot) .. " partition(s) not formatted with "
			.. tostring(fs_type) .. " (prepare via test_disk setup outside lua test)"
	end

	M._print_fixed_slot_probe(slot, path_or_err, test_disk.scheme(slot), fs_type)
	return true, path_or_err, info
end


--- 固定盘: 前 count 分区须为 exfat; 未格式化则 mkfs (破坏性, 仅 vfs/path 节)
function M.ensure_slot_parts_exfat(slot, count)
	count = count or 1

	local ok_req, image_path = M.require_test_disk_slot(slot, { min_parts = count })
	if not ok_req then
		return false, nil, image_path
	end

	local ok_fs = M.probe_slot_parts_fs(slot, count, "exfat")
	if ok_fs then
		report.print_disk_slot_formatted(slot, image_path, "exfat", count)
		return true, image_path
	end

	local disk = require("kpfs.disk")
	local mkfs_opts = {}
	for i = 1, count do
		mkfs_opts[i] = { fs = "exfat" }
	end

	local rc, msg = disk.mkfs(image_path, mkfs_opts)
	if rc ~= 0 then
		return false, nil, "disk.mkfs slot " .. tostring(slot) .. " rc=" .. tostring(rc)
			.. " " .. tostring(msg)
	end

	report.print_disk_slot_formatted(slot, image_path, "exfat", count)
	return true, image_path
end


function M.remount_slot(slot, mode)
	local kpfs = require("kpfs")
	return kpfs.remount(test_disk.drive_name(slot), mode)
end


function M.prepare_bare_exfat(work, image_name, size_str)
	size_str = size_str or common.exfat_disk_size_str()
	local image_path, err = M.create_vhdx(work, image_name, size_str)
	if image_path == nil then
		return nil, err
	end

	local disk = require("kpfs.disk")
	local tree = paths.join(work, "bare_tree")
	local ok_tree, err_tree = fsutil.ensure_dir(tree)
	if not ok_tree then
		return nil, "mkdir tree " .. tostring(err_tree)
	end

	local hello = paths.join(tree, "hello.txt")
	local fh, err_open = io.open(hello, "wb")
	if fh == nil then
		return nil, "open hello " .. tostring(err_open)
	end

	fh:write("bare exfat\n")
	fh:close()

	local rc, msg = disk.mkvol(image_path, {
		fs = "exfat",
		src = tree,
		label = "BARE",
	})
	if rc ~= 0 then
		return nil, "disk.mkvol bare rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	return image_path
end


function M.mount(image_path, mode, opts)
	local kpfs = require("kpfs")

	if opts ~= nil then
		local rc, msg = kpfs.mount(M.DRIVE, image_path, mode, opts)
		return rc, msg
	end

	if mode ~= nil then
		local rc, msg = kpfs.mount(M.DRIVE, image_path, mode)
		return rc, msg
	end

	local rc, msg = kpfs.mount(M.DRIVE, image_path)
	return rc, msg
end


function M.mount_slot(slot, image_path, mode, opts)
	local kpfs = require("kpfs")
	local name = test_disk.drive_name(slot)

	if opts ~= nil then
		return kpfs.mount(name, image_path, mode, opts)
	end

	if mode ~= nil then
		return kpfs.mount(name, image_path, mode)
	end

	return kpfs.mount(name, image_path)
end


function M.umount(part_index)
	local kpfs = require("kpfs")

	if part_index ~= nil then
		return kpfs.umount(M.DRIVE, part_index)
	end

	return kpfs.umount(M.DRIVE)
end


function M.umount_slot(slot, part_index)
	local kpfs = require("kpfs")
	local name = test_disk.drive_name(slot)

	if part_index ~= nil then
		return kpfs.umount(name, part_index)
	end

	return kpfs.umount(name)
end


function M.remount(mode)
	local kpfs = require("kpfs")
	return kpfs.remount(M.DRIVE, mode)
end


function M.remount_part(part_index, mode)
	return M.remount({ index = part_index, mode = mode })
end


function M.write_file(path, data, mode)
	local vfs = require("kpfs.vfs")
	mode = mode or "w"

	local f, msg = vfs.open(path, mode)
	if not M.is_userdata(f) then
		return false, "open failed: " .. tostring(path) .. " rc=" .. tostring(f)
			.. " " .. tostring(msg)
	end

	local nbytes, rc, msg = f:write(data)
	if rc ~= nil and rc ~= 0 then
		f:close()
		return false, "write rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	if nbytes == nil or nbytes < #data then
		f:close()
		return false, "short write"
	end

	f:close()
	return true
end


function M.read_file(path)
	local vfs = require("kpfs.vfs")

	local f, msg = vfs.open(path, "r")
	if not M.is_userdata(f) then
		return nil, "open failed: " .. tostring(path) .. " rc=" .. tostring(f)
			.. " " .. tostring(msg)
	end

	local chunks = {}
	local chunk = f:read(4096)

	while chunk ~= nil and chunk ~= "" do
		chunks[#chunks + 1] = chunk
		chunk = f:read(4096)
	end

	f:close()
	return table.concat(chunks)
end


function M.access_ok(path, mode)
	local vfs = require("kpfs.vfs")
	local rc, msg = vfs.access(path, mode or "f")
	return rc == 0, rc, msg
end


function M.ensure_preset_volume(work)
	local image_path = paths.join(work, "preset.vhdx")
	if fsutil.exists(image_path) then
		return image_path
	end

	local path, err = M.prepare_gpt_exfat(work, "preset.vhdx")
	if path == nil then
		return nil, err
	end

	return path
end


function M.setup_mounted_rw(doc_id, opts)
	opts = opts or {}
	local slot = opts.slot or M.VFS_SLOT
	local part = opts.part or M.VFS_PART

	local ok, image_path, err_prep = M.ensure_slot_parts_exfat(slot, part)
	if not ok then
		return nil, nil, err_prep
	end

	M.vfs_begin(slot, part)

	local rc, msg = M.mount_slot(slot, image_path, "rw")
	if rc ~= 0 then
		M.vfs_clear()
		return nil, nil, "mount rw rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	local vfs = require("kpfs.vfs")
	rc, msg = vfs.access(M.vfs_path(part, "/"), "f")
	if rc ~= 0 then
		M.umount_slot(slot)
		M.vfs_clear()
		return nil, nil, "vfs access " .. M.vfs_path(part, "/") .. " rc=" .. tostring(rc)
			.. " " .. tostring(msg)
	end

	return slot, image_path
end


--- 双分区跨区 path 用例 (2.5.6/2.5.9): 固定盘 N, mount N1+N2 RW
function M.setup_mounted_dual_rw(doc_id)
	local slot = M.VFS_DUAL_SLOT
	local count = M.VFS_DUAL_PARTS

	local ok, image_path, err_prep = M.ensure_slot_parts_exfat(slot, count)
	if not ok then
		return nil, nil, err_prep
	end

	M.vfs_begin(slot, 1)

	local rc, msg = M.mount_slot(slot, image_path, "rw")
	if rc ~= 0 then
		M.vfs_clear()
		return nil, nil, "mount rw rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	local vfs = require("kpfs.vfs")
	for i = 1, count do
		rc, msg = vfs.access(M.vfs_path(i, "/"), "f")
		if rc ~= 0 then
			M.umount_slot(slot)
			M.vfs_clear()
			return nil, nil, "vfs access " .. M.vfs_path(i, "/") .. " rc=" .. tostring(rc)
				.. " " .. tostring(msg)
		end
	end

	return slot, image_path
end

return M
