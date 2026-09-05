--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   ui.lua
-- @brief  klbui UI 用例通用框架 (单条转 wlua 开窗)
-- @note   约定 **klua-test-design**; 模块 lua_test.klbui.ui
--  \n 单条无 wsdl 时 os.execute wlua 再跑同一 test.lua; 批量 worker 则 skip
--  \n 各用例页直接 parse; 页面元素只由页面文件写, 本模块不改 dialog child
--  \n 开窗后由本模块生效 pref (分辨率/语言/字体/外观); 页面可选 apply_pref / apply_lang / apply_theme
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 开窗前应用 pref font_size
--  \n 2026 relocation 后由本层调用 apply_pref
--  \n 2026 开窗前应用 appearance
--  \n 2026 开窗前应用 font_face (auto / 指定字库)
--  \n 2026 demores 皮肤 S000/S001/S002 + tmpimage 图
--  \n 2026 _rs 委托 pref.from_wh
--]]


local ksys = require("ksys")
local kenv = require("kenv")
local kos = require("kos")
local lfs = require("lfs")
local report = require("lua_test.report")
local common = require("lua_test.klbui.common")
local pref = require("lua_test.klbui.pref")
local theme = require("lua_test.klbui.theme")

local M = {}

M.DEFAULT_W = 1920
M.DEFAULT_H = 1080


local function _args()
	return { ksys.get_args() }
end


local function _join(base, rel)
	if base == nil or base == "" then
		return rel
	end

	local last = base:sub(-1)
	if last == "/" or last == "\\" then
		return base .. rel
	end

	return base .. "/" .. rel
end


local function _quote(s)
	s = tostring(s or "")
	if kos.os == "windows" then
		return '"' .. s:gsub('"', '\\"') .. '"'
	end

	return "'" .. s:gsub("'", "'\\''") .. "'"
end


-- @brief 是否已在 wlua (wsdl 预加载)
-- @return ok[boolean]
function M.has_wsdl()
	local ok, wsdl = pcall(require, "wsdl")
	if not ok then
		return false
	end

	if type(wsdl) ~= "table" then
		return false
	end

	return type(wsdl.open_wnd) == "function"
end


-- @brief 是否 lua test 主进程 CLI (args[2] 为 test.lua)
-- @return ok[boolean]
function M.is_main_cli()
	return common.is_single()
end


-- @brief 是否 batch kthread worker
-- @return ok[boolean]
function M.is_batch_worker()
	return common.is_batch_worker()
end


-- @brief 当前可执行旁的 wlua 路径
-- @return path[string]
function M.wlua_path()
	local base = kenv.base_path()
	if kos.os == "windows" then
		return _join(base, "wlua.exe")
	end

	return _join(base, "wlua")
end


-- @brief 保证 UI 宿主: 已有 wsdl 则 true; 否则单条转 wlua / 批量 skip
-- @return ready[boolean]
function M.ensure_host()
	if M.has_wsdl() then
		return true
	end

	if M.is_batch_worker() then
		common.skip("need wlua (batch)")
		return false
	end

	local args = _args()
	local prog = tostring(args[1] or "")
	if prog:lower():find("wlua", 1, true) then
		common.skip("wsdl not loaded")
		return false
	end

	if not M.is_main_cli() then
		common.skip("need wlua")
		return false
	end

	return M.relaunch_wlua()
end


-- @brief 用 wlua 再启动当前 test.lua 用例; 阻塞等待后按子进程码退出
-- @return ready[boolean] 仅失败未退出时 false
function M.relaunch_wlua()
	local path = M.wlua_path()
	if lfs.attributes(path, "mode") ~= "file" then
		common.skip("wlua not found: " .. path)
		return false
	end

	local args = _args()
	local parts = { _quote(path) }

	for i = 2, #args do
		parts[#parts + 1] = _quote(args[i])
	end

	local cmd = table.concat(parts, " ")
	if kos.os == "windows" then
		cmd = '"' .. cmd .. '"'
	end

	print("[lua_test ui] relaunch wlua")
	print("  " .. cmd)

	local ok, why, code = os.execute(cmd)
	if type(ok) ~= "boolean" then
		code = ok
		why = "exit"
	end

	if why ~= "exit" and why ~= nil then
		report.fail("wlua " .. tostring(why) .. " " .. tostring(code))
		ksys.exit(1)
		return false
	end

	code = tonumber(code) or (ok and 0 or 1)
	print("[lua_test ui] wlua exit=" .. tostring(code))

	if code ~= 0 then
		report.fail("wlua exit=" .. tostring(code))
		ksys.exit(code)
		return false
	end

	report.pass()
	ksys.exit(0)
	return false
end


local function _load_demores(opts, base, klbui)
	local uires = require("klbcore.klbui.uires")
	local demores = _join(base, "demores")
	local cfg = opts.pref or pref.load()

	if opts.load_font ~= false then
		if not pref.apply_font_face(klbui, cfg.font_face, base) then
			print("[lua_test ui] font not found under demores/font")
		end
	end

	theme.bind_images(uires, klbui, base)
	theme.apply_skin(uires, klbui, base, cfg.appearance, theme.font_tier(cfg.font_size))
	theme.apply_skin_css(uires)
	if opts.load_images ~= false then
		theme.apply_images(uires, klbui, base, cfg.appearance)
	end

	if opts.load_lang ~= false then
		uires.append_lang_search_dir(_join(demores, "language"))
		uires.load_language()
		pref.apply_lang(uires, cfg.language)
	end

	pref.apply_appearance(klbui, cfg.appearance)
	pref.apply_font(klbui, cfg.font_size)

	return uires
end


-- @brief 按窗口宽高映射分辨率档
-- @param [in] w[number]    窗口宽
-- @param [in] h[number]    [可选] 窗口高
-- @return rs[string]  见 pref.RS_ORDER
local function _rs(w, h)
	return pref.from_wh(w, h)
end


-- @brief 若页面有 relocation 则按分辨率装填 dialog/css
-- @param [in] page[table]
-- @param [in] rs[string]   见 pref.RS_ORDER
-- @return 无
local function _apply_page(page, rs)
	if type(page) ~= "table" then
		return
	end

	if type(page.relocation) == "function" then
		page.relocation(rs)
	end
end


-- @brief 生效配置到页面 (页面只同步本页控件)
-- @param [in] page[table]
-- @param [in] cfg[table]
-- @return 无
local function _apply_pref(page, cfg)
	if type(page) ~= "table" then
		return
	end

	if type(page.apply_pref) == "function" then
		page.apply_pref(cfg)
	end

	if type(page.apply_theme) == "function" then
		page.apply_theme(cfg.appearance)
	end
end


-- @brief 打开 SDL 窗并加载 demores
-- @param [in] opts[table] 见 run
-- @return ctx[table]; 失败 skip 后为 nil
function M.open(opts)
	opts = opts or {}

	local ok_wsdl, wsdl = pcall(require, "wsdl")
	if not ok_wsdl then
		common.skip("wsdl not loaded")
		return nil
	end

	local kgui, klbui = common.require_klbui()
	if kgui == nil then
		return nil
	end

	local cfg = opts.pref or pref.load()
	opts.pref = cfg
	if opts.load_images == nil then
		opts.load_images = pref.use_images(cfg.appearance)
	end
	local sz = pref.size(cfg.resolution)
	local w = opts.w or sz.w
	local h = opts.h or sz.h
	local title = opts.title or report.label()
	local base = wsdl.get_base_path()
	if type(base) ~= "string" or base == "" then
		base = kenv.base_path()
	end

	wsdl.open_wnd(w, h, title)

	local uires = _load_demores(opts, base, klbui)

	return {
		wsdl = wsdl,
		kgui = kgui,
		klbui = klbui,
		uires = uires,
		w = w,
		h = h,
		title = title,
		base = base,
		pref = cfg,
		pass = common.pass,
		fail = function (msg)
			common.fail("ui", msg)
		end,
		skip = common.skip,
	}
end


-- @brief 单条 UI 用例入口
-- @param [in] opts[table]
--   title[string]          [可选] 窗口标题; 默认 report.label
--   w[number]              [可选] 宽, 默认 pref 分辨率
--   h[number]              [可选] 高, 默认 pref 分辨率
--   load_font[boolean]     [可选] demores/font, 默认 true
--   load_images[boolean]   [可选] demores/images/tmpimage, 默认随外观
--   load_lang[boolean]     [可选] demores/language, 默认 true
--   page[table]            [必须] { dialog, commands, css [, relocation] }
-- @param [in] scene[function] [可选] function (ctx) 在 parse/modal 之后调用
-- @return 无
-- @note eg. ui.run({ page = { dialog = { ['type']='kview', ... } } })
--  \n page.relocation(rs) 在 parse 前调用, 用于装填 dialog/css
--  \n apply_pref / apply_lang / apply_theme 由本函数调用; 不改 dialog child
function M.run(opts, scene)
	opts = opts or {}

	if not M.ensure_host() then
		return
	end

	opts.pref = opts.pref or pref.load()
	local cfg = opts.pref
	if opts.w == nil and opts.h == nil then
		local sz = pref.size(cfg.resolution)
		opts.w = sz.w
		opts.h = sz.h
	end

	print("[lua_test ui] pref " .. pref.path())
	print("  resolution=" .. cfg.resolution .. " language=" .. cfg.language
		.. " font_size=" .. cfg.font_size .. " font_face=" .. cfg.font_face
		.. " appearance=" .. cfg.appearance)

	local ctx = M.open(opts)
	if ctx == nil then
		return
	end

	local rs = pref.norm_rs(cfg.resolution)
	local page = opts.page or {}
	opts.page = page
	_apply_page(page, rs)
	_apply_pref(page, cfg)

	if type(page.dialog) ~= "table" then
		common.fail("ui", "page.dialog required")
		return
	end

	page.commands = page.commands or {}
	page.css = page.css or {}

	page.jq = ctx.klbui.select(page.dialog)
	page.jq0 = ctx.klbui.select(page.dialog, true)

	ctx.root = page.dialog
	ctx.page = page
	ctx.jq = page.jq

	if type(page.apply_lang) == "function" then
		page.apply_lang(cfg.language)
	end

	ctx.klbui.parse(page.dialog, page.commands, page.css)

	_apply_pref(page, cfg)
	if type(page.apply_lang) == "function" then
		page.apply_lang(cfg.language)
	end

	-- wui 在 open_wnd/register 时已按默认 24 固化 globalcss; parse 后再落到控件
	pref.apply_appearance_live(ctx.klbui, page.jq0, cfg.appearance)
	pref.apply_font_live(ctx.klbui, page.jq0, cfg.font_size)

	local path = page.dialog.path or page.dialog.name
	if type(path) == "string" and path ~= "" then
		ctx.klbui.modal(path)
	end

	if type(scene) == "function" then
		scene(ctx)
	end
end

return M
