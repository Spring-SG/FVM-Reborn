if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
}

switch state{
	case BOSS_STATE.IDLE:
		if !skill_3_style{
			sprite_index = spr_mouse_train_2_body_idle1
		}
		else{
			sprite_index = spr_mouse_train_2_body_idle2
		}
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 4
		}
		else{
			image_index = floor(timer/5) mod 4 + 4
		}
		//if timer >= wait_time{
		//	timer = 0
		//	if skill_choose == 0 {
		//		state = BOSS_STATE.SKILL1
		//	}
		//	else if skill_choose == 1{
		//		state = BOSS_STATE.SKILL2
		//	}
		//}
		break
		
	case BOSS_STATE.APPEAR:
		if timer <= 5 * 9 - 1{
			if !skill_3_style{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_appear1
				}
				else{
					sprite_index = spr_mouse_train_2_body_appear2
				}
			}
			else{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_appear3
				}
				else{
					sprite_index = spr_mouse_train_2_body_appear4
				}
			}
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 9
			}
			else{
				image_index = floor(timer/5) mod 9 + 9
			}
		}
		else{
			if !skill_3_style{
				sprite_index = spr_mouse_train_2_body_idle1
			}
			else{
				sprite_index = spr_mouse_train_2_body_idle2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 4
			}
			else{
				image_index = floor(timer/5) mod 4 + 4
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		
		if timer == move_time{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	
	case BOSS_STATE.SKILL1:
		if grid_row == 0{
			sprite_index = spr_mouse_train_2_body_skill_1_2
		}
		else{
			sprite_index = spr_mouse_train_2_body_skill_1_1
		}
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 40
		}
		else{
			image_index = floor(timer/5) mod 40 + 40
		}
		
		if timer >= 40*5 -1{
			move_time = 250 - move_time + 45
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		if grid_row == 0{
			sprite_index = spr_mouse_train_2_body_skill_2_2
		}
		else if grid_row == global.grid_rows-1{
			sprite_index = spr_mouse_train_2_body_skill_2_1
		}
		else{
			sprite_index = spr_mouse_train_2_body_skill_2_3
		}
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 63
		}
		else{
			image_index = floor(timer/5) mod 63 + 63
		}
		
		if timer >= 63*5 -1{
			move_time = 250 - move_time + 45
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_mouse_train_2_body_skill_3
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 63
		}
		else{
			image_index = floor(timer/5) mod 63 + 63
		}
		if timer == 27 * 5 + 2 || timer == 29 * 5 + 2{
			var bullet1 = instance_create_depth(x+80,y-80,-800,obj_mouse_train_2_bullet)
			bullet1.move_speed = 8
			bullet1.b_type = 0
			bullet1.image_angle = 0
			bullet1.grid_row = grid_row
			bullet1.grid_col = grid_col
			var bullet2 = instance_create_depth(x-80,y-80,-800,obj_mouse_train_2_bullet)
			bullet2.move_speed = -8
			bullet2.b_type = 0
			bullet2.image_angle = 180
			bullet2.grid_row = grid_row
			bullet2.grid_col = grid_col
			var bullet3 = instance_create_depth(x,y-180,-800,obj_mouse_train_2_bullet)
			bullet3.move_speed = -8
			bullet3.b_type = 1
			bullet3.image_angle = 90
			bullet3.grid_row = grid_row
			bullet3.grid_col = grid_col
			var bullet4 = instance_create_depth(x,y+20,-800,obj_mouse_train_2_bullet)
			bullet4.move_speed = 8
			bullet4.b_type = 1
			bullet4.image_angle = 270
			bullet4.grid_row = grid_row
			bullet4.grid_col = grid_col
		}
		if timer == 41 * 5 + 2 || timer == 43 * 5 + 2{
			var bullet1 = instance_create_depth(x+80,y-180,-800,obj_mouse_train_2_bullet)
			bullet1.move_speed = 8
			bullet1.b_type = 2
			bullet1.image_angle = 45
			bullet1.grid_row = grid_row
			bullet1.grid_col = grid_col
			var bullet2 = instance_create_depth(x-80,y-180,-800,obj_mouse_train_2_bullet)
			bullet2.move_speed = 8
			bullet2.b_type = 2
			bullet2.image_angle = 135
			bullet2.grid_row = grid_row
			bullet2.grid_col = grid_col
			var bullet3 = instance_create_depth(x-80,y+20,-800,obj_mouse_train_2_bullet)
			bullet3.move_speed = 8
			bullet3.b_type = 2
			bullet3.image_angle = 225
			bullet3.grid_row = grid_row
			bullet3.grid_col = grid_col
			var bullet4 = instance_create_depth(x+80,y+20,-800,obj_mouse_train_2_bullet)
			bullet4.move_speed = 8
			bullet4.b_type = 2
			bullet4.image_angle = 315
			bullet4.grid_row = grid_row
			bullet4.grid_col = grid_col
		}
		if timer >= 63*5 -1{
			move_time = 180
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		if timer <= move_time - 9 * 5{
			if !skill_3_style{
				sprite_index = spr_mouse_train_2_body_idle1
			}
			else{
				sprite_index = spr_mouse_train_2_body_idle2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 2
			}
			else{
				image_index = floor(timer/5) mod 2 + 2
			}
		}
		else{
			if !skill_3_style{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_disappear1
				}
				else{
					sprite_index = spr_mouse_train_2_body_disappear2
				}
			}
			else{
				if train_dir == 0{
					sprite_index = spr_mouse_train_2_body_disappear3
				}
				else{
					sprite_index = spr_mouse_train_2_body_disappear4
				}
			}
			if hp > maxhp * hurt_rate{
				image_index = floor((timer+5*9-move_time)/5) mod 9
			}
			else{
				image_index = floor((timer+5*9-move_time)/5) mod 9 + 9
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		
		if timer == move_time{
			image_alpha = 0
		}
		if timer == move_time{
			instance_destroy()
		}
		
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_mouse_train_2_body_death
		image_index = floor(timer/5) mod image_number
		if timer >= image_number * 5{
			image_alpha -= 0.1
			image_index = image_number - 1
		}
		break
}


timer ++


// 透明度处理
if (image_alpha <= 0 && state == BOSS_STATE.DEATH) {
    instance_destroy();
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -401
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

