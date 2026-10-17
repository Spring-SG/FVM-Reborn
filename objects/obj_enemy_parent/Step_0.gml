// 修改后的僵尸Step事件
if global.is_paused{
	exit
}

// 保持网格位置更新
var zombie_grid = get_grid_position_from_world(x, y);
grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if ice_timer > 0{
	ice_timer--
	is_slowdown = true
}
else{
	is_slowdown = false
}
if frozen_timer > 0{
	current_frozen = true
	frozen_timer--
	is_frozen = true
}
else{
	is_frozen = false
}
if scare_timer > 0{
	scare_timer--
	is_scare = true
}
else{
	is_scare = false
}
if stun_timer > 0{
	stun_timer--
	is_stun = true
}
else{
	is_stun = false
	stun_sprite = spr_mouse_stun
}
if flash_value > 0 {
	flash_value -= 10
}
if hp <= 0{
	frozen_timer = 0
	scare_timer = 0
	left_move_flashs = 0
	stun_timer = 0
}
var current_atk_cycle = 0
var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
	current_atk_cycle = atk_cycle*2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
	current_atk_cycle = atk_cycle
}
if left_move_flashs > 0{
	y += y_move
	left_move_flashs--
	if (y <= get_world_position_from_grid(0,0).y + 38 && y_move < 0) || (y >= get_world_position_from_grid(0,global.grid_rows-1).y + 38 && y_move > 0){
		left_move_flashs = 0
		y_move = 0
	}
}
if is_frozen || is_scare || is_stun{
	exit
}

timer++;





// ===== 梯子适用判定 =====
// 名单里的老鼠「无视梯子」：不爬上梯子，也不会被梯子跳过啃咬（照常啃咬/碾压植物）
// 注意：有的对象没设 mouse_id（如跳跳鼠），必须额外按 object_index 判断，否则会漏
//   - engineering_vehicle_mouse：工程车鼠，应直接碾压卡牌
//   - garbage_track_mouse：垃圾车鼠，碾压碰到的卡片
//   - landmine_vehicle_mouse：地雷车鼠，碾压型车辆
//   - snail_mouse：蜗牛鼠，碾压碰到的卡片
//   - mole：鼹鼠，从卡左侧攻击，不受右侧梯子影响，应正常啃咬
//   - obj_kangaroo / obj_infected_kangaroo：跳跳鼠系列（未设 mouse_id，自己会跳过卡片）
// var _no_ladder_ids = ["engineering_vehicle_mouse", "garbage_track_mouse", "landmine_vehicle_mouse", "snail_mouse", "mole"];
// var _no_ladder_objs = [obj_kangaroo];
// var _can_use_ladder = (array_get_index(_no_ladder_ids, mouse_id) == -1 && array_get_index(_no_ladder_objs, object_index) == -1);

// ================= 上梯越过植物（梯子功能）=================
// 说明：
//   - climb_stage 0 = 未越障
//   - 越障期间把 state 设为 IDLE（IDLE 不做普通移动），由本块接管位移
//   - 越障 = 沿本行水平向左移动到落点，同时叠一条小弧线（climb_arc_h = 40px）
//     弧线高度远小于一格(116px)，grid_row 不会变 → 不会被上面那行的卡片打到
//   - 越过恢复 NORMAL 继续向左走，此时已在下一格，不会回头啃本格植物
if (climb_stage == 0 && (state == ENEMY_STATE.NORMAL|| state ==ENEMY_STATE.ATTACK) && move_speed > 0 && can_use_ladder
	&& target_type == "normal") {   // 只让普通行走型上梯：air / underground / diver / invisible / obstacle 一律不爬
	if(grid_row>=0&&grid_row<global.grid_rows&&grid_col>=0&&grid_col<global.grid_cols){
		var _list = ds_grid_get(global.grid_plants, grid_col, grid_row);
		for(var _item = 0; _item < ds_list_size(_list); _item++)
		{
			var plant_inst = ds_list_find_value(_list, _item);
			if (!instance_exists(plant_inst)) continue;
			if(plant_inst.have_loder&& x-plant_inst.x<=attack_range){
				
				climb_end_x = plant_inst.x - global.grid_cell_size_x * 0.5;
				climb_base_y = y;
				climb_y = y;
				climb_total_dist = max(1, abs(climb_end_x - x));
				target_plant = noone;
				state = ENEMY_STATE.IDLE;
				climb_stage = 1;
				
				break;
			}
		}
	}
	if(climb_stage == 0 && grid_row>=0&&grid_row<global.grid_rows&&grid_col>0&&grid_col<global.grid_cols){
		var _list = ds_grid_get(global.grid_plants, grid_col-1, grid_row);
		for(var _item = 0; _item < ds_list_size(_list); _item++)
		{
			var plant_inst = ds_list_find_value(_list, _item);
			if (!instance_exists(plant_inst)) continue;
			if(plant_inst.have_loder&& x-plant_inst.x<=attack_range){
				
				climb_end_x = plant_inst.x - global.grid_cell_size_x * 0.5;
				climb_base_y = y;
				climb_y = y;
				climb_total_dist = max(1, abs(climb_end_x - x));
				target_plant = noone;
				state = ENEMY_STATE.IDLE;
				climb_stage = 1;
				
				break;
			}
		}
	}
}

// 障碍物：**不用有梯子**，同行前方够近就翻过去
//   ⚠ 门槛和上面那批一样（state / move_speed / can_use_ladder / target_type），否则车辆、飞行、
//     鼹鼠之类也会来翻障碍物
/*
var _row_wet = (grid_row >= 0 && grid_row < array_length(global.row_feature) && global.row_feature[grid_row] == "water");
if (!_row_wet && climb_stage == 0 && (state == ENEMY_STATE.NORMAL || state == ENEMY_STATE.ATTACK) && move_speed > 0 && can_use_ladder
	&& target_type == "normal") {
	with (obj_obstacle) {
		var _odx = other.x - x;                       // >0 = 障碍物在老鼠左边（前方）
		if (row == other.grid_row && _odx > 0 && _odx <= 60) {
			other.climb_end_x = x - global.grid_cell_size_x * 0.5 - 2;
			other.climb_base_y = other.y;
			other.climb_y = other.y;
			other.climb_total_dist = max(1, abs(other.climb_end_x - other.x));
			other.target_plant = noone;
			other.state_recode = other.state
			other.state = ENEMY_STATE.IDLE;
			other.climb_stage = 1;
			break;
		}
	}
}*/
if (climb_stage == 1) {
	// 越过：沿本行水平向左推进到落点，并叠一条小弧线（爬升感）
	//   弧线最高 climb_arc_h(40px)，远小于一格(116px)，grid_row 不会变
	//   → 不会被上面那行的卡片攻击打到。
	var _dx = climb_end_x - x;
	if (abs(_dx) <= climb_speed) {
		x = climb_end_x;
		//y = climb_base_y;             // 弧线收尾，落回本行
		climb_stage = 0;
		state = ENEMY_STATE.NORMAL;   // 恢复前进
		timer = 0;
	}
	else {
		x += sign(_dx) * climb_speed;
		// 进度 t：0=起点 1=落点；弧高 = sin(t*pi)，两端为 0、中间最高
		var _t = 1 - (abs(climb_end_x - x) / climb_total_dist);
		_t = clamp(_t, 0, 1);
		// 安全上限：上抬不得越过本行上边缘（越过了 grid_row 会变，就被上面那行卡片打到）
		//var _row_top = global.grid_offset_y + grid_row * global.grid_cell_size_y;
		//var _max_up = max(0, (climb_base_y - _row_top) - 4);
		//y = climb_base_y - sin(_t * pi) * min(climb_arc_h, _max_up);
		climb_y =  climb_base_y - sin(_t * pi) * global.grid_cell_size_y *0.5;
	}
}
// ==========================================================

// 状态处理前，先检查目标植物是否存在
if (instance_exists(target_plant) && target_plant.hp <= 0) {
    target_plant = noone;  // 目标已被消灭
}

// 状态机
switch(state) {
    case ENEMY_STATE.IDLE: {
        // 空闲状态不执行操作
        break;
    }
    
    case ENEMY_STATE.NORMAL: {
        // 移动和动画逻辑
        x -= current_move_speed * move_speed_modify;
        if shield_max_hp > 0 && shield_hp > 0{
			if shield_hp > hurt_rate * shield_max_hp{
				if helmet_hp > 0 && hp > maxhp - helmet_hp{
					if ((hp + helmet_hp - maxhp)/maxhp > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod move_anim;
			        } else {
			            image_index = (floor(timer / flash_speed) mod move_anim) + move_anim*2;
			        }
				}
				else{
			        if (hp/(maxhp - helmet_hp) > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod move_anim;
			        } else {
			            image_index = (floor(timer / flash_speed) mod move_anim) + move_anim*2;
			        }
				}
			}
			else{
				if helmet_hp > 0 && hp > maxhp - helmet_hp{
					if ((hp + helmet_hp - maxhp)/maxhp > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod move_anim + move_anim;
			        } else {
			            image_index = (floor(timer / flash_speed) mod move_anim) + move_anim*3;
			        }
				}
				else{
			        if (hp/(maxhp - helmet_hp) > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod move_anim + move_anim;
			        } else {
			            image_index = (floor(timer / flash_speed) mod move_anim) + move_anim*3;
			        }
				}
			}
		}
		else{
			if helmet_hp > 0 && hp > maxhp - helmet_hp{
				if ((hp + helmet_hp - maxhp)/maxhp > hurt_rate) {
		            image_index = floor(timer / flash_speed) mod move_anim;
		        } else {
		            image_index = (floor(timer / flash_speed) mod move_anim) + move_anim;
		        }
			}
			else{
		        if (hp/(maxhp - helmet_hp) > hurt_rate) {
		            image_index = floor(timer / flash_speed) mod move_anim;
		        } else {
		            image_index = (floor(timer / flash_speed) mod move_anim) + move_anim;
		        }
			}
		}
        
        // 检测前方植物
        var plant_in_range = noone;
		
		var plant_order_list = [noone,noone,noone,noone]
        
			/*
        // 使用碰撞检测查找攻击范围内的植物
        with (obj_card_parent) {
			var dx = x - other.x;
			var dy = y - other.y;
			var is_in_front = false
			if other.attack_range > 0{
				is_in_front = (dx < 0 && dx > -other.attack_range);
			}
			else{
				is_in_front = (dx > 0 && dx < -other.attack_range);
			}

            // 检查是否在攻击范围内
            if (is_in_front && zombie_grid.row == grid_row && (feature_type!="dwarf" || (feature_type=="dwarf" && other.giant_type))) {
                // 按铲除顺序优先选择
                for (var i = 0; i < ds_list_size(global.eat_order); i++) {
                    var tar_type = ds_list_find_value(global.eat_order, i);

                    if (plant_type == tar_type) {
                        plant_order_list[i] = id;
                        break;
                    }
                }


                if (plant_in_range != noone) break;
            }
        }
		*/
		
		// 限制老鼠索敌只在左右合起来5个格子内部
		if (variable_global_exists("grid_plants") && ds_exists(global.grid_plants, ds_type_grid)) {
			// 左右±2列范围
			var start_c = max(grid_col - 2, 0);
			var end_c = min(grid_col + 2, global.grid_cols - 1);

			for(var _c = start_c; _c <= end_c; _c++)
			{
				
				if(grid_row<0||grid_row>=global.grid_rows)continue;
				var _list = ds_grid_get(global.grid_plants, _c, grid_row);
				for(var _item = 0; _item < ds_list_size(_list); _item++)
				{
					var plant_inst = ds_list_find_value(_list, _item);
					if (!instance_exists(plant_inst)) continue;

					var dx = plant_inst.x - x;
					var dy = plant_inst.y - y;
					var is_in_front = false;

					if (attack_range > 0) {
						is_in_front = (dx < 0 && dx > -attack_range);
					} else {
						is_in_front = (dx > 0 && dx < -attack_range);
					}

					if (is_in_front && plant_inst.grid_row == grid_row && (plant_inst.feature_type != "dwarf" || (plant_inst.feature_type == "dwarf" && giant_type)))
					{
						// 按eat_order优先级填充
						for (var i = 0; i < ds_list_size(global.eat_order); i++)
						{
							var tar_type = ds_list_find_value(global.eat_order, i);
							if (plant_inst.plant_type == tar_type)
							{
								plant_order_list[i] = plant_inst;
								break;
							}
						}

					}
				}
			}
		}
		
		for(var i = 0 ; i < 4 ; i++){
			if plant_order_list[i] != noone{
				plant_in_range = plant_order_list[i]
				break
			}
		}
        
        // 如果找到目标植物，进入攻击状态
        if (plant_in_range != noone) {
            state = ENEMY_STATE.ATTACK;
            target_plant = plant_in_range;
            attack_timer = 0;  // 重置攻击计时器
            timer = 0;         // 重置动画计时器
        }
        break;
    }
    
	case ENEMY_STATE.ACTING:{
		break;
	}
	
    case ENEMY_STATE.ATTACK: {
		if shield_max_hp > 0 && shield_hp > 0{
			if shield_hp > hurt_rate * shield_max_hp{
				if helmet_hp > 0 && hp > maxhp - helmet_hp{
					if ((hp + helmet_hp - maxhp)/maxhp > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod attack_anim + move_anim * 4;
			        } else {
			            image_index = (floor(timer / flash_speed) mod attack_anim) + attack_anim*2 + move_anim * 4;
			        }
				}
				else{
			        if (hp/(maxhp - helmet_hp) > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod attack_anim + move_anim * 4;
			        } else {
			            image_index = (floor(timer / flash_speed) mod attack_anim) + attack_anim*2 + move_anim * 4;
			        }
				}
			}
			else{
				if helmet_hp > 0 && hp > maxhp - helmet_hp{
					if ((hp + helmet_hp - maxhp)/maxhp > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod attack_anim + attack_anim + move_anim * 4;
			        } else {
			            image_index = (floor(timer / flash_speed) mod attack_anim) + attack_anim*3 + move_anim * 4;
			        }
				}
				else{
			        if (hp/(maxhp - helmet_hp) > hurt_rate) {
			            image_index = floor(timer / flash_speed) mod attack_anim + attack_anim + move_anim * 4;
			        } else {
			            image_index = (floor(timer / flash_speed) mod attack_anim) + attack_anim*3 + move_anim * 4;
			        }
				}
			}
		}
		else{
			if helmet_hp > 0 && hp > maxhp - helmet_hp{
				if ((hp + helmet_hp - maxhp)/maxhp > hurt_rate) {
		            image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2);
		        } else {
		            image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2 + attack_anim);
		        }
			}
			else{
		        if (hp/(maxhp - helmet_hp) > hurt_rate) {
		            image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2);
		        } else {
		            image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2 + attack_anim);
		        }
			}
		}
        // 攻击动画
        // 检测前方植物
        var plant_in_range = noone;
        
		var plant_order_list = [noone,noone,noone,noone]
		
/*
        // 使用碰撞检测查找攻击范围内的植物
        with (obj_card_parent) {
			var dx = x - other.x;
			var dy = y - other.y;
			var is_in_front = false
			if other.attack_range > 0{
				is_in_front = (dx < 0 && dx > -other.attack_range);
			}
			else{
				is_in_front = (dx > 0 && dx < -other.attack_range);
			}
				
            // 检查是否在攻击范围内
            if (is_in_front && zombie_grid.row == grid_row && (feature_type!="dwarf" || (feature_type=="dwarf" && other.giant_type))) {
                // 按铲除顺序优先选择
                for (var i = 0; i < ds_list_size(global.eat_order); i++) {
                    var tar_type = ds_list_find_value(global.eat_order, i);
                    
                    if (plant_type == tar_type) {
                        plant_order_list[i] = id;
                        break;
                    }
                }
                
                if (plant_in_range != noone) break;
            }
        }
		*/
		
		// 限制老鼠索敌只在左右合起来5个格子内部
		if (variable_global_exists("grid_plants") && ds_exists(global.grid_plants, ds_type_grid)) {
			
			// 左右±2列范围
			var start_c = max(grid_col - 2, 0);
			var end_c = min(grid_col + 2, global.grid_cols - 1);
	
			for(var _c = start_c; _c <= end_c; _c++)
			{
				if(grid_row<0||grid_row>=global.grid_rows)continue;
				var _list = ds_grid_get(global.grid_plants, _c, grid_row);
				for(var _item = 0; _item < ds_list_size(_list); _item++)
				{
					var plant_inst = ds_list_find_value(_list, _item);
					if (!instance_exists(plant_inst)) continue;

					var dx = plant_inst.x - x;
					var dy = plant_inst.y - y;
					var is_in_front = false;
			
					if (attack_range > 0) {
						is_in_front = (dx < 0 && dx > -attack_range);
					} else {
						is_in_front = (dx > 0 && dx < -attack_range);
					}
			
					if (is_in_front && plant_inst.grid_row == grid_row && (plant_inst.feature_type != "dwarf" || (plant_inst.feature_type == "dwarf" && giant_type)))
					{
						// 按eat_order优先级填充
						for (var i = 0; i < ds_list_size(global.eat_order); i++)
						{
							var tar_type = ds_list_find_value(global.eat_order, i);
							if (plant_inst.plant_type == tar_type)
							{
								plant_order_list[i] = plant_inst;
								break;
							}
						}
				
					}
				}
			}
		}

		for(var i = 0 ; i < 4 ; i++){
			if plant_order_list[i] != noone{
				plant_in_range = plant_order_list[i]
				break
			}
		}
		if (plant_in_range != noone) {
            target_plant = plant_in_range;
        }
		else{
			state = ENEMY_STATE.NORMAL;
            target_plant = plant_in_range;
            attack_timer = 0;  // 重置攻击计时器
            timer = 0;         // 重置动画计时器
		}
        
        // 攻击处理
        attack_timer++;
        if (attack_timer >= current_atk_cycle) {
            // 对目标植物造成伤害
            with (target_plant) {
				if !invincible{
					hp -= other.atk;
				}
                event_user(2)
                // 播放受击效果
                if (instance_exists(other)) {
                    //instance_create_depth(x, y, depth - 1, obj_plant_hit);
                }
            }
			
            //播放音效
			var a = irandom_range(0,2)
			global.audio.play(ds_list_find_value(obj_battle.chomp_sound_list,a),0,0)
            // 重置攻击计时器
            attack_timer = 0;
        }
        break;
    }
    
    case ENEMY_STATE.DEAD: {
		ice_timer = 0
		frozen_timer = 0
        // 死亡动画
		if shield_max_hp > 0 && shield_hp > 0{
			if image_index >= death_anim + move_anim * 4 + attack_anim * 4 - 1 {
	            image_alpha -= 0.08;
	        } else {
	            image_index = (floor(timer / flash_speed) mod death_anim) + move_anim * 4 + attack_anim * 4;
	        }
		}
		else{
	        if image_index >= death_anim + move_anim * 2 + attack_anim * 2 - 1 {
	            image_alpha -= 0.08;
	        } else {
	            image_index = (floor(timer / flash_speed) mod death_anim) + move_anim * 2 + attack_anim * 2;
	        }
		}
        break;
    }
}

// 死亡处理
if (hp <= 0 && state != ENEMY_STATE.DEAD) {
    timer = 0;
    state = ENEMY_STATE.DEAD;
    target_plant = noone;  // 清除攻击目标
}

// 透明度处理
if (image_alpha <= 0 && state == ENEMY_STATE.DEAD) {
    instance_destroy();
}




// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (9 * 5);
depth = base_depth; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

if x < global.grid_offset_x-150 && hp > 0 && not place_meeting(x,y,obj_cat) && array_get_index(block_mouse_id_list,mouse_id) == -1{
	global.is_paused = true
	global.game_over = true
	instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
	global.audio.play(snd_lose,0,0)
}

//破冰动画
if current_frozen && not is_frozen{
	global.audio.play(snd_mouse_unfreeze,0,0)
	var inst = instance_create_depth(x,y+50,depth,obj_unfreeze_effect)
	inst.sprite_index = ice_sprite
	ice_sprite = spr_mouse_frozen
	current_frozen = false
}