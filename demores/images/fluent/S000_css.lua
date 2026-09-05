--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   S000_css.lua
-- @brief  Skin default CSS (global baseline)
-- @note   Appearance: fluent (Windows 11 light)
-- @note   仅 default 基线; 经 css_loader 加载, theme.apply 同步 default_css
-- @note   Loaded by uires css_loader from skin dir (S000/S001/S002 sequential merge)
-- @history 修改历史
--  \n 2026 创建; S00 拆为 S000 default 基线 (theme PALETTE, css_loader 字号阶梯)
--]]


local css_loader = require("klbcore.klbui.uires.css_loader")

local M = {}

local font_size = css_loader.font_size()

M['default'] = {
	["background-color"] = {255, 243, 243, 243},
	["background-color:disabled"] = {255, 243, 243, 243},
	["background-color:focus"] = {255, 249, 249, 249},
	["background-color:checked"] = {255, 0, 120, 212},
	["background-color:input"] = {255, 255, 255, 255},
	["border-color"] = {255, 209, 209, 209},
	["border-color:disabled"] = {255, 229, 229, 229},
	["border-color:focus"] = {255, 0, 120, 212},
	["border-color:checked"] = {255, 0, 120, 212},
	["border-color:input"] = {255, 209, 209, 209},
	["border-width"] = {1, 1, 1, 1},
	["border-width:disabled"] = {1, 1, 1, 1},
	["border-width:focus"] = {2, 2, 2, 2},
	["color"] = {255, 26, 26, 26},
	["color:disabled"] = {255, 157, 157, 157},
	["color:focus"] = {255, 26, 26, 26},
	["color:checked"] = {255, 26, 26, 26},
	["color:input"] = {255, 26, 26, 26},
	["font-size"] = font_size,
	["font-size:disabled"] = font_size,
	["font-size:focus"] = font_size + 1,
	["margin"] = {0, 0, 0, 0},
	["padding"] = {1, 1, 1, 1},
	["text-align"] = "left",
	["text-align:disabled"] = "left",
	["text-align:focus"] = "left",
}

return M
