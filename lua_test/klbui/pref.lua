--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   pref.lua
-- @brief  klbui UI 配置 (kenv.pref_path + klbui.json)
-- @note   约定 **klua-test-design**; 模块 lua_test.klbui.pref
--  \n org=klua app=lua_test; 字段 resolution / language / font_size / font_face / appearance
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 增加 font_size
--  \n 2026 增加 apply_font_live
--  \n 2026 增加 appearance
--  \n 2026 增加 font_face (auto / demores/font 指定字库)
--  \n 2026 font_size 档改为 16/20/24/28/32; css_loader S/M/L 标准 16/24/32
--  \n 2026 增加 WXGA+ / WSXGA+ / WUXGA / WQXGA / QHD+ / UW-FHD / UWQHD 分辨率档
--]]


local kenv = require("kenv")
local cjson = require("cjson")
local lfs = require("lfs")
local fsutil = require("lua_test.util.fsutil")
local theme = require("lua_test.klbui.theme")

local M = {}

M.ORG = "klua"
M.APP = "lua_test"
M.FILE = "klbui.json"

M.DEFAULT_RS = "Full HD"
M.DEFAULT_LANG = "en"
M.DEFAULT_FONT = "24"
M.DEFAULT_FONT_FACE = "auto"
M.DEFAULT_APPEARANCE = theme.DEFAULT

M.FONT_FACE_AUTO = "auto"
M.FONT_EXT = {
	["ttf"] = true,
	["ttc"] = true,
	["otf"] = true,
}

M.SIZE = {
	["HD"] = { w = 1280, h = 720 },
	["WXGA"] = { w = 1366, h = 768 },
	["WXGA+"] = { w = 1440, h = 900 },
	["HD+"] = { w = 1600, h = 900 },
	["WSXGA+"] = { w = 1680, h = 1050 },
	["Full HD"] = { w = 1920, h = 1080 },
	["WUXGA"] = { w = 1920, h = 1200 },
	["QHD"] = { w = 2560, h = 1440 },
	["WQXGA"] = { w = 2560, h = 1600 },
	["QHD+"] = { w = 3200, h = 1800 },
	["UW-FHD"] = { w = 2560, h = 1080 },
	["UWQHD"] = { w = 3440, h = 1440 },
	["4K UHD"] = { w = 3840, h = 2160 },
}

M.RS_ORDER = {
	"HD", "WXGA", "WXGA+", "HD+", "WSXGA+",
	"Full HD", "WUXGA",
	"QHD", "WQXGA", "QHD+",
	"UW-FHD", "UWQHD",
	"4K UHD",
}

M.FONT = {
	["16"] = 16,
	["20"] = 20,
	["24"] = 24,
	["28"] = 28,
	["32"] = 32,
}

M.FONT_ORDER = { "16", "20", "24", "28", "32" }

-- 旧 klbui.json 档名 → 像素档
M.FONT_LEGACY = {
	["small"] = "16",
	["medium"] = "24",
	["large"] = "32",
	["xlarge"] = "32",
}


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


-- @brief 是否合法分辨率档
-- @param [in] rs[string]
-- @return ok[boolean]
function M.is_rs(rs)
	return M.SIZE[rs] ~= nil
end


-- @brief 是否合法语言 (语言包 M[1]; 未加载时保留已存 key)
-- @param [in] lang[string]
-- @return ok[boolean]
function M.is_lang(lang)
	if type(lang) ~= "string" or lang == "" then
		return false
	end

	local ok, uilang = pcall(require, "klbcore.klbui.uires.lang")
	if not ok or type(uilang) ~= "table" or type(uilang.supports) ~= "function" then
		return true
	end

	local _, _, list = uilang.supports()
	if type(list) ~= "table" or #list == 0 then
		return true
	end

	for i = 1, #list do
		local item = list[i]
		if type(item) == "table" and item[lang] ~= nil then
			return true
		end
	end

	return false
end


-- @brief 规范分辨率档
-- @param [in] rs[string]
-- @return rs[string]
function M.norm_rs(rs)
	if M.is_rs(rs) then
		return rs
	end

	return M.DEFAULT_RS
end


-- @brief 规范语言
-- @param [in] lang[string]
-- @return lang[string]
function M.norm_lang(lang)
	if M.is_lang(lang) then
		return lang
	end

	return M.DEFAULT_LANG
end


-- @brief 是否合法字体档
-- @param [in] font[string]
-- @return ok[boolean]
function M.is_font(font)
	return M.FONT[font] ~= nil
end


-- @brief 规范字体档
-- @param [in] font[string]
-- @return font[string]
function M.norm_font(font)
	if type(font) == "string" and M.FONT_LEGACY[font] ~= nil then
		font = M.FONT_LEGACY[font]
	end

	if M.is_font(font) then
		return font
	end

	return M.DEFAULT_FONT
end


-- @brief 字体档对应像素
-- @param [in] font[string]
-- @return px[number]
function M.font_px(font)
	return M.FONT[M.norm_font(font)]
end


-- @brief 字体档对应下拉显示名 (存储仍用档名)
-- @param [in] font[string]
-- @return title[string]
function M.font_title(font)
	font = M.norm_font(font)
	return tostring(M.FONT[font])
end


-- @brief 字体大小下拉 append
-- @return list[array]
function M.font_append()
	local append = {}
	for i = 1, #M.FONT_ORDER do
		local name = M.FONT_ORDER[i]
		append[#append + 1] = { [name] = M.font_title(name) }
	end

	return append
end


-- @brief demores 根 (wsdl base 优先)
-- @return base[string]
function M.demores_base()
	local ok, wsdl = pcall(require, "wsdl")
	if ok and type(wsdl) == "table" and type(wsdl.get_base_path) == "function" then
		local base = wsdl.get_base_path()
		if type(base) == "string" and base ~= "" then
			return base
		end
	end

	return kenv.base_path()
end


-- @brief demores/font 目录
-- @param [in] base[string]  [可选]
-- @return dir[string]
function M.font_dir(base)
	if type(base) ~= "string" or base == "" then
		base = M.demores_base()
	end

	return _join(base, "demores/font")
end


local function _font_stem(file)
	if type(file) ~= "string" or file == "" then
		return ""
	end

	local stem = file:match("^(.+)%.[^%.]+$")
	if type(stem) ~= "string" or stem == "" then
		return file
	end

	return stem
end


local function _font_ext(file)
	if type(file) ~= "string" or file == "" then
		return ""
	end

	local ext = file:match("%.([^%.]+)$")
	if type(ext) ~= "string" then
		return ""
	end

	return string.lower(ext)
end


-- @brief 扫描 demores/font 字库
-- @param [in] base[string]  [可选]
-- @return list[array]  { stem, file, path }
function M.list_fonts(base)
	local dir = M.font_dir(base)
	local list = {}
	if lfs.attributes(dir, "mode") ~= "directory" then
		return list
	end

	for file in lfs.dir(dir) do
		if file ~= "." and file ~= ".." then
			local path = _join(dir, file)
			local attr = lfs.attributes(path)
			if type(attr) == "table" and attr.mode == "file" then
				local ext = _font_ext(file)
				if M.FONT_EXT[ext] then
					list[#list + 1] = {
						stem = _font_stem(file),
						file = file,
						path = path,
					}
				end
			end
		end
	end

	table.sort(list, function (a, b)
		return a.stem < b.stem
	end)

	return list
end


-- @brief 是否合法字库档 (auto 或 demores/font stem)
-- @param [in] face[string]
-- @param [in] base[string]  [可选]
-- @return ok[boolean]
function M.is_font_face(face, base)
	if face == M.FONT_FACE_AUTO then
		return true
	end

	if type(face) ~= "string" or face == "" then
		return false
	end

	local list = M.list_fonts(base)
	for i = 1, #list do
		if list[i].stem == face then
			return true
		end
	end

	return false
end


-- @brief 规范字库档
-- @param [in] face[string]
-- @param [in] base[string]  [可选]
-- @return face[string]
function M.norm_font_face(face, base)
	if M.is_font_face(face, base) then
		return face
	end

	return M.DEFAULT_FONT_FACE
end


-- @brief 字库档对应下拉显示名 (存储仍用档名)
-- @param [in] face[string]
-- @param [in] base[string]  [可选]
-- @return title[string]
function M.font_face_title(face, base)
	face = M.norm_font_face(face, base)
	if face == M.FONT_FACE_AUTO then
		return M.FONT_FACE_AUTO
	end

	local list = M.list_fonts(base)
	for i = 1, #list do
		local item = list[i]
		if item.stem == face then
			return item.stem .. " (" .. item.file .. ")"
		end
	end

	return face
end


-- @brief 字库下拉 append
-- @param [in] base[string]  [可选]
-- @return list[array]
function M.font_face_append(base)
	local append = {
		{ [M.FONT_FACE_AUTO] = M.FONT_FACE_AUTO },
	}
	local list = M.list_fonts(base)
	for i = 1, #list do
		local item = list[i]
		append[#append + 1] = { [item.stem] = M.font_face_title(item.stem, base) }
	end

	return append
end


-- @brief 解析字库路径 (auto 取 demores/font 首个命中)
-- @param [in] face[string]
-- @param [in] base[string]  [可选]
-- @return path[string]
function M.font_path(face, base)
	face = M.norm_font_face(face, base)
	if face == M.FONT_FACE_AUTO then
		local ok, uires = pcall(require, "klbcore.klbui.uires")
		if not ok or type(uires) ~= "table" then
			return ""
		end

		uires.append_font_search_dir(M.font_dir(base))
		local path = uires.search_font()
		if type(path) == "string" then
			return path
		end

		return ""
	end

	local list = M.list_fonts(base)
	for i = 1, #list do
		local item = list[i]
		if item.stem == face then
			return item.path
		end
	end

	return ""
end


-- @brief 加载字库 (须在 parse 前或 unload 后)
-- @param [in] klbui[table]
-- @param [in] face[string]
-- @param [in] base[string]  [可选]
-- @return ok[boolean]
function M.apply_font_face(klbui, face, base)
	if type(klbui) ~= "table" or type(klbui.load_font) ~= "function" then
		return false
	end

	local path = M.font_path(face, base)
	if type(path) ~= "string" or path == "" then
		print("[lua_test pref] font not found: " .. tostring(M.norm_font_face(face, base)))
		return false
	end

	local rc = klbui.load_font(path)
	return rc == 0
end


-- @brief 切换字库到已 parse 页面
-- @param [in] klbui[table]
-- @param [in] face[string]
-- @param [in] base[string]  [可选]
-- @return ok[boolean]
function M.apply_font_face_live(klbui, face, base)
	if type(klbui) ~= "table" then
		return false
	end

	if type(klbui.unload_font) == "function" then
		klbui.unload_font()
	end

	local ok = M.apply_font_face(klbui, face, base)
	if not ok then
		return false
	end

	local ok_kgui, kgui = pcall(require, "kgui")
	if ok_kgui and type(kgui) == "table" and type(kgui.refresh) == "function" then
		pcall(kgui.refresh)
	end

	return true
end


-- @brief 产品皮肤图子目录名 (appearance 中 - 换 _)
-- @param [in] name[string]
-- @return dir[string]
function M.skin_dir(name)
	return theme.skin_dir(name)
end


-- @brief 是否合法外观档
-- @param [in] name[string]
-- @return ok[boolean]
function M.is_appearance(name)
	return theme.is(name)
end


-- @brief 规范外观档
-- @param [in] name[string]
-- @return name[string]
function M.norm_appearance(name)
	return theme.norm(name)
end


-- @brief 外观是否加载图片
-- @param [in] name[string]
-- @return ok[boolean]
function M.use_images(name)
	return theme.use_images(name)
end


-- @brief 外观下拉显示名 (存储仍用档名)
-- @param [in] name[string]
-- @return title[string]
function M.appearance_title(name)
	return theme.title(name)
end


-- @brief 外观下拉 append
-- @return list[array]
function M.appearance_append()
	return theme.append()
end


-- @brief 语言档对应下拉显示名 (语言包 M[2]; 判定/存储仍用 M[1])
-- @param [in] lang[string]
-- @return title[string]
function M.lang_title(lang)
	lang = M.norm_lang(lang)

	local ok, uilang = pcall(require, "klbcore.klbui.uires.lang")
	if ok and type(uilang) == "table" and type(uilang.supports) == "function" then
		local _, _, list = uilang.supports()
		if type(list) == "table" then
			for i = 1, #list do
				local item = list[i]
				if type(item) == "table" and type(item[lang]) == "string" then
					return item[lang]
				end
			end
		end
	end

	return lang
end


-- @brief 分辨率档对应下拉显示名 (标准称谓 + 像素)
-- @param [in] rs[string]
-- @return title[string]  如 "Full HD (1920x1080)"
function M.rs_title(rs)
	rs = M.norm_rs(rs)
	local sz = M.SIZE[rs]
	return rs .. " (" .. sz.w .. "x" .. sz.h .. ")"
end


-- @brief 分辨率下拉 append
-- @return list[array]
function M.rs_append()
	local append = {}
	for i = 1, #M.RS_ORDER do
		local name = M.RS_ORDER[i]
		append[#append + 1] = { [name] = M.rs_title(name) }
	end

	return append
end


-- @brief 分辨率对应窗口宽高
-- @param [in] rs[string]
-- @return size[table]  { w, h }
function M.size(rs)
	local sz = M.SIZE[M.norm_rs(rs)]
	return { w = sz.w, h = sz.h }
end


-- @brief 按窗口宽高推断分辨率档 (精确匹配优先, 否则按宽/高阈值)
-- @param [in] w[number]
-- @param [in] h[number]
-- @return rs[string]
function M.from_wh(w, h)
	w = tonumber(w) or 0
	h = tonumber(h) or 0

	for i = 1, #M.RS_ORDER do
		local name = M.RS_ORDER[i]
		local sz = M.SIZE[name]
		if sz.w == w and sz.h == h then
			return name
		end
	end

	if 3840 <= w then
		return "4K UHD"
	end

	if 3400 <= w and 1400 <= h then
		return "UWQHD"
	end

	if 3200 <= w and 1700 <= h then
		return "QHD+"
	end

	if 2560 <= w and 1500 <= h then
		return "WQXGA"
	end

	if 2560 <= w and h <= 1100 then
		return "UW-FHD"
	end

	if 2560 <= w then
		return "QHD"
	end

	if 1920 <= w and 1150 <= h then
		return "WUXGA"
	end

	if 1920 <= w then
		return "Full HD"
	end

	if 1680 <= w then
		return "WSXGA+"
	end

	if 1600 <= w then
		return "HD+"
	end

	if 1440 <= w then
		return "WXGA+"
	end

	if 1366 <= w then
		return "WXGA"
	end

	return "HD"
end


-- @brief 配置目录 (kenv.pref_path)
-- @return dir[string]
function M.dir()
	local dir = kenv.pref_path(M.ORG, M.APP)
	if type(dir) ~= "string" then
		return ""
	end

	return dir
end


-- @brief klbui.json 全路径
-- @return path[string]
function M.path()
	return _join(M.dir(), M.FILE)
end


-- @brief 缺省配置
-- @return cfg[table]
function M.defaults()
	return {
		resolution = M.DEFAULT_RS,
		language = M.DEFAULT_LANG,
		font_size = M.DEFAULT_FONT,
		font_face = M.DEFAULT_FONT_FACE,
		appearance = M.DEFAULT_APPEARANCE,
	}
end


-- @brief 规范配置表
-- @param [in] cfg[table]
-- @return cfg[table]
function M.normalize(cfg)
	if type(cfg) ~= "table" then
		return M.defaults()
	end

	return {
		resolution = M.norm_rs(cfg.resolution),
		language = M.norm_lang(cfg.language),
		font_size = M.norm_font(cfg.font_size),
		font_face = M.norm_font_face(cfg.font_face),
		appearance = M.norm_appearance(cfg.appearance),
	}
end


-- @brief 读取 klbui.json; 无文件则写缺省
-- @return cfg[table]
function M.load()
	local path = M.path()
	local f = io.open(path, "rb")
	if f == nil then
		local cfg = M.defaults()
		M.save(cfg)
		return cfg
	end

	local raw = f:read("*a")
	f:close()

	if type(raw) ~= "string" or raw == "" then
		return M.defaults()
	end

	local ok, obj = pcall(cjson.decode, raw)
	if not ok or type(obj) ~= "table" then
		return M.defaults()
	end

	return M.normalize(obj)
end


-- @brief 写入 klbui.json
-- @param [in] cfg[table]
-- @return ok[boolean]
function M.save(cfg)
	cfg = M.normalize(cfg)

	local dir = M.dir()
	if dir == "" then
		print("[lua_test pref] pref_path empty")
		return false
	end

	if lfs.attributes(dir, "mode") ~= "directory" then
		local ok, err = fsutil.ensure_dir(dir)
		if not ok then
			print("[lua_test pref] mkdir fail: " .. tostring(err))
			return false
		end
	end

	local ok, text = pcall(cjson.encode, {
		resolution = cfg.resolution,
		language = cfg.language,
		font_size = cfg.font_size,
		font_face = cfg.font_face,
		appearance = cfg.appearance,
	})
	if not ok then
		print("[lua_test pref] encode fail: " .. tostring(text))
		return false
	end

	local f, err = io.open(M.path(), "wb")
	if f == nil then
		print("[lua_test pref] write fail: " .. tostring(err))
		return false
	end

	f:write(text)
	f:write("\n")
	f:close()
	return true
end


-- @brief 应用 uires 语言
-- @param [in] uires[table]
-- @param [in] lang[string]
-- @return 无
function M.apply_lang(uires, lang)
	if type(uires) ~= "table" or type(uires.apply_lang) ~= "function" then
		return
	end

	uires.apply_lang(M.norm_lang(lang))
end


-- @brief 应用外观 default_css (须在 parse 前)
-- @param [in] klbui[table]
-- @param [in] name[string]
-- @return 无
function M.apply_appearance(klbui, name)
	theme.apply(klbui, name)
end


-- @brief 应用外观到已 parse 页面
-- @param [in] klbui[table]
-- @param [in] jq0[function]
-- @param [in] name[string]
-- @return 无
function M.apply_appearance_live(klbui, jq0, name)
	local cfg = M.load()
	theme.apply_live(klbui, jq0, name, cfg.font_size)
end


-- @brief 应用默认 font-size (须在 parse 前)
-- @param [in] klbui[table]
-- @param [in] font[string]
-- @return 无
function M.apply_font(klbui, font)
	if type(klbui) ~= "table" or type(klbui.default_css) ~= "function" then
		return
	end

	local n = M.font_px(font)
	klbui.default_css({
		["font-size"] = n,
		["font-size:focus"] = n,
		["font-size:disabled"] = n,
		["font-size:checked"] = n,
		["font-size:input"] = n,
	})
end


-- @brief 应用 font-size 到已 parse 页面
-- @param [in] klbui[table]
-- @param [in] jq0[function]
-- @param [in] font[string]
-- @return 无
function M.apply_font_live(klbui, jq0, font)
	M.apply_font(klbui, font)
	if type(jq0) ~= "function" then
		return
	end

	local n = M.font_px(font)
	pcall(function ()
		local all = jq0("*")
		all.set("font-size", n)
		all.set("font-size:focus", n)
		all.set("font-size:disabled", n)
		all.set("font-size:checked", n)
		all.set("font-size:input", n)
	end)
end


return M
