image_xscale = 0.9
image_yscale = 0.9
instance_create_depth(x+620,y-410,depth-1,obj_world_map_close_btn)
instance_create_depth(x+15,y-160,depth-1,obj_world_map_choose_btn)
var btn = instance_create_depth(x-365,y-85,depth-1,obj_world_map_choose_btn)
btn.sprite_index = spr_world_map_delicious_land
btn.map_name = "美味岛"
btn.map_id = "delicious_island"
btn.room_target = room_map

var btn2 = instance_create_depth(x-260,y+257,depth-1,obj_world_map_choose_btn)
btn2.sprite_index = spr_world_map_tower_cake
btn2.map_name = "魔塔蛋糕"
btn2.map_id = "tower_cake"
btn2.room_target = room_menu
btn2.level_require = 8

var btn3 = instance_create_depth(x+310,y+240,depth-1,obj_world_map_choose_btn)
btn3.sprite_index = spr_world_map_volcanic_island
btn3.map_name = "火山岛"
btn3.map_id = "volcanic_island"
btn3.room_target = room_map
btn3.level_require = 21

//var btn4 = instance_create_depth(x+402,y-170,depth-1,obj_world_map_choose_btn)
//btn4.sprite_index = spr_world_map_floating_island
//btn4.map_name = "浮空岛"
//btn4.map_id = "floating_island"
//btn4.room_target = room_map
//btn4.level_require = 41