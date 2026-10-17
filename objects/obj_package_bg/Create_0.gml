image_xscale = 1.8
image_yscale = 1.8
instance_create_depth(x+380,y+403,depth-1,obj_closepackage_btn)
package_cols = 9 //背包格子行列数
package_rows = 16
// 滚动条状态（绘制与拖动在 Draw_0 末尾，与滚轮共用 y_offset）
sb_dragging = false
sb_drag_y = 0
sb_drag_offset = 0
info_button_select = 1
package_button_select = 1
is_submenu_opened = false
gem_start_line = 0
y_offset = 0
y_offset_target = 0
package_surface = -1
//创建背包栏位选择按钮
var btn1 = instance_create_depth(x-300,y-455,depth-1,obj_packageselect_btn)
btn1.type = "Package"
btn1.button_index = 1
btn1.sprite_index = spr_packageselect_btn_1
var btn2 = instance_create_depth(x-70,y-455,depth-1,obj_packageselect_btn)
btn2.type = "Package"
btn2.button_index = 2
btn2.sprite_index = spr_packageselect_btn_2
var btn5 = instance_create_depth(x+160,y-455,depth-1,obj_packageselect_btn)
btn5.type = "Package"
btn5.button_index = 3
btn5.sprite_index = spr_packageselect_btn_5
var btn3 = instance_create_depth(x-1170,y-454,depth-1,obj_packageselect_btn)
btn3.type = "Player Info"
btn3.button_index = 1
btn3.sprite_index = spr_packageselect_btn_3
var btn4 = instance_create_depth(x-1020,y-454,depth-1,obj_packageselect_btn)
btn4.type = "Player Info"
btn4.button_index = 2
btn4.sprite_index = spr_packageselect_btn_4
var btn6 = instance_create_depth(x-870,y-454,depth-1,obj_packageselect_btn)
btn6.type = "Player Info"
btn6.button_index = 3
btn6.sprite_index = spr_packageselect_btn_6

hover_card_index = -1; // 当前悬停的卡片索引
hover_weapon_index = -1
hover_gem_index = -1
hover_material_index = -1
view_max_shapes = 0

// 整块面板的进出场过渡（左右分半滑入；实现在 scripts/GuiStack/GuiStack.gml）
// 分界线 951：与情报岛同一接缝（素材几何硬算 955~956，实机取 951）
panel_anim_init(id, 0.28, 0.18, 260, 1)

// ── 页签切换：整页淡入（旧页当帧消失，不做退场）──
// 左右两半各有自己的计时器：点左半的标签只淡左半，点右半只淡右半
pg_t_l    = -1;    // 左半（Player Info）页签：-1 = 无动画；>=0 = 动画帧号（0 = 全透明）
pg_t_r    = -1;    // 右半（Package）页签：同上
pg_frames = 13;    // 时长（帧），60fps ≈ 0.22s
// 子菜单（卡片/宝石信息编辑、卡片时装选择）是独立实例，必须一起登记，否则关面板时它们留在屏幕上
// （注意不含 obj_info_island_bg —— 情报岛是另一套独立过渡，不归背包管）
panel_anim_kids(id, [obj_closepackage_btn, obj_packageselect_btn,
                          obj_card_edit_menu, obj_card_edit_select_btn, obj_card_edit_btn,
                          obj_card_attire_menu, obj_card_attire_select_btn,
                          obj_gem_edit_menu, obj_gem_edit_select_btn, obj_gem_edit_btn])