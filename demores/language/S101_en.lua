--[[
-- Doc-Encode UTF8
-- 命名: SMN_<lang>.lua; 词条 key 以本文件 (en) 为准, 其它语言须同步
--]]

local M = {

    -- 通用基础词汇
    ['Ok'] = 'OK',
    ['Cancel'] = 'Cancel',
    ['Save'] = 'Save',
    ['Close'] = 'Close',
    ['Copy'] = 'Copy',
    ['Pass'] = 'Pass',
    ['Fail'] = 'Fail',
    ['Get'] = 'Get',
    ['Set'] = 'Set',
    ['Open'] = 'Open',

    -- lua test 1.1.1
    ['Resolution'] = 'Resolution',
    ['Language'] = 'Language',
    ['FontSize'] = 'Font size',
    ['FontFace'] = 'Font',
    ['Appearance'] = 'Appearance',
    ['AppearancePlain'] = 'plain (no image)',
    ['AppearanceDark'] = 'dark (VS Code)',
    ['AppearanceWin11Dark'] = 'Win11 dark',
    ['AppearanceIosDark'] = 'iOS dark',
    ['AppearanceMaterialDark'] = 'Material dark',
    ['AppearanceGithubDark'] = 'GitHub dark',
    ['AppearanceLight'] = 'light (Windows XP)',
    ['AppearanceFluent'] = 'fluent (Windows 11)',
    ['HintSelectResLang'] = 'Select resolution, language, font size, font and appearance',
    ['HintSaved'] = 'Saved. Font size, font and colors apply now. Resolution and images apply on next launch.',
    ['Config'] = 'Config',

    -- lua test 1.3.3
    ['KpictureHint'] = '1.3.3 kpicture image combo; left fit, same image',
    ['KpictureLabFmt'] = 'kpicture %s',
    ['ToggleHide'] = 'Toggle hide',
    ['KpictureFmtImage'] = 'image',
    ['ImageClear'] = 'Clear',
    ['ModeDefault'] = 'default',
    ['ModeResize'] = 'resize',
    ['Scale9'] = 'scale9',
    ['KpictureGetFmt'] = 'get title=%s value=%s image=%s mode=%s',
    ['KpictureSet'] = 'set pic title=cover value=cover1',
    ['KpictureImageCleared'] = 'pic image cleared',
    ['KpictureImageFmt'] = 'pic image=%s',
    ['KpictureModeFmt'] = 'pic mode=%s',
    ['KpictureVisible'] = 'pic visible',
    ['KpictureHidden'] = 'pic hidden',

    -- lua test 1.2.1
    ['KdialogHint'] = '1.2.1 kdialog title/value',
    ['KdialogLabFmt'] = 'kdialog title=%s',
    ['KdialogTitle'] = 'Dialog',
    ['KdialogTitle2'] = 'Dialog2',
    ['KdialogBody'] = 'body',
    ['KdialogGetFmt'] = 'get title=%s value=%s',
    ['KdialogSet'] = 'set dlg title=Dialog2 value=dlg2',
    ['KdialogVisible'] = 'dlg visible',
    ['KdialogHidden'] = 'dlg hidden',

    -- lua test 1.2.2
    ['KviewHint'] = '1.2.2 kview title/bg/hide',
    ['KviewLabFmt'] = 'kview title=%s',
    ['KviewTitle'] = 'View',
    ['KviewTitle2'] = 'View2',
    ['KviewBody'] = 'body',
    ['KviewGetFmt'] = 'get title=%s',
    ['KviewSet'] = 'set box title=View2 bg',
    ['KviewVisible'] = 'box visible',
    ['KviewHidden'] = 'box hidden',

    -- lua test 1.2.3
    ['Tab1'] = 'Tab1',
    ['Tab2'] = 'Tab2',
    ['KtabHint'] = '1.2.3 ktab pages',
    ['KtabLabFmt'] = 'ktab title=%s',
    ['KtabGetFmt'] = 'get title=%s',
    ['KtabBody1'] = 'page 1',
    ['KtabBody2'] = 'page 2',

    -- lua test 1.2.4
    ['Item1'] = 'Item1',
    ['Item2'] = 'Item2',
    ['Item3'] = 'Item3',
    ['KmenuHint'] = '1.2.4 kmenu append/onchange',
    ['KmenuLabFmt'] = 'kmenu value=%s',
    ['KmenuGetFmt'] = 'get value=%s',

    -- lua test 1.2.5
    ['KdivHint'] = '1.2.5 kdiv title/index/hide',
    ['KdivLabFmt'] = 'kdiv title=%s index=%s',
    ['KdivTitle'] = 'Div',
    ['KdivTitle2'] = 'Div2',
    ['KdivBody'] = 'body',
    ['KdivGetFmt'] = 'get title=%s index=%s',
    ['KdivSet'] = 'set box title=Div2 index=2',
    ['KdivVisible'] = 'box visible',
    ['KdivHidden'] = 'box hidden',

    -- lua test 1.2.6
    ['KmodalHint'] = '1.2.6 modal overlay',
    ['KmodalLabFmt'] = 'modal num=%s',
    ['KmodalTitle'] = 'Modal',
    ['KmodalBody'] = 'overlay',

    -- lua test 1.2.7
    ['KpopupHint'] = '1.2.7 popup kmenu',
    ['KpopupLabFmt'] = 'popup value=%s num=%s',

    -- lua test 1.2.8
    ['KmsgHint'] = '1.2.8 messagebox',
    ['KmsgLabFmt'] = 'messagebox value=%s num=%s',
    ['KmsgTitle'] = 'Message',
    ['KmsgBody'] = 'confirm or cancel',
}


M[1] = 'en'		--内部关键字; 判定与存储配置
M[2] = 'English'		--UI显示描述

return M
-- 翻译行数 : 86
