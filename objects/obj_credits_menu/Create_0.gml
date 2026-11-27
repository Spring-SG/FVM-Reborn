/// 致谢页面：一层黑色半透明遮罩 + 文字 + 底部 5 个链接按钮，没有底版
/// 打开/关闭动效走 GuiStack 通用面板接口（设置里动效等级 0 时由 panel_anim_step 直接瞬开）
/// 退出方式：ESC（obj_menu_manager / obj_map_manager 的 ESC 链）或 鼠标右键（本对象的 Step）

image_xscale = 1
image_yscale = 1

// ── 版式：没有底版，整块内容以屏幕中心排版（标签右对齐、姓名左对齐）──
// 名单 7 行 + 底部一排 5 个按钮要挤进一屏，行距从 58 收到 48
cx = x
cy = y
title_y = cy - 296      // 标题中心
sub_y   = cy - 252      // 副标题顶部
row_y0  = cy - 156      // 第一行的垂直中心
row_dy  = 48
hint_y  = cy + 258      // 底部提示顶部
label_x = cx - 40       // 标签右边界
name_x  = cx + 40       // 姓名左边界

// ── 名单 ──
credits = [
	["主程序",     "Spring曙光"],
	["代码贡献",     "staystart  苏格拉底的开始  比漆黑更黑的黑暗  碘化钾化镓"],
	["关卡设计",     "启蒙丶起点  泪-永恒  Spring曙光  VESPERHOST"],
	["美术资源",     "绛音ジャイイン  FVM进化版制作组"],
	["战斗平衡",     "泪-永恒"],
	["实验室关卡",     "老灵夜  VESPERHOST  泪-永恒"],
]

// ── 底部 5 个链接按钮（spr_common_button：0 = 普通 / 1 = 悬停 / 2 = 按下）──
// [显示文字, 打开地址, 悬停提示]；地址一律带协议头，url_open 才能交给系统浏览器
links = [
	["B站主页",    "https://space.bilibili.com/525306447",    ""],
	["社区主页",   "https://fvm-reb.top",                     ""],
	["爱发电",     "https://afdian.com/a/FVM_Reborn",         "支持我们的创作！"],
	["开源仓库", "https://github.com/Spring-SG/FVM-Reborn", ""],
	["游戏主页",   "https://www.fvm-reb.top/main",            ""],
]
btn_w     = 132
btn_h     = 56
btn_gap   = 18
btn_y     = cy + 190                                          // 按钮行的垂直中心
// 注意：spr_common_button 的 .yy 里 width/height 记的是 78×33（贴图 156×66 的一半），
// sprite_get_width() 返回的也是 78 —— 直接拿它算缩放会翻倍、按钮互相盖住，所以按常量写死
btn_px_w  = 156
btn_px_h  = 66
btn_sc    = btn_w / btn_px_w                                  // 132 / 156 ≈ 0.846
btn_x0    = cx - (array_length(links) * btn_w + (array_length(links) - 1) * btn_gap) * 0.5
btn_hover = -1
btn_armed = -1

// 进出场：0.28s 进 / 0.18s 出，文字整块从下方滑入 260px（设置面板同款）
panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [])
