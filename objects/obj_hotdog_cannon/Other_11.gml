var inst = instance_create_depth(x+40,y-65,depth-500,obj_hotdogcannon_bullet)
inst.damage = atk
inst.move_speed = 8
inst.row = grid_row
inst.target_y = y-65
if has_air{
	inst.target_type = "air_only"
	inst.target_y = y-125
}