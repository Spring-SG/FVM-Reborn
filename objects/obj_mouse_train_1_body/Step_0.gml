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
		sprite_index = spr_mouse_train_1_body_idle
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 3
		}
		else{
			image_index = floor(timer/5) mod 3 + 3
		}
		if timer >= wait_time{
			timer = 0
			if skill_choose == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_choose == 1{
				state = BOSS_STATE.SKILL2
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_mouse_train_1_body_idle
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 3
		}
		else{
			image_index = floor(timer/5) mod 3 + 3
		}
		
		if (skill_choose == 1 && skill_change_style == 0)||(skill_choose == 1 && skill_change_style == 1 && is_reversed){
			y += 4
		}
		else{
			y -= 4
		}
		
		if timer == move_time{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_mouse_train_1_body_skill_1
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 42
		}
		else{
			image_index = floor(timer/5) mod 42 + 42
		}
		
		if timer mod (23 * 5) == 14 * 5 - 2{
			//var inst = instance_create_depth(x-45,y-30,depth,obj_xiaoming_text)
			if jump_times == 1{
				//inst.sprite_index = spr_xiaoming_text_2
			}
			if jump_times == 2{
				//inst.sprite_index = spr_xiaoming_text_3
			}
		}
		
		if timer >= 42*5 -1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_mouse_train_1_body_skill_2
		if skill_change_style == 0{
			sprite_index = spr_mouse_train_1_body_skill_4
		}
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 27
		}
		else{
			image_index = floor(timer/5) mod 27 + 27
		}
		
		if timer >= 27*5 -1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_mouse_train_1_body_idle
		if train_head.hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 3
		}
		else{
			image_index = floor(timer/5) mod 3 + 3
		}
		
		if (skill_choose == 1 && skill_change_style == 0) || (skill_choose == 1 && skill_change_style == 1  && is_reversed){
			y += 4
		}
		else{
			y -= 4
		}
		
		if timer == 430{
			instance_destroy()
		}
		
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_mouse_train_1_body_death
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

