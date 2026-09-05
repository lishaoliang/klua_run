--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   basic/ch1_s3_3.lua
-- @brief  1.3.3 UI kpicture
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 右大图 pic 可操作; 左示意图 pic_png 与右图同 key
--  \n 左图: 小于框则 default(原图), 大于框则 resize(缩放)
--  \n 右图模式: default(原图)/resize(缩放)/scale9; 开窗由 ui.run
--  \n 一个 kcombo 列 tmpimage/png 与 tmpimage/bmp 格式样例; 无图或 plain 时为色块
--  \n 文案 lang.str; apply_lang 由 ui.run 调用
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 先只留一块 kpicture
--]]


local klbui = require("klbcore.klbui")
local lang = require("klbcore.klbui.uires.lang")
local kgui = require("kgui")
local kenv = require("kenv")
local lfs = require("lfs")
local theme = require("lua_test.klbui.theme")

local M = {}

local jq = function () end
local jq0 = function () end
local g_filled = false


-----------------------------------------------------------------------------------
-- css

local css_720p = {
	['type'] = {
	},
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
			['pos'] = {16, 12, 1248, 28},
			['title'] = lang.str('KpictureHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 44, 1248, 28},
			['title'] = string.format(lang.str('KpictureLabFmt'), lang.str('ModeDefault')),
			['name'] = 'lab',
		},
		{
			['type'] = 'kpicture',
			['pos'] = {328, 80, 936, 624},
			['name'] = 'pic',
			['title'] = 'image',
			['value'] = 'cover',
			['background-color'] = {255, 60, 80, 60},
			['background-image'] = '/cover',
			['background-image-mode'] = 'default',
		},
		{
			['type'] = 'kpicture',
			['pos'] = {16, 80, 296, 166},
			['name'] = 'pic_png',
			['title'] = 'png',
			['value'] = 'cover',
			['background-color'] = {255, 40, 60, 100},
			['background-image'] = '/cover',
			['background-image-mode'] = 'default',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 258, 90, 32},
			['title'] = lang.str('Get'),
			['name'] = 'btn_get',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {119, 258, 90, 32},
			['title'] = lang.str('Set'),
			['name'] = 'btn_set',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {222, 258, 90, 32},
			['title'] = lang.str('ToggleHide'),
			['name'] = 'btn_hide',
		},
		{
			['type'] = 'kcombo',
			['pos'] = {16, 298, 296, 32},
			['name'] = 'cmb_img',
			['title'] = lang.str('KpictureFmtImage'),
			['value'] = '',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 338, 90, 32},
			['title'] = lang.str('ImageClear'),
			['name'] = 'btn_clear',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 378, 90, 32},
			['title'] = lang.str('ModeDefault'),
			['name'] = 'btn_mode_default',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {119, 378, 90, 32},
			['title'] = lang.str('ModeResize'),
			['name'] = 'btn_mode_resize',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {222, 378, 90, 32},
			['title'] = lang.str('Scale9'),
			['name'] = 'btn_mode_scale9',
		},
	}
}


-----------------------------------------------------------------------------------
-- commands

-- UI 走 lang; 控制台固定英文 (避免终端乱码)
local function _lab(s, en)
	jq('lab').set('title', s)
	print('  kpicture: ' .. (en or s))
end

-- mode: default=原图拷贝, resize=缩放铺满, scale9=九宫格
local function _mode_lab(mode)
	if 'scale9' == mode then
		return lang.str('Scale9')
	elseif 'resize' == mode then
		return lang.str('ModeResize')
	end

	return lang.str('ModeDefault')
end


local function _mode_en(mode)
	if 'scale9' == mode then
		return 'scale9'
	elseif 'resize' == mode then
		return 'resize'
	end

	return 'default'
end


local function _set_mode(mode)
	jq('pic').set('background-image-mode', mode)
	_lab(string.format(lang.str('KpictureModeFmt'), _mode_lab(mode)),
		'pic mode=' .. _mode_en(mode))
end


local function _set_child(dialog, name, key, val)
	local child = dialog and dialog.child
	if type(child) ~= 'table' then
		return
	end

	for i = 1, #child do
		local n = child[i]
		if type(n) == 'table' and n.name == name then
			n[key] = val
			return
		end
	end
end


local function _set_title(name, title)
	_set_child(M.dialog, name, 'title', title)
	if type(M.jq) == 'function' then
		pcall(function ()
			M.jq(name).set('title', title)
		end)
	end
end


local function _join(base, rel)
	if base == nil or base == '' then
		return rel
	end

	local last = base:sub(-1)
	if last == '/' or last == '\\' then
		return base .. rel
	end

	return base .. '/' .. rel
end


-- @brief lua test 图根 (demores/images/tmpimage)
-- @return dir[string]
local function _tmpimage_root()
	local base = ''
	local ok, wsdl = pcall(require, 'wsdl')
	if ok and type(wsdl) == 'table' and type(wsdl.get_base_path) == 'function' then
		base = wsdl.get_base_path() or ''
	end

	if type(base) ~= 'string' or base == '' then
		base = kenv.base_path() or ''
	end

	return theme.images_dir(base)
end


-- @brief 列出 tmpimage/<fmt> 下指定扩展名文件
-- @param [in] fmt[string]   png / bmp
-- @param [in] ext[string]   png / bmp
-- @return items[array]      { key, title }
-- @note 按已知扩展名列格式样例; 不是 stem 回退探测
local function _list_fmt(fmt, ext)
	local items = {}
	local root = _join(_tmpimage_root(), fmt)
	local ext_dot = '.' .. ext
	local ext_len = #ext_dot

	local function walk(path, key_prefix, rel_prefix)
		if lfs.attributes(path, 'mode') ~= 'directory' then
			return
		end

		for file in lfs.dir(path) do
			if file ~= '.' and file ~= '..' then
				local full = _join(path, file)
				local attr = lfs.attributes(full)
				if attr and attr.mode == 'directory' then
					local sub_rel = rel_prefix
					if sub_rel == '' then
						sub_rel = file .. '/'
					else
						sub_rel = rel_prefix .. file .. '/'
					end
					walk(full, key_prefix .. '/' .. file, sub_rel)
				elseif attr and attr.mode == 'file' then
					local lower = string.lower(file)
					if #lower > ext_len and lower:sub(-ext_len) == ext_dot then
						local stem = file:sub(1, #file - ext_len)
						if stem ~= '' then
							items[#items + 1] = {
								key = key_prefix .. '/' .. stem,
								title = rel_prefix .. stem,
							}
						end
					end
				end
			end
		end
	end

	walk(root, '/' .. fmt, '')
	table.sort(items, function (a, b)
		return a.title < b.title
	end)

	return items
end


local function _to_append(items)
	local list = {}
	for i = 1, #items do
		list[i] = {
			[items[i].key] = items[i].title,
		}
	end

	return list
end


local function _pick(items, want)
	if type(items) ~= 'table' or #items < 1 then
		return nil
	end

	if type(want) == 'string' and want ~= '' then
		local tail = '/' .. want
		for i = 1, #items do
			local t = items[i].title
			if t == want or t:sub(-#tail) == tail then
				return items[i]
			end
		end
	end

	return items[1]
end


-- @brief 合并 png/bmp 列表; 标题带格式前缀
-- @return items[array]  { key, title }
local function _list_all()
	local items = {}
	local function add(fmt, ext)
		local list = _list_fmt(fmt, ext)
		for i = 1, #list do
			items[#items + 1] = {
				key = list[i].key,
				title = fmt .. '/' .. list[i].title,
			}
		end
	end

	add('png', 'png')
	add('bmp', 'bmp')
	table.sort(items, function (a, b)
		return a.title < b.title
	end)

	return items
end


local function _pick_default(items)
	if type(items) ~= 'table' or #items < 1 then
		return nil
	end

	for i = 1, #items do
		local t = items[i].title
		if type(t) == 'string' and t:sub(1, 4) == 'png/' then
			if t:sub(-6) == '/cover' then
				return items[i]
			end
		end
	end

	return _pick(items, 'cover')
end


local function _fill_combo(name, items, pick)
	if type(jq) ~= 'function' then
		return
	end

	pcall(function ()
		jq(name).set('clear', true)
		if type(items) ~= 'table' or #items < 1 then
			return
		end

		jq(name).append(_to_append(items))
		if type(pick) ~= 'table' then
			return
		end

		jq(name).value(pick.key)
		jq(name).set('title', pick.title)
	end)
end


local function _left_box_wh()
	local w = 296
	local h = 166
	local child = M.dialog and M.dialog.child
	if type(child) ~= 'table' then
		return w, h
	end

	for i = 1, #child do
		local n = child[i]
		if type(n) == 'table' and n.name == 'pic_png' and type(n.pos) == 'table' then
			local pw = tonumber(n.pos[3])
			local ph = tonumber(n.pos[4])
			if pw ~= nil and 0 < pw then
				w = pw
			end
			if ph ~= nil and 0 < ph then
				h = ph
			end
			break
		end
	end

	return w, h
end


-- @brief 左示意图 mode: 图不大于框则原图, 否则缩放
-- @param [in] key[string]
-- @return mode[string]  default / resize
local function _left_mode(key)
	local mode = 'default'
	if type(kgui.image_size) ~= 'function' then
		return mode
	end

	local iw, ih = kgui.image_size(key)
	iw = tonumber(iw) or 0
	ih = tonumber(ih) or 0
	if iw < 1 or ih < 1 then
		return mode
	end

	local bw, bh = _left_box_wh()
	if bw < iw or bh < ih then
		mode = 'resize'
	end

	return mode
end


local function _show_image(key)
	if type(key) ~= 'string' then
		return
	end

	jq('pic').set('image', key)
	jq('pic_png').set('image', key)
	if key == '' then
		return
	end

	jq('pic_png').set('background-image-mode', _left_mode(key))
end


local function _onload()
	if g_filled then
		return
	end

	g_filled = true

	local items = _list_all()
	local pick = _pick_default(items)

	_fill_combo('cmb_img', items, pick)
	if pick ~= nil then
		_show_image(pick.key)
	end
end


local function _on_img()
	local key = jq('cmb_img').value()
	if type(key) ~= 'string' or key == '' then
		return
	end

	_show_image(key)
	_lab(string.format(lang.str('KpictureImageFmt'), key), 'pic image=' .. key)
end


M.commands = {
	['page'] = {
		['onload'] = _onload,
	},
	['btn_get'] = {
		['click'] = function ()
			local title = jq('pic').get('title')
			local value = jq('pic').get('value')
			local image = jq('pic').get('image')
			local mode = jq('pic').get('background-image-mode')
			_lab(string.format(lang.str('KpictureGetFmt'),
				tostring(title), tostring(value), tostring(image), _mode_lab(mode)),
				string.format('get title=%s value=%s image=%s mode=%s',
					tostring(title), tostring(value), tostring(image), _mode_en(mode)))
		end,
	},
	['btn_set'] = {
		['click'] = function ()
			jq('pic').set('title', 'cover')
			jq('pic').set('value', 'cover1')
			_lab(lang.str('KpictureSet'), 'set pic title=cover value=cover1')
		end,
	},
	['cmb_img'] = {
		['onchange'] = _on_img,
	},
	['btn_clear'] = {
		['click'] = function ()
			_show_image('')
			_lab(lang.str('KpictureImageCleared'), 'pic image cleared')
		end,
	},
	['btn_mode_default'] = {
		['click'] = function ()
			_set_mode('default')
		end,
	},
	['btn_mode_resize'] = {
		['click'] = function ()
			_set_mode('resize')
		end,
	},
	['btn_mode_scale9'] = {
		['click'] = function ()
			_set_mode('scale9')
		end,
	},
	['btn_hide'] = {
		['click'] = function ()
			local vis = jq('pic').get('visibility')
			if 'hidden' == vis or false == vis then
				jq('pic').set('visibility', 'visible')
				_lab(lang.str('KpictureVisible'), 'pic visible')
			else
				jq('pic').set('visibility', 'hidden')
				_lab(lang.str('KpictureHidden'), 'pic hidden')
			end
		end,
	},
}


-- @brief 按语言更新本页文案
-- @param [in] code[string]
-- @return 无
M.apply_lang = function (code)
	if type(code) == 'string' and code ~= '' then
		lang.apply(code)
	end

	_set_title('hint', lang.str('KpictureHint'))
	_set_title('btn_get', lang.str('Get'))
	_set_title('btn_set', lang.str('Set'))
	_set_title('btn_hide', lang.str('ToggleHide'))
	_set_title('btn_clear', lang.str('ImageClear'))
	_set_title('btn_mode_default', lang.str('ModeDefault'))
	_set_title('btn_mode_resize', lang.str('ModeResize'))
	_set_title('btn_mode_scale9', lang.str('Scale9'))

	local mode = 'default'
	if type(jq) == 'function' then
		pcall(function ()
			local m = jq('pic').get('background-image-mode')
			if type(m) == 'string' and m ~= '' then
				mode = m
			end
		end)
	end

	_set_title('lab', string.format(lang.str('KpictureLabFmt'), _mode_lab(mode)))
end


-----------------------------------------------------------------------------------
-- 处理导出

M.css = {}
M.dialog = {}
M.jq = jq
M.jq0 = jq0


-- 重定向
M.relocation = function (rs)
	if 'HD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'WXGA' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'HD+' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'Full HD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'QHD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '4K UHD' == rs then
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
