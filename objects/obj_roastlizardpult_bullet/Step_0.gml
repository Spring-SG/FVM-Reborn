if global.is_paused{
	exit
}
x += move_speed
y -= cvspeed
cvspeed -= cgravity
image_angle -= 5
if x > 2200 or y > 1200 or x < -200 or y < -200{
	instance_destroy()
}
// 检查是否落地
if y >= thrower_y {
    // 击中地面，造成溅射伤害
    var inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
	inst.sprite_index = spr_roast_lizard_pult_bullet_effect
    instance_destroy()
}
if !atk_modified{
	with obj_card_parent{
		if plant_id == "fruit_tart"{
			if grid_row == other.row && ((shape <= 1 && x >= other.x) || shape >= 2){
				other.damage *= atk
				other.atk_modified = true
			}
		}
	}
}