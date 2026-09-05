--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   custom/ch1_s1_1.lua
-- @brief  1.1.1 UI 分辨率 / 语言 / 字体 / 外观
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 本页满窗 parse; 元素只写本文件; 开窗由 lua_test.klbui.ui.run
--  \n 配置 lua_test.klbui.pref (klbui.json)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local klbui = require("klbcore.klbui")
local lang = require("klbcore.klbui.uires.lang")
local pref = require("lua_test.klbui.pref")

local M = {}

local jq = function () end
local jq0 = function () end


-----------------------------------------------------------------------------------
-- css

local css_720p = {
	['type'] = {
	}
}


-----------------------------------------------------------------------------------
-- dialog

local dialog_720p = {
	['type'] = 'kview',
	['pos'] = {0, 0, -1, -1},
	['name'] = 'page',

	['child'] = {
		{
			['type'] = 'kstatic',
			['pos'] = {16, 16, 1240, 32},
			['title'] = lang.str("HintSelectResLang"),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 64, 200, 32},
			['title'] = lang.str("Resolution"),
			['name'] = 'lab_rs',
		},
		{
			['type'] = 'kcombo',
			['pos'] = {224, 64, 240, 32},
			['name'] = 'cmb_rs',
			['title'] = pref.rs_title(pref.DEFAULT_RS),
			['value'] = pref.DEFAULT_RS,
			['append'] = pref.rs_append(),
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 112, 200, 32},
			['title'] = lang.str("Language"),
			['name'] = 'lab_lang',
		},
		{
			['type'] = 'kcombo',
			['pos'] = {224, 112, 240, 32},
			['name'] = 'cmb_lang',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 160, 200, 32},
			['title'] = lang.str("FontSize"),
			['name'] = 'lab_font',
		},
		{
			['type'] = 'kcombo',
			['pos'] = {224, 160, 240, 32},
			['name'] = 'cmb_font',
			['title'] = pref.font_title("24"),
			['value'] = '24',
			['append'] = pref.font_append(),
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 208, 200, 32},
			['title'] = lang.str("FontFace"),
			['name'] = 'lab_font_face',
		},
		{
			['type'] = 'kcombo',
			['pos'] = {224, 208, 280, 32},
			['name'] = 'cmb_font_face',
			['title'] = pref.font_face_title("auto"),
			['value'] = 'auto',
			['append'] = pref.font_face_append(),
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 256, 200, 32},
			['title'] = lang.str("Appearance"),
			['name'] = 'lab_appearance',
		},
		{
			['type'] = 'kcombo',
			['pos'] = {224, 256, 280, 32},
			['name'] = 'cmb_appearance',
			['title'] = pref.appearance_title("dark"),
			['value'] = 'dark',
			['append'] = pref.appearance_append(),
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 312, 1240, 48},
			['title'] = '',
			['name'] = 'lab_path',
		},
	}
}


-----------------------------------------------------------------------------------
-- helpers

local function _set_child(dialog, name, key, val)
	local child = dialog and dialog.child
	if type(child) ~= "table" then
		return
	end

	for i = 1, #child do
		local n = child[i]
		if type(n) == "table" and n.name == name then
			n[key] = val
			return
		end
	end
end


local function _set_pos(name, x, y, w, h)
	_set_child(M.dialog, name, "pos", {x, y, w, h})
end


-- @brief 取当前画布宽高; 未开窗则用分辨率档
-- @param [in] rs[string]
-- @return w[number], h[number]
local function _wnd_wh(rs)
	local sz = pref.size(rs)
	local w = sz.w
	local h = sz.h
	local ok, kgui = pcall(require, "kgui")
	if not ok or type(kgui) ~= "table" or type(kgui.wh) ~= "function" then
		return w, h
	end

	local gw, gh = kgui.wh()
	if type(gw) == "number" and 0 < gw then
		w = gw
	end

	if type(gh) == "number" and 0 < gh then
		h = gh
	end

	return w, h
end


-- @brief 将分辨率/语言/字体/外观相对窗口居中
-- @param [in] w[number]
-- @param [in] h[number]
-- @return 无
-- @note 小屏上大窗若被系统居中, 左上角控件会落到屏外; 居中后仍可点到下拉
local function _layout_center(w, h)
	w = tonumber(w) or 0
	h = tonumber(h) or 0
	if w < 1 then
		w = 1280
	end

	if h < 1 then
		h = 720
	end

	local pad = 16
	local lab_w = 220
	local cmb_w = 280
	local gap_x = 16
	local row_h = 32
	local row_gap = 16
	local hint_h = 32
	local path_h = 48
	local path_gap = 24
	local form_w = lab_w + gap_x + cmb_w
	local form_h = hint_h + row_gap + (5 * row_h) + (4 * row_gap) + path_gap + path_h
	local avail = w - (2 * pad)
	local path_w = form_w
	local block_w = form_w

	if avail < 1 then
		avail = w
	end

	if form_w < avail then
		path_w = avail
		if 960 < path_w then
			path_w = 960
		end
	else
		path_w = avail
		if path_w < 1 then
			path_w = form_w
		end
	end

	if path_w < form_w then
		block_w = form_w
	else
		block_w = path_w
	end

	local x0 = math.floor((w - block_w) / 2)
	local y0 = math.floor((h - form_h) / 2)
	if x0 < pad then
		x0 = pad
	end

	if y0 < pad then
		y0 = pad
	end

	local form_x = x0 + math.floor((block_w - form_w) / 2)
	local path_x = x0 + math.floor((block_w - path_w) / 2)
	local y = y0

	_set_pos("hint", path_x, y, path_w, hint_h)
	y = y + hint_h + row_gap

	_set_pos("lab_rs", form_x, y, lab_w, row_h)
	_set_pos("cmb_rs", form_x + lab_w + gap_x, y, cmb_w, row_h)
	y = y + row_h + row_gap

	_set_pos("lab_lang", form_x, y, lab_w, row_h)
	_set_pos("cmb_lang", form_x + lab_w + gap_x, y, cmb_w, row_h)
	y = y + row_h + row_gap

	_set_pos("lab_font", form_x, y, lab_w, row_h)
	_set_pos("cmb_font", form_x + lab_w + gap_x, y, cmb_w, row_h)
	y = y + row_h + row_gap

	_set_pos("lab_font_face", form_x, y, lab_w, row_h)
	_set_pos("cmb_font_face", form_x + lab_w + gap_x, y, cmb_w, row_h)
	y = y + row_h + row_gap

	_set_pos("lab_appearance", form_x, y, lab_w, row_h)
	_set_pos("cmb_appearance", form_x + lab_w + gap_x, y, cmb_w, row_h)
	y = y + row_h + path_gap

	_set_pos("lab_path", path_x, y, path_w, path_h)
end


local function _set_title(name, title)
	_set_child(M.dialog, name, "title", title)
	if type(M.jq) == "function" then
		pcall(function ()
			M.jq(name).set("title", title)
		end)
	end
end


local function _set_field(name, key, val)
	_set_child(M.dialog, name, key, val)
	if type(M.jq) == "function" then
		pcall(function ()
			M.jq(name).set(key, val)
		end)
	end
end


local function _fill_font_face()
	if type(jq) ~= "function" then
		return
	end

	pcall(function ()
		jq("cmb_font_face").set("clear", true)
		jq("cmb_font_face").append(pref.font_face_append())

		local cfg = pref.load()
		local name = pref.norm_font_face(cfg.font_face)
		jq("cmb_font_face").value(name)
		jq("cmb_font_face").set("title", pref.font_face_title(name))
	end)
end


local function _fill_appearance()
	if type(jq) ~= "function" then
		return
	end

	pcall(function ()
		jq("cmb_appearance").set("clear", true)
		jq("cmb_appearance").append(pref.appearance_append())

		local cfg = pref.load()
		local name = pref.norm_appearance(cfg.appearance)
		jq("cmb_appearance").value(name)
		jq("cmb_appearance").set("title", pref.appearance_title(name))
	end)
end


-- @brief 按语言更新本页文案
-- @param [in] code[string]
-- @return 无
function M.apply_lang(code)
	if type(code) == "string" and code ~= "" then
		lang.apply(pref.norm_lang(code))
	end

	_set_title("hint", lang.str("HintSelectResLang"))
	_set_title("lab_rs", lang.str("Resolution"))
	_set_title("lab_lang", lang.str("Language"))
	_set_title("lab_font", lang.str("FontSize"))
	_set_title("lab_font_face", lang.str("FontFace"))
	_set_title("lab_appearance", lang.str("Appearance"))
	_set_title("lab_path", lang.str("Config") .. ": " .. pref.path())
	_fill_font_face()
	_fill_appearance()
end


-- @brief 按配置同步本页下拉 (由 ui.run 调用)
-- @param [in] cfg[table]
-- @return 无
function M.apply_pref(cfg)
	if type(cfg) ~= "table" then
		cfg = pref.load()
	end

	local rs = pref.norm_rs(cfg.resolution)
	_set_field("cmb_rs", "value", rs)
	_set_field("cmb_rs", "title", pref.rs_title(rs))

	local font = pref.norm_font(cfg.font_size)
	_set_field("cmb_font", "value", font)
	_set_field("cmb_font", "title", pref.font_title(font))

	local font_face = pref.norm_font_face(cfg.font_face)
	_set_field("cmb_font_face", "value", font_face)
	_set_field("cmb_font_face", "title", pref.font_face_title(font_face))

	local appearance = pref.norm_appearance(cfg.appearance)
	_set_field("cmb_appearance", "value", appearance)
	_set_field("cmb_appearance", "title", pref.appearance_title(appearance))
end


local function _fill_lang()
	local key, name, list = lang.supports()
	if type(list) ~= "table" then
		list = {}
	end

	jq("cmb_lang").set("clear", true)
	jq("cmb_lang").append(list)

	if type(key) ~= "string" or key == "" then
		return
	end

	jq("cmb_lang").value(key)
	if type(name) == "string" and name ~= "" then
		jq("cmb_lang").set("title", name)
	end
end


local function _onload()
	_fill_lang()
	_fill_font_face()
	_fill_appearance()
end


local function _save_rs()
	local cfg = pref.load()
	local v = jq("cmb_rs").value()
	cfg.resolution = v
	pref.save(cfg)
	print("[lua_test pref] resolution=" .. cfg.resolution)
	_set_title("hint", lang.str("HintSaved"))
end


local function _save_lang()
	local cfg = pref.load()
	local v = jq("cmb_lang").value()
	cfg.language = v
	pref.save(cfg)

	local uires = require("klbcore.klbui.uires")
	pref.apply_lang(uires, cfg.language)
	M.apply_lang(cfg.language)
	_set_title("hint", lang.str("HintSaved"))
	print("[lua_test pref] language=" .. cfg.language)
end


local function _save_font()
	local cfg = pref.load()
	local v = jq("cmb_font").value()
	cfg.font_size = v
	pref.save(cfg)
	pref.apply_font_live(klbui, M.jq0, cfg.font_size)
	_set_title("hint", lang.str("HintSaved"))
	print("[lua_test pref] font_size=" .. cfg.font_size)
end


local function _save_font_face()
	local cfg = pref.load()
	local v = jq("cmb_font_face").value()
	cfg.font_face = v
	pref.save(cfg)
	pref.apply_font_face_live(klbui, cfg.font_face)
	pref.apply_font_live(klbui, M.jq0, cfg.font_size)
	_set_title("hint", lang.str("HintSaved"))
	print("[lua_test pref] font_face=" .. cfg.font_face)
end


local function _save_appearance()
	local cfg = pref.load()
	local v = jq("cmb_appearance").value()
	cfg.appearance = v
	pref.save(cfg)
	pref.apply_appearance_live(klbui, M.jq0, cfg.appearance)
	pref.apply_font_live(klbui, M.jq0, cfg.font_size)
	_set_title("hint", lang.str("HintSaved"))
	print("[lua_test pref] appearance=" .. cfg.appearance)
end


-----------------------------------------------------------------------------------
-- commands

M.commands = {
	['page'] = {
		['onload'] = _onload,
	},
	['cmb_rs'] = {
		['onchange'] = _save_rs,
	},
	['cmb_lang'] = {
		['onchange'] = _save_lang,
	},
	['cmb_font'] = {
		['onchange'] = _save_font,
	},
	['cmb_font_face'] = {
		['onchange'] = _save_font_face,
	},
	['cmb_appearance'] = {
		['onchange'] = _save_appearance,
	},
}


-----------------------------------------------------------------------------------
-- 处理导出

M.css = {}
M.dialog = {}
M.jq = jq
M.jq0 = jq0


-- 重定向
M.relocation = function (rs)
	if 'HD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'WXGA' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'HD+' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'Full HD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'QHD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '4K UHD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	else
		M.dialog = dialog_720p
		M.css = css_720p
	end

	-- 重定向 jq
	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0

	_layout_center(_wnd_wh(rs))
end


return M
