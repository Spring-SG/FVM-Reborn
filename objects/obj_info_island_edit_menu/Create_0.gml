image_xscale = 1.8
image_yscale = 1.8

target_card_index = -1
target_current_info = ds_map_create()
info_got = 0
view_max_shape = 0

//target_current_level = 9
//target_current_shape = 0
//target_current_skill = 0

var btn1 = instance_create_depth(x-180,y+160,depth-1,obj_info_island_card_edit_select_btn)
btn1.btn_type = "confirm"
btn1.btn_text = "确定"
var btn2 = instance_create_depth(x+180,y+160,depth-1,obj_info_island_card_edit_select_btn)
btn2.btn_type = "cancel"
btn2.btn_text = "取消"
var target_list = ["level","shape","skill"]

for(var i = 0 ; i< 3 ; i++){
	var btn3 = instance_create_depth(x-200,y-70+80*i,depth-1,obj_info_island_edit_menu_btn)
	btn3.btn_type = "min"
	btn3.target_info = target_list[i]
	btn3.target_card_index = target_card_index
	btn3.view_max_shape = view_max_shape
	var btn4 = instance_create_depth(x-130,y-70+80*i,depth-1,obj_info_island_edit_menu_btn)
	btn4.btn_type = "subtract"
	btn4.target_info = target_list[i]
	btn4.target_card_index = target_card_index
	btn4.view_max_shape = view_max_shape
	var btn5 = instance_create_depth(x+130,y-70+80*i,depth-1,obj_info_island_edit_menu_btn)
	btn5.btn_type = "plus"
	btn5.target_info = target_list[i]
	btn5.target_card_index = target_card_index
	btn5.view_max_shape = view_max_shape
	var btn6 = instance_create_depth(x+200,y-70+80*i,depth-1,obj_info_island_edit_menu_btn)
	btn6.btn_type = "max"
	btn6.target_info = target_list[i]
	btn6.target_card_index = target_card_index
	btn6.view_max_shape = view_max_shape
}

// 三级菜单淡入淡出（等级 1 起；子对象跟着一起淡）
panel_anim_init(id, 0.18, 0.14, 0, 3)
panel_anim_kids(id, [obj_info_island_card_edit_select_btn, obj_info_island_edit_menu_btn])

// ── 弹出（scale in）：由小到大弹开 ──
// 绕面板中心缩放；子对象位置按同一比例向中心收/放，精灵同步缩放
// 曲线 ease-out back：0.84 → 1，终点轻微过冲后回落，保留体积感
pop_t = 0
pop_dur = 0.20          // 秒
pop_from = 0.84         // 起始缩放（相对终态）
pop_s = pop_from
pop_p = 0               // 1 = 已播完
pop_base_s = image_xscale
with (obj_info_island_card_edit_select_btn){
pop_bx = x; pop_by = y; pop_sx = image_xscale
}
with (obj_info_island_edit_menu_btn){
pop_bx = x; pop_by = y; pop_sx = image_xscale
}
