--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   registry_ch3.lua
-- @brief  lua_test 第 3 章 (klb k*) 用例表
-- @note   约定 **klua-test-design**; 由 registry.lua 聚合
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 章号冻结: 3=klb (原第 1 章)
--]]


local M = {}

M.chapter = 3
M.title = "Chapter 3 klb"

M.cases = {
	{
		doc_id = "3.1.1",
		ids = { "klb.kco.fork", "klb.kco_fork" },
		mod = "lua_test.klb.kco_fork",
		desc = "kco.fork / kco.timeout smoke test",
		doc = "klua_doc/lua/lua_test/klb/readme.md",
		chapter = 3,
		batch_ok = true,
	},
}

return M
