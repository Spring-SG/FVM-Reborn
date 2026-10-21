if global.is_paused{
	exit
}
x += move_speed
y -= cvspeed
cvspeed -= cgravity
image_angle -= 2
if x > 2200 or y > 1200 or x < -200 or y < -200{
	instance_destroy()
}

if y >= thrower_y {
    // 击中地面，造成溅射伤害
	var grid_pos = get_grid_position_from_world(x,y)
	var inst = instance_create_depth(grid_pos.x,grid_pos.y,0,obj_panfriedbun_bullet_effect)
	inst.damage = round(damage*splash_ratio)
	inst.grid_row = grid_pos.row
	inst.shape = shape
	if shape >= 1{
		inst.sprite_index = spr_panfriedbun_bullet_effect_2
	}
    instance_destroy()
}
//if !atk_modified{
//	with obj_card_parent{
//		if plant_id == "fruit_tart"{
//			if grid_row == other.row && ((shape <= 1 && x >= other.x) || shape >= 2){
//				other.damage *= atk
//				other.atk_modified = true
//			}
//		}
//	}
//}