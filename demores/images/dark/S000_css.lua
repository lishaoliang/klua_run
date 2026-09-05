--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   S000_css.lua
-- @brief  Skin default CSS (global baseline)
-- @note   Appearance: dark (VS Code Dark+)
-- @note   仅 default 基线; 经 css_loader 加载, theme.apply 同步 default_css
-- @note   Loaded by uires css_loader from skin dir (S000/S001/S002 sequential merge)
-- @history 修改历史
--  \n 2026 创建; S00 拆为 S000 default 基线 (theme PALETTE, css_loader 字号阶梯)
--]]


local css_loader = require("klbcore.klbui.uires.css_loader")

local M = {}

local font_size = css_loader.font_size()

M['default'] = {
	["background-color"] = {255, 30, 30, 30},
	["background-color:disabled"] = {255, 46, 46, 46},
	["background-color:focus"] = {255, 37, 37, 38},
	["background-color:checked"] = {255, 9, 71, 113},
	["background-color:input"] = {255, 60, 60, 60},
	["border-color"] = {255, 60, 60, 60},
	["border-color:disabled"] = {255, 60, 60, 60},
	["border-color:focus"] = {255, 0, 122, 204},
	["border-color:checked"] = {255, 0, 122, 204},
	["border-color:input"] = {255, 0, 122, 204},
	["border-width"] = {1, 1, 1, 1},
	["border-width:disabled"] = {1, 1, 1, 1},
	["border-width:focus"] = {2, 2, 2, 2},
	["color"] = {255, 204, 204, 204},
	["color:disabled"] = {255, 133, 133, 133},
	["color:focus"] = {255, 255, 255, 255},
	["color:checked"] = {255, 255, 255, 255},
	["color:input"] = {255, 204, 204, 204},
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
