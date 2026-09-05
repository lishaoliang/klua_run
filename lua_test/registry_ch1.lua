--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   registry_ch1.lua
-- @brief  lua_test 第 1 章 (klbui) 用例表
-- @note   约定 **klua-test-design**; 由 registry.lua 聚合; 待实现条不登记
--  \n UI 条须 ui=true (单条转 wlua; list 标 [UI]); 建议 batch_ok=false
-- @history 修改历史
--  \n 2026 创建文件
--]]


local M = {}

M.chapter = 1
M.title = "Chapter 1 klbui"

M.cases = {
	{
		doc_id = "1.1.1",
		ids = { "klbui.custom.chrome" },
		mod = "lua_test.klbui.custom.ch1_s1_1",
		desc = "UI pref rs/lang",
		doc = "klua_doc/lua/lua_test/klbui/klbui_custom.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.1.2",
		ids = { "klbui.custom.widgets" },
		mod = "lua_test.klbui.custom.ch1_s1_2",
		desc = "UI custom kstatic + kbutton",
		doc = "klua_doc/lua/lua_test/klbui/klbui_custom.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.1.3",
		ids = { "klbui.custom.types" },
		mod = "lua_test.klbui.custom.ch1_s1_3",
		desc = "UI custom registered types",
		doc = "klua_doc/lua/lua_test/klbui/klbui_custom.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.1",
		ids = { "klbui.kdialog" },
		mod = "lua_test.klbui.shell.ch1_s2_1",
		desc = "UI kdialog title/value",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.2",
		ids = { "klbui.kview" },
		mod = "lua_test.klbui.shell.ch1_s2_2",
		desc = "UI kview title/bg/hide",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.3",
		ids = { "klbui.ktab" },
		mod = "lua_test.klbui.shell.ch1_s2_3",
		desc = "UI ktab pages",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.4",
		ids = { "klbui.kmenu" },
		mod = "lua_test.klbui.shell.ch1_s2_4",
		desc = "UI kmenu append/onchange",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.5",
		ids = { "klbui.kdiv" },
		mod = "lua_test.klbui.shell.ch1_s2_5",
		desc = "UI kdiv title/index/hide",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.6",
		ids = { "klbui.modal" },
		mod = "lua_test.klbui.shell.ch1_s2_6",
		desc = "UI modal stack",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.7",
		ids = { "klbui.popup" },
		mod = "lua_test.klbui.shell.ch1_s2_7",
		desc = "UI popup kmenu",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.2.8",
		ids = { "klbui.messagebox" },
		mod = "lua_test.klbui.shell.ch1_s2_8",
		desc = "UI messagebox stack",
		doc = "klua_doc/lua/lua_test/klbui/klbui_shell.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
	{
		doc_id = "1.3.3",
		ids = { "klbui.kpicture" },
		mod = "lua_test.klbui.basic.ch1_s3_3",
		desc = "UI kpicture image combo",
		doc = "klua_doc/lua/lua_test/klbui/klbui_basic.md",
		chapter = 1,
		batch_ok = false,
		ui = true,
	},
}

return M
