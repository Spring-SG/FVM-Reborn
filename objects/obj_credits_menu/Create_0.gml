/// 致谢页面（纯绘制）：整块从下方滑入 + 淡入，走 GuiStack 的通用面板动效
/// 打开/关闭时长与设置面板一致；动效等级 0（关闭动画）时由 panel_anim_step 内部直接瞬开

image_xscale = 1
image_yscale = 1

// ── 面板尺寸（以实例位置为中心）──
pw  = 880
ph  = 580
px1 = x - pw * 0.5
px2 = x + pw * 0.5
py1 = y - ph * 0.5
py2 = y + ph * 0.5

// ── 名单：左边一栏标题，右边一栏姓名 ──
credits = [
	["主要程序",     "Spring曙光"],
	["代码贡献",     "超级飞侠 · 苏格拉底的开始"],
	["关卡设计",     "启蒙-起点 · 泪-永恒 · Spring曙光"],
	["美术资源",     "绛音 · 十月"],
	["爱发电支持者", "待填写"],
]
row_y0 = py1 + 186      // 第一行文字的垂直中心
row_dy = 62

// ── 关闭按钮（纯绘制，与致谢入口按钮同一套配色）──
close_w = 136
close_h = 44
close_x1 = x - close_w * 0.5
close_x2 = x + close_w * 0.5
close_y2 = py2 - 48
close_y1 = close_y2 - close_h
close_hover = false
close_s     = 0

// 进出场：0.28s 进 / 0.18s 出，整块从下方滑入 260px（设置面板同款）
panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [])     // 纯绘制，没有子对象要跟着走