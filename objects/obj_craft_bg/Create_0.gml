image_xscale = 0.9
image_yscale = 0.9

is_submenu_opened = false
button_select = 0

instance_create_depth(x+785,y-466,depth-1,obj_closecraft_btn)
instance_create_depth(x-305,y+220,depth-1,obj_craft_confirm_btn)

var btn1 = instance_create_depth(x-661,y-50,depth-1,obj_craft_select_btn)
btn1.button_index = 0
btn1.text_spr = spr_craft_card_text
var btn2 = instance_create_depth(x-661,y+100,depth-1,obj_craft_select_btn)
btn2.button_index = 1
btn2.text_spr = spr_craft_gem_text

card_material_id_list = ["natural_spices","secret_spices","royal_spices","clover_1","clover_2","clover_3","clover_4"]
gem_material_id_list = ["less_crystal","middle_crystal","advanced_crystal"]


hover_card_index = -1
hover_gem_index = -1
close_timer = -1

y_offset = 0
y_offset_target = 0
// 滚动条状态（绘制与拖动都在 Draw_0 末尾，与滚轮共用 y_offset）
sb_dragging = false
sb_drag_y = 0
sb_drag_offset = 0
card_surface = -1

current_uprade_target_id = ""

spices_use_order = ["natural_spices","secret_spices","royal_spices"]
clover_use_order = ["clover_1","clover_2","clover_3","clover_4"]
crystal_use_order = ["less_crystal","middle_crystal","advanced_crystal"]

// 整块面板的进出场过渡（实现在 scripts/GuiStack/GuiStack.gml）
panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [obj_closecraft_btn, obj_craft_select_btn, obj_craft_confirm_btn])

// 合成屋的三个元素（房间坐标 1920x1080，对着绘制坐标算的）：[x1,y1,x2,y2,dx,dy]，dx/dy = 从哪边来
craft_parts = [[130,  15, 1096,  900, -1, 0],   // 左上板块（卡片/宝石强化台）：从左边
               [130, 900, 1096, 1065,  0, 1],   // 下面的道具条：从下边
               [1096, 15, 1790, 1065,  1, 0]]   // 右边的素材格：从右边