--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   theme.lua
-- @brief  klbui UI 外观 (皮肤目录编排)
-- @note   约定 **klua-test-design** / **klbcore-klbui-page**; 模块 lua_test.klbui.theme
--  \n 配色/CSS 真源 demores/images/<skin>/S000/S001/S002_css.lua
--  \n 图根 demores/images/tmpimage; 对应 C "~/tmpimage"; 页面 key 不含皮肤名
--  \n 产品皮肤图 demores/images/<skin_dir>; appearance 中 - 换 _ (如 win11-dark → win11_dark)
--  \n 由 ui.run / pref 生效; 页面只同步本页控件
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 light 改为仿 XP 蓝
--  \n 2026 增加 fluent (Win11 浅色)
--  \n 2026 删除 plain 外观档
--  \n 2026 增加 win11-dark / ios-dark / material-dark / github-dark
--  \n 2026 产品皮肤目录 skin_dir (- 换 _)
--  \n 2026 apply_skin: 皮肤目录 CSS+图片 (S000/S001/S002)
--  \n 2026 font_tier; apply_images 皮肤+tmpimage; apply_live 换肤重载皮肤 CSS
--  \n 2026 CSS 迁入皮肤 S***_css.lua; theme 读 css_loader.default()
--]]


local css_loader = require("klbcore.klbui.uires.css_loader")

local M = {}

M.DARK = "dark"
M.WIN11_DARK = "win11-dark"
M.IOS_DARK = "ios-dark"
M.MATERIAL_DARK = "material-dark"
M.GITHUB_DARK = "github-dark"
M.LIGHT = "light"
M.FLUENT = "fluent"
M.DEFAULT = "dark"

M.ORDER = {
	"dark",
	"win11-dark",
	"ios-dark",
	"material-dark",
	"github-dark",
	"light",
	"fluent",
}


local TITLE = {
	["dark"] = "dark (VS Code)",
	["win11-dark"] = "Win11 dark",
	["ios-dark"] = "iOS dark",
	["material-dark"] = "Material dark",
	["github-dark"] = "GitHub dark",
	["light"] = "light (Windows XP)",
	["fluent"] = "fluent (Windows 11)",
}


local LANG_KEY = {
	["dark"] = "AppearanceDark",
	["win11-dark"] = "AppearanceWin11Dark",
	["ios-dark"] = "AppearanceIosDark",
	["material-dark"] = "AppearanceMaterialDark",
	["github-dark"] = "AppearanceGithubDark",
	["light"] = "AppearanceLight",
	["fluent"] = "AppearanceFluent",
}


local images_ctx = {
	uires = nil,
	klbui = nil,
	base = "",
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


local function _is_known(name)
	for i = 1, #M.ORDER do
		if M.ORDER[i] == name then
			return true
		end
	end

	return false
end


-- @brief 是否合法外观档
-- @param [in] name[string]
-- @return ok[boolean]
function M.is(name)
	return _is_known(name)
end


-- @brief 规范外观档
-- @param [in] name[string]
-- @return name[string]
function M.norm(name)
	if M.is(name) then
		return name
	end

	return M.DEFAULT
end


-- @brief 该外观是否加载图片资源
-- @param [in] name[string]
-- @return ok[boolean]
function M.use_images(name)
	return true
end


-- @brief pref font_size 档映射 css_loader S/M/L (16→S, 20/24→M, 28/32→L)
-- @param [in] font_size[string|number]
-- @return tier[string]  'S' / 'M' / 'L'
function M.font_tier(font_size)
	font_size = tostring(font_size or "24")
	if "16" == font_size then
		return "S"
	end

	if "28" == font_size or "32" == font_size then
		return "L"
	end

	return "M"
end


-- @brief 产品皮肤图子目录名 (appearance 中 - 换 _)
-- @param [in] name[string]
-- @return dir[string]
function M.skin_dir(name)
	name = M.norm(name)

	return (string.gsub(name, "-", "_"))
end


-- @brief 产品皮肤图相对路径 (相对 cwd / wsdl base)
-- @param [in] name[string]
-- @return rel[string]
function M.images_skin_rel(name)
	return "demores/images/" .. M.skin_dir(name)
end


-- @brief 产品皮肤图检索根 (绝对或拼接路径)
-- @param [in] base[string]
-- @param [in] name[string]
-- @return dir[string]
function M.images_skin_dir(base, name)
	return _join(base, M.images_skin_rel(name))
end


-- @brief lua test 图片相对路径 (相对 cwd / wsdl base)
-- @param [in] name[string]  外观名 (未用; 图根固定 tmpimage)
-- @return rel[string]
function M.images_rel(name)
	return "demores/images/tmpimage"
end


-- @brief 外观图片检索根 (绝对或拼接路径)
-- @param [in] base[string]
-- @param [in] name[string]
-- @return dir[string]
function M.images_dir(base, name)
	return _join(base, M.images_rel(name))
end


-- @brief 绑定开窗后的图片上下文 (供 live 换肤)
-- @param [in] uires[table]
-- @param [in] klbui[table]
-- @param [in] base[string]
-- @return 无
function M.bind_images(uires, klbui, base)
	images_ctx.uires = uires
	images_ctx.klbui = klbui
	images_ctx.base = base or ""
end


-- @brief 加载皮肤目录 (CSS + 图片同目录; 见 demores/images/README.md)
-- @param [in] uires[table]
-- @param [in] klbui[table]		[可选] 换肤前 clear_image
-- @param [in] base[string]
-- @param [in] name[string]		appearance
-- @param [in] font_tier[string]	[可选] 'S' / 'M' / 'L'; 默认 'M'
-- @return 无
function M.apply_skin(uires, klbui, base, name, font_tier)
	if type(uires) ~= "table" then
		return
	end

	name = M.norm(name)
	local skin_dir = M.images_skin_dir(base, name)
	if type(uires.configure) == "function" then
		uires.configure({
			css_dirs = { skin_dir },
			image_dirs = { skin_dir },
		})
	end

	if type(uires.load_css) == "function" then
		uires.load_css(font_tier or "M")
	end

	if type(klbui) == "table" and type(klbui.clear_image) == "function" then
		klbui.clear_image()
	end

	if type(uires.load_images) == "function" then
		uires.load_images()
	end
end


-- @brief 生效皮肤全局 CSS (须在 apply_skin / load_css 之后, parse 前)
-- @param [in] uires[table]
-- @return 无
function M.apply_skin_css(uires)
	if type(uires) == "table" and type(uires.apply_css) == "function" then
		uires.apply_css()
	end
end


-- @brief 加载皮肤图 + lua test 图 (皮肤目录优先, tmpimage 覆盖同 key)
-- @param [in] uires[table]
-- @param [in] klbui[table]
-- @param [in] base[string]
-- @param [in] name[string]
-- @return 无
function M.apply_images(uires, klbui, base, name)
	if type(uires) ~= "table" or type(uires.configure) ~= "function" then
		return
	end

	name = M.norm(name)
	local dirs = {}
	if M.use_images(name) then
		dirs[#dirs + 1] = M.images_skin_dir(base, name)
		dirs[#dirs + 1] = M.images_dir(base, name)
	end

	uires.configure({
		image_dirs = dirs,
	})
	if type(klbui) == "table" and type(klbui.clear_image) == "function" then
		klbui.clear_image()
	end

	if 0 < #dirs and type(uires.load_images) == "function" then
		uires.load_images()
	end
end


-- @brief 当前皮肤 S000 default_css (须在 load_css 之后)
-- @param [in] name[string]  [可选] 未用; 保留 API 兼容
-- @return css[table]
function M.css(name)
	return css_loader.default()
end


-- @brief 外观下拉显示名
-- @param [in] name[string]
-- @return title[string]
function M.title(name)
	name = M.norm(name)

	local ok, uilang = pcall(require, "klbcore.klbui.uires.lang")
	if ok and type(uilang) == "table" and type(uilang.str) == "function" then
		local key = LANG_KEY[name]
		local s = uilang.str(key)
		if type(s) == "string" and s ~= "" and s ~= "xxxx" then
			return s
		end
	end

	return TITLE[name]
end


-- @brief 下拉 append 表
-- @return list[array]
function M.append()
	local list = {}
	for i = 1, #M.ORDER do
		local name = M.ORDER[i]
		list[#list + 1] = {
			[name] = M.title(name),
		}
	end

	return list
end


-- @brief 应用外观到 default_css (须在 apply_skin / load_css 之后, parse 前)
-- @param [in] klbui[table]
-- @param [in] name[string]
-- @return 无
function M.apply(klbui, name)
	if type(klbui) ~= "table" or type(klbui.default_css) ~= "function" then
		return
	end

	local css = M.css(name)
	if next(css) ~= nil then
		klbui.default_css(css)
	end
end


-- @brief 应用外观到已 parse 页面
-- @param [in] klbui[table]
-- @param [in] jq0[function]
-- @param [in] name[string]
-- @param [in] font_size[string]  [可选] pref font_size 档, 映射 css_loader S/M/L
-- @return 无
function M.apply_live(klbui, jq0, name, font_size)
	if images_ctx.uires ~= nil then
		M.apply_skin(images_ctx.uires, images_ctx.klbui, images_ctx.base, name,
			M.font_tier(font_size))
		M.apply_skin_css(images_ctx.uires)
		M.apply_images(images_ctx.uires, images_ctx.klbui, images_ctx.base, name)
	end

	M.apply(klbui, name)
	if type(jq0) ~= "function" then
		return
	end

	local css = M.css(name)
	pcall(function ()
		local all = jq0("*")
		for k, v in pairs(css) do
			all.set(k, v)
		end
	end)
end


return M
