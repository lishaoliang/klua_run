--[[
-- Doc-Encode UTF8
-- 命名: SMN_<lang>.lua; 词条 key 以 S101_en.lua 为准, 须同步
--]]

local M = {

    -- 通用基础词汇
    ['Ok'] = '确定',
    ['Cancel'] = '取消',
    ['Save'] = '保存',
    ['Close'] = '关闭',
    ['Copy'] = '复制',
    ['Pass'] = '通过',
    ['Fail'] = '失败',
    ['Get'] = '获取',
    ['Set'] = '设置',
    ['Open'] = '打开',

    -- lua test 1.1.1
    ['Resolution'] = '分辨率',
    ['Language'] = '语言',
    ['FontSize'] = '字体大小',
    ['FontFace'] = '字体',
    ['Appearance'] = '外观',
    ['AppearancePlain'] = '纯色 (无图片)',
    ['AppearanceDark'] = 'VS Code 黑色',
    ['AppearanceWin11Dark'] = 'Win11 深色',
    ['AppearanceIosDark'] = 'iOS 深色',
    ['AppearanceMaterialDark'] = 'Material 深色',
    ['AppearanceGithubDark'] = 'GitHub 深色',
    ['AppearanceLight'] = 'XP 蓝色',
    ['AppearanceFluent'] = 'Win11 浅色',
    ['HintSelectResLang'] = '选择分辨率, 语言, 字体大小, 字体和外观',
    ['HintSaved'] = '已保存. 字体大小, 字库与配色立即生效. 分辨率与是否加载图片下次开窗生效.',
    ['Config'] = '配置',

    -- lua test 1.3.3
    ['KpictureHint'] = '1.3.3 kpicture 选图; 左示意图自适应, 左右同图',
    ['KpictureLabFmt'] = 'kpicture %s',
    ['ToggleHide'] = '切换隐藏',
    ['KpictureFmtImage'] = '选图',
    ['ImageClear'] = '清空',
    ['ModeDefault'] = '原图',
    ['ModeResize'] = '缩放',
    ['Scale9'] = 'scale9',
    ['KpictureGetFmt'] = 'get title=%s value=%s image=%s mode=%s',
    ['KpictureSet'] = 'set pic title=cover value=cover1',
    ['KpictureImageCleared'] = '已清空图片',
    ['KpictureImageFmt'] = '图片=%s',
    ['KpictureModeFmt'] = '模式=%s',
    ['KpictureVisible'] = '图片可见',
    ['KpictureHidden'] = '图片隐藏',

    -- lua test 1.2.1
    ['KdialogHint'] = '1.2.1 kdialog 标题/值',
    ['KdialogLabFmt'] = 'kdialog 标题=%s',
    ['KdialogTitle'] = '对话框',
    ['KdialogTitle2'] = '对话框2',
    ['KdialogBody'] = '内容',
    ['KdialogGetFmt'] = 'get title=%s value=%s',
    ['KdialogSet'] = 'set dlg title=Dialog2 value=dlg2',
    ['KdialogVisible'] = '对话框可见',
    ['KdialogHidden'] = '对话框隐藏',

    -- lua test 1.2.2
    ['KviewHint'] = '1.2.2 kview 标题/底色/隐藏',
    ['KviewLabFmt'] = 'kview 标题=%s',
    ['KviewTitle'] = '视图',
    ['KviewTitle2'] = '视图2',
    ['KviewBody'] = '内容',
    ['KviewGetFmt'] = 'get title=%s',
    ['KviewSet'] = 'set box title=View2 bg',
    ['KviewVisible'] = '视图可见',
    ['KviewHidden'] = '视图隐藏',

    -- lua test 1.2.3
    ['Tab1'] = '页1',
    ['Tab2'] = '页2',
    ['KtabHint'] = '1.2.3 ktab 页签',
    ['KtabLabFmt'] = 'ktab 标题=%s',
    ['KtabGetFmt'] = 'get title=%s',
    ['KtabBody1'] = '第1页',
    ['KtabBody2'] = '第2页',

    -- lua test 1.2.4
    ['Item1'] = '项1',
    ['Item2'] = '项2',
    ['Item3'] = '项3',
    ['KmenuHint'] = '1.2.4 kmenu 追加/变更',
    ['KmenuLabFmt'] = 'kmenu 值=%s',
    ['KmenuGetFmt'] = 'get value=%s',

    -- lua test 1.2.5
    ['KdivHint'] = '1.2.5 kdiv 标题/序号/隐藏',
    ['KdivLabFmt'] = 'kdiv 标题=%s 序号=%s',
    ['KdivTitle'] = '分区',
    ['KdivTitle2'] = '分区2',
    ['KdivBody'] = '内容',
    ['KdivGetFmt'] = 'get title=%s index=%s',
    ['KdivSet'] = 'set box title=Div2 index=2',
    ['KdivVisible'] = '分区可见',
    ['KdivHidden'] = '分区隐藏',

    -- lua test 1.2.6
    ['KmodalHint'] = '1.2.6 modal 叠层',
    ['KmodalLabFmt'] = 'modal 数=%s',
    ['KmodalTitle'] = '模态',
    ['KmodalBody'] = '叠层',

    -- lua test 1.2.7
    ['KpopupHint'] = '1.2.7 popup 菜单',
    ['KpopupLabFmt'] = 'popup 值=%s 数=%s',

    -- lua test 1.2.8
    ['KmsgHint'] = '1.2.8 messagebox',
    ['KmsgLabFmt'] = 'messagebox 值=%s 数=%s',
    ['KmsgTitle'] = '消息',
    ['KmsgBody'] = '确认或取消',
}


M[1] = 'zh'		--内部关键字; 判定与存储配置
M[2] = '简体中文'		--UI显示描述

return M
-- 翻译行数 : 86
