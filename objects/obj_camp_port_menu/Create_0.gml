image_xscale = 1
image_yscale = 1

// 整块面板的进出场过渡（从下方滑入 = 向上到位 + 淡入；关闭原路返回）
panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [obj_camp_port_close_btn, obj_camp_port_choose_btn])
instance_create_depth(x+780,y-480,depth-1,obj_camp_port_close_btn)
var btn = instance_create_depth(x-590,y+110,depth-1,obj_camp_port_choose_btn)
btn.sprite_index = spr_camp_port_desert_btn
btn.map_name = "沙漠之旅"
btn.map_id = "desert_trip"
btn.room_target = room_map
btn.level_require = 20

var btn2 = instance_create_depth(x-240,y-290,depth-1,obj_camp_port_choose_btn)
btn2.sprite_index = spr_camp_port_snowymountain_btn
btn2.map_name = "雷雪探险"
btn2.map_id = "thunder_snowy"
btn2.room_target = room_map
btn2.level_require = 99

var btn3 = instance_create_depth(x+230,y+40,depth-1,obj_camp_port_choose_btn)
btn3.sprite_index = spr_camp_port_thundercity_btn
btn3.map_name = "雷雪探险"
btn3.map_id = "thunder_snowy"
btn3.room_target = room_map
btn3.level_require = 99

var btn4 = instance_create_depth(x+540,y-230,depth-1,obj_camp_port_choose_btn)
btn4.sprite_index = spr_camp_port_wonderland_btn
btn4.map_name = "漫游奇境"
btn4.map_id = "wonderland_wondering"
btn4.room_target = room_map
btn4.level_require = 99
