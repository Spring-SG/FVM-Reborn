if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}

timer++

// 持续让 3*3 范围内的卡片处于睡眠状态（玩家角色 obj_player_character 也是卡片子对象，排除掉）
with obj_card_parent{
	if abs(grid_row - other.grid_row) <= 1 && abs(grid_col - other.grid_col) <= 1 && plant_id != "player"{
		if array_get_index(other.slept_card_id_list,id) == -1{
			array_push(other.slept_card_id_list,id)
		}
		state = CARD_STATE.SLEEP
		awake_buff_timer = 0     // 压住唤醒计时，保证范围内卡片持续沉睡
	}
}

// 到期后领域消失，被睡过的卡片复原
if timer >= life_time{
	with obj_card_parent{
		if array_get_index(other.slept_card_id_list,id) != -1 && state == CARD_STATE.SLEEP{
			if awake_anim > 0{
				state = CARD_STATE.AWAKE
			}
			else{
				state = CARD_STATE.IDLE
			}
		}
	}
	instance_destroy()
}
