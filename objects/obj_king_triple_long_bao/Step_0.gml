if global.is_paused{
	exit
}

sprite_index = normal_spr_list[bun_count]
if bun_count >= max_bun{
	if bun_count > max_bun{
		bun_count = max_bun
	}
	feature_type = "normal"
}
event_inherited(); 

if is_frozen || state == CARD_STATE.SLEEP{
	exit
}

//升级逻辑
if state == CARD_STATE.GROW{
	sprite_index = upgrade_spr_list[bun_count-1]
	image_index = floor(upgrade_timer/5)
	upgrade_timer ++
	if upgrade_timer >= 49{
		state = CARD_STATE.IDLE
		sprite_index = normal_spr_list[bun_count]
		upgrade_timer = 0
	}
}

var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

with obj_card_parent{
	if (feature_type == "tbun" || feature_type == "king_tbun")&&id!=other.id{
		if grid_row == other.grid_row && grid_col == other.grid_col{
			for(var i = 0 ; i < array_length(other.bun_card_info) ; i++){
				if plant_id == other.bun_card_info[i].card_id{
					var can_absorb = false
					for(var j = 0 ; j < other.bun_card_info[i].bun_amount ; j++){
						if other.bun_count < other.max_bun{
							other.bun_count++
							array_push(other.bullet_list,{"bullet_type":other.bun_card_info[i].bullet_type,"damage":atk})
							can_absorb = true
						}
					}
					if other.shape >= 2{
						if other.bun_count < other.max_bun{
							other.bun_count++
							array_push(other.bullet_list,{"bullet_type":other.bun_card_info[i].bullet_type,"damage":atk})
						}
					}
					if can_absorb{
						other.state = CARD_STATE.GROW
						instance_destroy()
					}
					break
				}
			}
		}
	}
}

//升级时停止攻击检测
if state == CARD_STATE.GROW{
	exit
}
//检测自身右方是否有敌人
var has_enemy = false
with(obj_enemy_parent){
	if (((grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1)) || abs(x - other.x) <= 100)&& can_target_on(other.target_type,target_type)){
		has_enemy = true
		break
	}
}
//攻击逻辑
if (has_enemy) {
    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    } else if (attack_timer <= cycle) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
        event_user(1); // 发射子弹
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}


