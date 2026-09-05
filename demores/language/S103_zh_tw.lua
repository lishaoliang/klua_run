--[[
-- Doc-Encode UTF8
-- 命名: SMN_<lang>.lua; 词条 key 以 S101_en.lua 为准, 须同步
--]]

local M = {

    -- 通用基础词汇
    ['Ok'] = '確定',
    ['Cancel'] = '取消',
    ['Save'] = '儲存',
    ['Close'] = '關閉',
    ['Copy'] = '複製',
    ['Pass'] = '通過',
    ['Fail'] = '失敗',
    ['Get'] = '取得',
    ['Set'] = '設定',
    ['Open'] = '開啟',

    -- lua test 1.1.1
    ['Resolution'] = '解析度',
    ['Language'] = '語言',
    ['FontSize'] = '字體大小',
    ['FontFace'] = '字體',
    ['Appearance'] = '外觀',
    ['AppearancePlain'] = '純色 (無圖片)',
    ['AppearanceDark'] = 'VS Code 黑色',
    ['AppearanceWin11Dark'] = 'Win11 深色',
    ['AppearanceIosDark'] = 'iOS 深色',
    ['AppearanceMaterialDark'] = 'Material 深色',
    ['AppearanceGithubDark'] = 'GitHub 深色',
    ['AppearanceLight'] = 'XP 藍色',
    ['AppearanceFluent'] = 'Win11 淺色',
    ['HintSelectResLang'] = '選擇解析度, 語言, 字體大小, 字體與外觀',
    ['HintSaved'] = '已儲存. 字體大小, 字庫與配色立即生效. 解析度與是否載入圖片下次開窗生效.',
    ['Config'] = '設定',

    -- lua test 1.3.3
    ['KpictureHint'] = '1.3.3 kpicture 選圖; 左示意圖自適應, 左右同圖',
    ['KpictureLabFmt'] = 'kpicture %s',
    ['ToggleHide'] = '切換隱藏',
    ['KpictureFmtImage'] = '選圖',
    ['ImageClear'] = '清空',
    ['ModeDefault'] = '原圖',
    ['ModeResize'] = '縮放',
    ['Scale9'] = 'scale9',
    ['KpictureGetFmt'] = 'get title=%s value=%s image=%s mode=%s',
    ['KpictureSet'] = 'set pic title=cover value=cover1',
    ['KpictureImageCleared'] = '已清空圖片',
    ['KpictureImageFmt'] = '圖片=%s',
    ['KpictureModeFmt'] = '模式=%s',
    ['KpictureVisible'] = '圖片可見',
    ['KpictureHidden'] = '圖片隱藏',

    -- lua test 1.2.1
    ['KdialogHint'] = '1.2.1 kdialog 標題/值',
    ['KdialogLabFmt'] = 'kdialog 標題=%s',
    ['KdialogTitle'] = '對話框',
    ['KdialogTitle2'] = '對話框2',
    ['KdialogBody'] = '內容',
    ['KdialogGetFmt'] = 'get title=%s value=%s',
    ['KdialogSet'] = 'set dlg title=Dialog2 value=dlg2',
    ['KdialogVisible'] = '對話框可見',
    ['KdialogHidden'] = '對話框隱藏',

    -- lua test 1.2.2
    ['KviewHint'] = '1.2.2 kview 標題/底色/隱藏',
    ['KviewLabFmt'] = 'kview 標題=%s',
    ['KviewTitle'] = '檢視',
    ['KviewTitle2'] = '檢視2',
    ['KviewBody'] = '內容',
    ['KviewGetFmt'] = 'get title=%s',
    ['KviewSet'] = 'set box title=View2 bg',
    ['KviewVisible'] = '檢視可見',
    ['KviewHidden'] = '檢視隱藏',

    -- lua test 1.2.3
    ['Tab1'] = '頁1',
    ['Tab2'] = '頁2',
    ['KtabHint'] = '1.2.3 ktab 頁籤',
    ['KtabLabFmt'] = 'ktab 標題=%s',
    ['KtabGetFmt'] = 'get title=%s',
    ['KtabBody1'] = '第1頁',
    ['KtabBody2'] = '第2頁',

    -- lua test 1.2.4
    ['Item1'] = '項1',
    ['Item2'] = '項2',
    ['Item3'] = '項3',
    ['KmenuHint'] = '1.2.4 kmenu 追加/變更',
    ['KmenuLabFmt'] = 'kmenu 值=%s',
    ['KmenuGetFmt'] = 'get value=%s',

    -- lua test 1.2.5
    ['KdivHint'] = '1.2.5 kdiv 標題/序號/隱藏',
    ['KdivLabFmt'] = 'kdiv 標題=%s 序號=%s',
    ['KdivTitle'] = '分區',
    ['KdivTitle2'] = '分區2',
    ['KdivBody'] = '內容',
    ['KdivGetFmt'] = 'get title=%s index=%s',
    ['KdivSet'] = 'set box title=Div2 index=2',
    ['KdivVisible'] = '分區可見',
    ['KdivHidden'] = '分區隱藏',

    -- lua test 1.2.6
    ['KmodalHint'] = '1.2.6 modal 疊層',
    ['KmodalLabFmt'] = 'modal 數=%s',
    ['KmodalTitle'] = '模態',
    ['KmodalBody'] = '疊層',

    -- lua test 1.2.7
    ['KpopupHint'] = '1.2.7 popup 選單',
    ['KpopupLabFmt'] = 'popup 值=%s 數=%s',

    -- lua test 1.2.8
    ['KmsgHint'] = '1.2.8 messagebox',
    ['KmsgLabFmt'] = 'messagebox 值=%s 數=%s',
    ['KmsgTitle'] = '訊息',
    ['KmsgBody'] = '確認或取消',
}


M[1] = 'zh_tw'		--内部关键字; 判定与存储配置
M[2] = '繁體中文'		--UI显示描述

return M
-- 翻译行数 : 86
