// obj_level_guide_confirm - Create Event
// 关卡引导确认窗：备战房间里玩家没带关键卡片就点「开始战斗」时弹出
// （由 obj_battlestart_button 创建，创建后覆盖 message / title）
// 外观与交互沿用 obj_quit_confirm：spr_battle_escape_menu + spr_common_button
bg = spr_battle_escape_menu;
width = sprite_get_width(bg);
height = sprite_get_height(bg);

// 按钮定义
buttons = [
    [-80, "确定", 110, 40],
    [80, "取消", 110, 40]
];

selected_button = -1;
click_locked = false;   // 点过一次就锁住，避免淡出期间重复触发

// 由创建者覆盖：窗口标题 / 正文（正文可用 \n 换行）
title   = "携带提示";
message = "";

// 定位到屏幕中心
x = room_width / 2;
y = room_height / 2;

// 三级菜单淡入淡出（等级 1 起）
panel_anim_init(id, 0.18, 0.22, 0, 3)
panel_anim_kids(id, [])

// 弹窗弹出/回缩：GuiStack pop_anim_*（0.20s，ease-out back），关闭时反向缩回
pop_anim_init(id, [])