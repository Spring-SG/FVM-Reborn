// Inherit the parent event
if skipped or hp <= 0{
	sprite_index = spr_machine_skateboard_mouse
	move_anim = 8
	attack_anim = 6
	death_anim = 15
	move_speed = 0.3
}

// 修改后的僵尸Step事件
if global.is_paused{
	exit
}
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
}
if is_frozen || is_scare{
	exit
}

var zombie_grid = get_grid_position_from_world(x, y);

timer++;

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
        x -= current_move_speed;
        
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
        
        // 检测前方植物
        var plant_in_range = noone;
		
		var plant_order_list = [noone,noone,noone,noone]
        
		
        // 使用碰撞检测查找攻击范围内的植物
        with (obj_card_parent) {
			var dx = x - other.x;
			var dy = y - other.y;
			var is_in_front = false
			is_in_front = (dx < 0 && dx > -other.attack_range);
				
            // 检查是否在攻击范围内
            if (is_in_front && zombie_grid.row == grid_row && (feature_type!="dwarf" || (feature_type=="dwarf" && other.giant_type))) {
                // 按铲除顺序优先选择
                for (var i = 0; i < ds_list_size(global.eat_order); i++) {
                    var target_type = ds_list_find_value(global.eat_order, i);
                    
                    if (plant_type == target_type) {
                        plant_order_list[i] = id;
                        break;
                    }
                }
				
                
                if (plant_in_range != noone) break;
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
        // 攻击动画
        if (hp/maxhp > hurt_rate) {
            image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2);
        } else {
            image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2 + attack_anim);
        }
        if not skipped{
			if instance_exists(target_plant){
				if array_get_index(block_list,target_plant.plant_id) == -1{
			
					move_speed = 1.80
				}
				else{
					move_speed = 0
				}
			}
			else{
				move_speed = 1.8
			}
			if  ((hp/maxhp > hurt_rate) && image_index == move_anim * 2 + attack_anim-1) or ((hp/maxhp <= hurt_rate) && image_index == move_anim * 2 + attack_anim*2-1){
				skipped = true
			}
			x -= current_move_speed;
		}
		
		else{
	        // 检测前方植物
	        var plant_in_range = noone;
        
			var plant_order_list = [noone,noone,noone,noone]
		
	        // 使用碰撞检测查找攻击范围内的植物
	        with (obj_card_parent) {
				var dx = x - other.x;
				var dy = y - other.y;
				var is_in_front = false
				is_in_front = (dx < 0 && dx > -other.attack_range);
				
	            // 检查是否在攻击范围内
	            if (is_in_front && zombie_grid.row == grid_row && (feature_type!="dwarf" || (feature_type=="dwarf" && other.giant_type))) {
	                // 按铲除顺序优先选择
	                for (var i = 0; i < ds_list_size(global.eat_order); i++) {
	                    var target_type = ds_list_find_value(global.eat_order, i);
                    
	                    if (plant_type == target_type) {
	                        plant_order_list[i] = id;
	                        break;
	                    }
	                }
                
	                if (plant_in_range != noone) break;
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
				audio_play_sound(ds_list_find_value(obj_battle.chomp_sound_list,a),0,0)
	            // 重置攻击计时器
	            attack_timer = 0;
	        }
		}
        break;
    }
    
    case ENEMY_STATE.DEAD: {
		ice_timer = 0
		frozen_timer = 0
        // 死亡动画
        if image_index >= death_anim + move_anim * 2 + attack_anim * 2 - 1 {
            image_alpha -= 0.08;
        } else {
            image_index = (floor(timer / flash_speed) mod death_anim) + move_anim * 2 + attack_anim * 2;
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

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新
grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if x < global.grid_offset_x-150 && hp > 0 && not place_meeting(x,y,obj_cat){
	global.is_paused = true
	global.game_over = true
	instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
	audio_play_sound(snd_lose,0,0)
}