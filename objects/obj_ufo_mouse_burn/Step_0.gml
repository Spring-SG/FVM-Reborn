if global.is_paused{
	image_speed = 0
	exit
}
image_speed = 1
timer++

// 第一帧才建岩浆：obj_ufo_mouse_burn 的 col/row 是创建后由飞碟鼠赋值的
if timer == 1{
	var _pos = get_world_position_from_grid(col, row)
	lava_inst = instance_create_depth(_pos.x, _pos.y - 35, -1200, obj_lava)
	lava_inst.row = row
	lava_inst.col = col
	lava_inst.depth = calculate_plant_depth(col, row, "coffee")
}

// 燃烧特效与岩浆同时存在 30 秒，到点一起消失
if timer >= 30 * 60{
	if instance_exists(lava_inst){
		instance_destroy(lava_inst)
	}
	instance_destroy()
}