if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_pos = get_world_position_from_grid(10,3)
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 1000
	timer = 0;
	state = BOSS_STATE.DEATH;
	target_plant = noone;  // 清除攻击目标
	// 技能3 催眠期间被击杀：立刻让全场卡片恢复
	release_hypno()
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = spr_medusa_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break

	case BOSS_STATE.APPEAR:
		// 到位后的待机，一轮动画播完再决定放哪个技能
		sprite_index = spr_medusa_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer == 12 * 5 - 1{
			timer = 0
			if skill_count == 0{
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL3
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			break
		}
		break

	case BOSS_STATE.SKILL1:
		// 技能1：给全场老鼠回血并提速
		sprite_index = spr_medusa_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 17
		}
		else{
			image_index = floor(timer/5) mod 17 + 17
		}

		if timer == 9 * 5{
			with obj_enemy_parent{
				if hp > 0{
					hp = min(hp + other.skill1_heal, maxhp)
					if move_speed > 0 && !is_boss{
						move_speed += other.skill1_speed_add
					}
				}
			}
		}

		if timer >= 17 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break

	case BOSS_STATE.SKILL2:
		// 技能2：冰封自身前方 4 列、上下各 1 行的卡片
		sprite_index = spr_medusa_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 20
		}
		else{
			image_index = floor(timer/5) mod 20 + 20
		}

		if timer == 10 * 5{
			var boss_grid = get_grid_position_from_world(x, y)
			var center_row = boss_grid.row
			var front_col = boss_grid.col
			with obj_card_parent{
				if abs(grid_row - center_row) <= other.skill2_row_range &&
				grid_col > front_col && grid_col <= front_col + other.skill2_front_cols &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					// 冰冻时长不做加法：低于 600 帧的补到 600 帧
					if frozen_timer < other.skill2_freeze_time{
						frozen_timer = other.skill2_freeze_time
					}
					// 被美杜莎冰冻的卡片换用石像外观
					is_medusa_statue = true
					medusa_statue_timer = other.skill2_freeze_time
					medusa_statue_anim = 0
				}
			}
		}

		if timer >= 20 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break

	case BOSS_STATE.SKILL3:
		// 技能3：催眠全场卡片，技能结束时恢复
		sprite_index = spr_medusa_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 54
		}
		else{
			image_index = floor(timer/5) mod 54 + 54
		}

		if timer == 12 * 5{
			apply_hypno()
		}

		// 整段动画（54 帧 × 2 轮 × 5 帧/图）播完即解除催眠
		if timer >= 54 * 5 - 1{
			release_hypno()
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break

	case BOSS_STATE.DISAPPEAR:
		// 移动：按 skill_count 决定下一个技能的站位
		sprite_index = spr_medusa_move
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer == 1{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 0{
				// 技能1：第 9 列随机行（落点要 -90，所以传 9，实际站在第 8 列=1 基的第 9 列）
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_count == 1{
				// 技能2：第 1 列左侧（代码列 0）、第 2 行或第 6 行
				enemy_row = choose(1,5)
				enemy_row = clamp(enemy_row,0,global.grid_rows-1)
				enemy_pos = get_world_position_from_grid(0,enemy_row)
			}
			else{
				// 技能3：第 9 列随机行
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			x_move_speed = (enemy_pos.x - 90 - x)/180
			y_move_speed = (enemy_pos.y + 30 - y)/180
		}
		if timer >= 1 && timer <= 180{
			x += x_move_speed
			y += y_move_speed
		}
		if timer == 180{
			if skill_count == 1{
				image_xscale = -1.8	// 到左侧后翻面朝向卡片
			}
			else{
				image_xscale = 1.8	// 回到右侧，翻回原朝向
			}
			timer = 0
			state = BOSS_STATE.APPEAR
		}
		break

	case BOSS_STATE.DEATH:
		sprite_index = spr_medusa_death
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

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;