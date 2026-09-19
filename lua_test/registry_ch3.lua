--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   registry_ch3.lua
-- @brief  lua_test 第 3 章 (klb) 用例表
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
		{
			doc_id = "3.2.1",
			ids = { "klbhttp.co_get" },
			mod = "lua_test.klb.http.ch3_s2_1",
			desc = "klbhttp.co_get loopback smoke",
			doc = "klua_doc/lua/lua_test/klb/klbhttp.md",
			chapter = 3,
			batch_ok = true,
		},
		{
			doc_id = "3.2.2",
			ids = { "klbhttp.co_post" },
			mod = "lua_test.klb.http.ch3_s2_2",
			desc = "klbhttp.co_post loopback smoke",
			doc = "klua_doc/lua/lua_test/klb/klbhttp.md",
			chapter = 3,
			batch_ok = true,
		},
		{
			doc_id = "3.2.3",
			ids = { "klbhttp.connect" },
			mod = "lua_test.klb.http.ch3_s2_3",
			desc = "klbhttp.connect loopback smoke",
			doc = "klua_doc/lua/lua_test/klb/klbhttp.md",
			chapter = 3,
			batch_ok = true,
		},
		{
			doc_id = "3.2.4",
			ids = { "klbhttp.listen" },
			mod = "lua_test.klb.http.ch3_s2_4",
			desc = "klbhttp.listen / co_accept loopback smoke",
			doc = "klua_doc/lua/lua_test/klb/klbhttp.md",
			chapter = 3,
			batch_ok = true,
		},
		{
			doc_id = "3.2.5",
			ids = { "klbhttp.co_get.public" },
			mod = "lua_test.klb.http.ch3_s2_5",
			desc = "klbhttp.co_get public sites",
			doc = "klua_doc/lua/lua_test/klb/klbhttp.md",
			chapter = 3,
			batch_ok = false,
		},
		{
			doc_id = "3.2.6",
			ids = { "klbhttp.co_post.public" },
			mod = "lua_test.klb.http.ch3_s2_6",
			desc = "klbhttp.co_post public sites",
			doc = "klua_doc/lua/lua_test/klb/klbhttp.md",
			chapter = 3,
			batch_ok = false,
		},
}

return M
