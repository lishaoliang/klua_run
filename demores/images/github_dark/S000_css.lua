--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   S000_css.lua
-- @brief  Skin default CSS (global baseline)
-- @note   Appearance: github-dark
-- @note   仅 default 基线; 经 css_loader 加载, theme.apply 同步 default_css
-- @note   Loaded by uires css_loader from skin dir (S000/S001/S002 sequential merge)
-- @history 修改历史
--  \n 2026 创建; S00 拆为 S000 default 基线 (theme PALETTE, css_loader 字号阶梯)
--]]


local css_loader = require("klbcore.klbui.uires.css_loader")

local M = {}

local font_size = css_loader.font_size()

M['default'] = {
	["background-color"] = {255, 13, 17, 23},
	["background-color:disabled"] = {255, 13, 17, 23},
	["background-color:focus"] = {255, 22, 27, 34},
	["background-color:checked"] = {255, 17, 46, 87},
	["background-color:input"] = {255, 22, 27, 34},
	["border-color"] = {255, 48, 54, 61},
	["border-color:disabled"] = {255, 48, 54, 61},
	["border-color:focus"] = {255, 88, 166, 255},
	["border-color:checked"] = {255, 88, 166, 255},
	["border-color:input"] = {255, 48, 54, 61},
	["border-width"] = {1, 1, 1, 1},
	["border-width:disabled"] = {1, 1, 1, 1},
	["border-width:focus"] = {2, 2, 2, 2},
	["color"] = {255, 201, 209, 217},
	["color:disabled"] = {255, 72, 79, 88},
	["color:focus"] = {255, 230, 237, 243},
	["color:checked"] = {255, 230, 237, 243},
	["color:input"] = {255, 201, 209, 217},
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
