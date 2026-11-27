// 强制清除application_surface，避免上一房间图像残留
// ⚠️ application_surface 可能短暂失效（值为 -1），直接用会抛 surface target does not exist
if (surface_exists(application_surface)){
	surface_set_target(application_surface);
	draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
	surface_reset_target();
}

global.menu_screen = false
instance_create_depth(1680,820,-2,obj_battlestart_button)
readyroom_music = mus_readyroom

// 主界面菜单栏（背包 / 商店 / 合成屋 / 任务 / 食神谱 / 情报 / 退出）
// 与菜单房、地图房同一套按钮、同一个锚点；备战房间没有 obj_player_info_ui，
// 菜单状态的读写统一走 scripts/menu_ui（见 obj_player_menu_btn 的点击事件）
instance_create_depth(room_width-205,room_height-5,-1,obj_player_menu_bg)

ds_list_clear(global.selected_deck);
deck_ensure_size();
//for(var i = 0;i < 21;i++){
//add_to_deck("xiao_long_bao",0);
//}
//add_to_deck("small_fire",get_card_info_simple("small_fire").shape);
//add_to_deck("flour_sack",get_card_info_simple("flour_sack").shape);
//add_to_deck("toast_bread",0)
//add_to_deck("toast_bread",0);
select_card_index = ds_list_create()
hover_card_index = -1
hover_slot_index = -1

// 卡片飞入卡槽的动画状态（线性匀速）
fly_active = false
fly_add = true
fly_t = 0
fly_dur = 1
fly_sx = 0
fly_sy = 0
fly_tx = 0
fly_ty = 0
fly_spr = -1
fly_card_id = ""
fly_slot = -1
fly_pool_i = -1
// 点「清空」时整批飞回卡池的动画（每条 = 一张卡；与上面单张的 fly_* 互不干扰）
fly_batch = []
hover_card_x = 0
hover_card_y = 0
hover_card_spr = -1
slot_rows = 11
slot_cols = 10
slot_surface = -1
map_surface = -1
y_offset = 0
y_offset_target = 0
// 滚动条状态（绘制与拖动都在 Draw_0 末尾，与滚轮共用 y_offset）
sb_dragging = false
sb_drag_y = 0
sb_drag_offset = 0

is_submenu_open = false

deck_first_slot_index = 0

selected_custom_deck = 0

var select_btn_spr_list = [spr_deck_select_btn_1,spr_deck_select_btn_2,spr_deck_select_btn_3,spr_deck_select_btn_4,spr_deck_select_btn_5,spr_deck_select_btn_6]
for(var i = 1; i < 7;i++){
	var inst = instance_create_depth(x+1023+79*i,y+227,depth-5,obj_deck_select_btn)
	inst.deck_index = i
	inst.sprite_index = select_btn_spr_list[i-1]
}
instance_create_depth(x+1730,y+225,depth-5,obj_deck_clear_btn)
instance_create_depth(x+1625,y+225,depth-5,obj_deck_save_btn)
instance_create_depth(x+703,y+455,depth-5,obj_ready_room_preview_btn)

var prev_btn = instance_create_depth(x+1745,y+105,depth-5,obj_readyroom_slot_btn)
prev_btn.type = "prev"
var next_btn = instance_create_depth(x+1745,y+155,depth-5,obj_readyroom_slot_btn)
next_btn.type = "next"

//统计敌人和BOSS类型
enemy_type_list = []
boss_type_list = []
for(var i = 0;i < global.level_file.total_waves;i ++){
	if global.level_file.waves[i].boss_wave{
		if array_get_index(boss_type_list,global.level_file.waves[i].boss) == -1{
			array_push(boss_type_list,global.level_file.waves[i].boss)
		}
		if is_real(global.level_file.version){
			if array_get_index(boss_type_list,global.level_file.waves[i].boss2) == -1 && global.level_file.waves[i].boss2 != ""{
				array_push(boss_type_list,global.level_file.waves[i].boss2)
			}
		}
	}
	var subwave = global.level_file.waves[i].subwaves
	for(var j = 0 ; j <array_length(subwave);j++){
		var enemy_list = subwave[j].enemy_list
		for(var k = 0 ; k < array_length(enemy_list);k++){
			if array_get_index(enemy_type_list,enemy_list[k].type) == -1{
				array_push(enemy_type_list,enemy_list[k].type)
			}
		}
	}
}