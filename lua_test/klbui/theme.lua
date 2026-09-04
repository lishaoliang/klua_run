--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   theme.lua
-- @brief  klbui UI 外观 (default_css)
-- @note   约定 **klua-test-design** / **klbcore-klbui-page**; 模块 lua_test.klbui.theme
--  \n dark 仿 VS Code; win11-dark / ios-dark / material-dark / github-dark 仿各平台深色
--  \n light 仿 XP 蓝; fluent 仿 Win11 浅色
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
--]]


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

-- 旧 klbui.json plain → 缺省外观
M.APPEARANCE_LEGACY = {
	["plain"] = "dark",
}


local function _c(r, g, b)
	return {255, r, g, b}
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


local images_ctx = {
	uires = nil,
	klbui = nil,
	base = "",
}


-- 配色键 (default_css / 已 parse 控件)
local CSS_KEYS = {
	"color",
	"color:focus",
	"color:disabled",
	"color:checked",
	"color:input",
	"background-color",
	"background-color:focus",
	"background-color:disabled",
	"background-color:checked",
	"background-color:input",
	"border-color",
	"border-color:focus",
	"border-color:disabled",
	"border-color:checked",
	"border-color:input",
	"border-width",
}


-- 1. 仿 VS Code Dark+
local CSS_DARK = {
	["color"] = _c(204, 204, 204),
	["color:focus"] = _c(255, 255, 255),
	["color:disabled"] = _c(133, 133, 133),
	["color:checked"] = _c(255, 255, 255),
	["color:input"] = _c(204, 204, 204),
	["background-color"] = _c(30, 30, 30),
	["background-color:focus"] = _c(37, 37, 38),
	["background-color:disabled"] = _c(30, 30, 30),
	["background-color:checked"] = _c(9, 71, 113),
	["background-color:input"] = _c(60, 60, 60),
	["border-color"] = _c(60, 60, 60),
	["border-color:focus"] = _c(0, 122, 204),
	["border-color:disabled"] = _c(60, 60, 60),
	["border-color:checked"] = _c(0, 122, 204),
	["border-color:input"] = _c(0, 122, 204),
	["border-width"] = 1,
}


-- 2. 仿 Windows 11 深色
local CSS_WIN11_DARK = {
	["color"] = _c(255, 255, 255),
	["color:focus"] = _c(255, 255, 255),
	["color:disabled"] = _c(109, 109, 109),
	["color:checked"] = _c(255, 255, 255),
	["color:input"] = _c(255, 255, 255),
	["background-color"] = _c(32, 32, 32),
	["background-color:focus"] = _c(43, 43, 43),
	["background-color:disabled"] = _c(32, 32, 32),
	["background-color:checked"] = _c(0, 88, 163),
	["background-color:input"] = _c(45, 45, 45),
	["border-color"] = _c(69, 69, 69),
	["border-color:focus"] = _c(0, 120, 212),
	["border-color:disabled"] = _c(69, 69, 69),
	["border-color:checked"] = _c(0, 120, 212),
	["border-color:input"] = _c(69, 69, 69),
	["border-width"] = 1,
}


-- 3. 仿 iOS / macOS HIG 深色
local CSS_IOS_DARK = {
	["color"] = _c(255, 255, 255),
	["color:focus"] = _c(255, 255, 255),
	["color:disabled"] = _c(142, 142, 147),
	["color:checked"] = _c(255, 255, 255),
	["color:input"] = _c(255, 255, 255),
	["background-color"] = _c(28, 28, 30),
	["background-color:focus"] = _c(44, 44, 46),
	["background-color:disabled"] = _c(28, 28, 30),
	["background-color:checked"] = _c(0, 72, 147),
	["background-color:input"] = _c(28, 28, 30),
	["border-color"] = _c(56, 56, 58),
	["border-color:focus"] = _c(10, 132, 255),
	["border-color:disabled"] = _c(56, 56, 58),
	["border-color:checked"] = _c(10, 132, 255),
	["border-color:input"] = _c(56, 56, 58),
	["border-width"] = 1,
}


-- 4. 仿 Material 3 Dark
local CSS_MATERIAL_DARK = {
	["color"] = _c(230, 225, 229),
	["color:focus"] = _c(230, 225, 229),
	["color:disabled"] = _c(147, 143, 153),
	["color:checked"] = _c(255, 255, 255),
	["color:input"] = _c(230, 225, 229),
	["background-color"] = _c(18, 18, 18),
	["background-color:focus"] = _c(30, 30, 30),
	["background-color:disabled"] = _c(18, 18, 18),
	["background-color:checked"] = _c(55, 48, 70),
	["background-color:input"] = _c(46, 46, 46),
	["border-color"] = _c(72, 72, 72),
	["border-color:focus"] = _c(187, 134, 252),
	["border-color:disabled"] = _c(72, 72, 72),
	["border-color:checked"] = _c(187, 134, 252),
	["border-color:input"] = _c(72, 72, 72),
	["border-width"] = 1,
}


-- 5. 仿 GitHub Dark
local CSS_GITHUB_DARK = {
	["color"] = _c(201, 209, 217),
	["color:focus"] = _c(230, 237, 243),
	["color:disabled"] = _c(72, 79, 88),
	["color:checked"] = _c(255, 255, 255),
	["color:input"] = _c(201, 209, 217),
	["background-color"] = _c(13, 17, 23),
	["background-color:focus"] = _c(22, 27, 34),
	["background-color:disabled"] = _c(13, 17, 23),
	["background-color:checked"] = _c(17, 46, 87),
	["background-color:input"] = _c(22, 27, 34),
	["border-color"] = _c(48, 54, 61),
	["border-color:focus"] = _c(88, 166, 255),
	["border-color:disabled"] = _c(48, 54, 61),
	["border-color:checked"] = _c(88, 166, 255),
	["border-color:input"] = _c(48, 54, 61),
	["border-width"] = 1,
}


-- 6. 仿 Windows XP Luna 蓝 (对话框米色 + 标题蓝)
local CSS_LIGHT = {
	["color"] = _c(0, 0, 0),
	["color:focus"] = _c(0, 0, 0),
	["color:disabled"] = _c(172, 168, 153),
	["color:checked"] = _c(255, 255, 255),
	["color:input"] = _c(0, 0, 0),
	["background-color"] = _c(236, 233, 216),
	["background-color:focus"] = _c(236, 233, 216),
	["background-color:disabled"] = _c(236, 233, 216),
	["background-color:checked"] = _c(49, 106, 197),
	["background-color:input"] = _c(255, 255, 255),
	["border-color"] = _c(0, 84, 227),
	["border-color:focus"] = _c(61, 149, 255),
	["border-color:disabled"] = _c(192, 192, 192),
	["border-color:checked"] = _c(10, 36, 106),
	["border-color:input"] = _c(127, 157, 185),
	["border-width"] = 1,
}


-- 7. 仿 Windows 11 Fluent 浅色
local CSS_FLUENT = {
	["color"] = _c(26, 26, 26),
	["color:focus"] = _c(26, 26, 26),
	["color:disabled"] = _c(157, 157, 157),
	["color:checked"] = _c(255, 255, 255),
	["color:input"] = _c(26, 26, 26),
	["background-color"] = _c(243, 243, 243),
	["background-color:focus"] = _c(249, 249, 249),
	["background-color:disabled"] = _c(243, 243, 243),
	["background-color:checked"] = _c(0, 120, 212),
	["background-color:input"] = _c(255, 255, 255),
	["border-color"] = _c(229, 229, 229),
	["border-color:focus"] = _c(0, 120, 212),
	["border-color:disabled"] = _c(229, 229, 229),
	["border-color:checked"] = _c(0, 120, 212),
	["border-color:input"] = _c(209, 209, 209),
	["border-width"] = 1,
}


local CSS = {
	["dark"] = CSS_DARK,
	["win11-dark"] = CSS_WIN11_DARK,
	["ios-dark"] = CSS_IOS_DARK,
	["material-dark"] = CSS_MATERIAL_DARK,
	["github-dark"] = CSS_GITHUB_DARK,
	["light"] = CSS_LIGHT,
	["fluent"] = CSS_FLUENT,
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


-- @brief 是否合法外观档
-- @param [in] name[string]
-- @return ok[boolean]
function M.is(name)
	return CSS[name] ~= nil
end


-- @brief 规范外观档
-- @param [in] name[string]
-- @return name[string]
function M.norm(name)
	if type(name) == "string" and M.APPEARANCE_LEGACY[name] ~= nil then
		name = M.APPEARANCE_LEGACY[name]
	end

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


-- @brief 重置图片检索根并加载 (lua test 固定 tmpimage)
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
	if M.use_images(name) then
		uires.configure({
			image_dirs = {
				M.images_dir(base, name),
			},
		})
		if type(klbui) == "table" and type(klbui.clear_image) == "function" then
			klbui.clear_image()
		end
		uires.load_images()
	else
		uires.configure({
			image_dirs = {},
		})
		if type(klbui) == "table" and type(klbui.clear_image) == "function" then
			klbui.clear_image()
		end
	end
end


-- @brief 外观 default_css 表
-- @param [in] name[string]
-- @return css[table]
function M.css(name)
	return CSS[M.norm(name)]
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


-- @brief 应用外观到 default_css (须在 parse 前)
-- @param [in] klbui[table]
-- @param [in] name[string]
-- @return 无
function M.apply(klbui, name)
	if type(klbui) ~= "table" or type(klbui.default_css) ~= "function" then
		return
	end

	klbui.default_css(M.css(name))
end


-- @brief 应用外观到已 parse 页面
-- @param [in] klbui[table]
-- @param [in] jq0[function]
-- @param [in] name[string]
-- @return 无
function M.apply_live(klbui, jq0, name)
	M.apply(klbui, name)
	if images_ctx.uires ~= nil then
		M.apply_images(images_ctx.uires, images_ctx.klbui, images_ctx.base, name)
	end
	if type(jq0) ~= "function" then
		return
	end

	local css = M.css(name)
	pcall(function ()
		local all = jq0("*")
		for i = 1, #CSS_KEYS do
			local k = CSS_KEYS[i]
			all.set(k, css[k])
		end
	end)
end


return M
