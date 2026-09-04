--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   custom/ch1_s1_3.lua
-- @brief  1.1.3 UI 已注册 type 一览
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n kview/kstatic/kbutton/kpicture/kdemo; 本页满窗 parse; 开窗由 ui.run
-- @history 修改历史
--  \n 2026 创建文件
--]]


local klbui = require("klbcore.klbui")

local M = {}

local jq = function () end
local jq0 = function () end


-----------------------------------------------------------------------------------
-- css

local css_720p = {
	['type'] = {
		['kview'] = {
			['background-color'] = {255, 48, 48, 52},
		},
		['kbutton'] = {
			['background-color'] = {255, 70, 70, 80},
			['border-width'] = 1,
			['border-color'] = {255, 140, 140, 140},
		},
		['kdemo'] = {
			['background-color'] = {255, 60, 80, 60},
		},
		['kpicture'] = {
			['border-width'] = 1,
			['border-color'] = {255, 160, 120, 120},
		},
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
			['pos'] = {16, 16, 640, 32},
			['title'] = 'registered types: kview / kstatic / kbutton / kpicture / kdemo',
			['name'] = 'hint',
		},
		{
			['type'] = 'kview',
			['pos'] = {16, 64, 200, 80},
			['title'] = 'kview',
			['name'] = 'box',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {232, 64, 240, 32},
			['title'] = 'kstatic',
			['name'] = 'lab',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {232, 112, 120, 32},
			['title'] = 'kbutton',
			['name'] = 'btn',
		},
		{
			['type'] = 'kpicture',
			['pos'] = {16, 160, 200, 80},
			['title'] = 'kpicture',
			['name'] = 'pic',
			['background-color'] = {255, 80, 60, 60},
		},
		{
			['type'] = 'kdemo',
			['pos'] = {232, 160, 120, 80},
			['name'] = 'demo',
		},
	}
}


-----------------------------------------------------------------------------------
-- commands

M.commands = {
}


-----------------------------------------------------------------------------------
-- 处理导出

M.css = {}
M.dialog = {}
M.jq = jq
M.jq0 = jq0


-- 重定向
M.relocation = function (rs)
	if '720p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '1366x768' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '900p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '1080p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '1440p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '4k' == rs then
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
end


return M
