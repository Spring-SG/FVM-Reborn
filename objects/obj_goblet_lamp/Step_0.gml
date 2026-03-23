if global.is_paused{
	exit
}
// obj_plant_parent 的 Step 事件
if ice_timer > 0{
	ice_timer--
	is_slowdown = true
}
else{
	is_slowdown = false
}

// 动画计时器
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
var upgrade_data = get_plant_data_with_skill(plant_id, shape,current_level,skill);
    if is_slowdown {
        cycle = upgrade_data[? "cycle"] * 2;    
    }
	else{
		cycle = upgrade_data[? "cycle"]
	}
if grow_timer < 90*60{
	grow_timer++
}
else if grow_timer == 90*60{
	state = CARD_STATE.GROW
	audio_play_sound(snd_goblet_lamp_grow,0,0)
	grow_timer++
}
else if grow_timer < 90*60+8*current_flash_speed{
	state = CARD_STATE.GROW
	grow_timer++
}
else if grow_timer == 90*60+8*current_flash_speed{
	state = CARD_STATE.IDLE
	flash_offset = 36
	grow_timer++
}
// 计算深度值
//var depth_value = -((y + depth_offset) * 10 + x);
//depth = depth_value - depth_group * 100;

if hp <= 0{
	instance_destroy()
}

if flash_value >0{
	
	flash_value -= 10
	
}
depth = calculate_plant_depth(grid_col, grid_row, plant_type)
if instance_exists(banding_star_obj){
banding_star_obj.depth = depth - 1
}

if is_frozen{
	exit
}

if timer < current_flash_speed - 1 {
    timer++;
} else {
    switch (state) {
        case CARD_STATE.IDLE:
            if image_index < idle_anim+flash_offset image_index++;
            else image_index = flash_offset;
            break;
            
        case CARD_STATE.ATTACK:
            if (image_index >= (idle_anim+1+flash_offset) && image_index <= (idle_anim+1 + attack_anim + flash_offset)) image_index++;
            else image_index = (idle_anim+1)+flash_offset;
            break;
			
		case CARD_STATE.GROW:
			if (image_index >= (idle_anim+attack_anim+1) && image_index <= (idle_anim+1) + attack_anim+8) image_index++;
            else image_index = (idle_anim+attack_anim+1);
            break;
    }
    timer = 0;
}

// 生产逻辑
current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
if (first_produce == 0) {
    if (attack_timer <= first_produce_delay) {
        attack_timer++;
    } else if (attack_timer <= first_produce_delay + attack_anim * current_flash_speed) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
        // 生产火苗（调用子类特定方法）
        event_user(1);  // 用户事件1用于生产
        
        attack_timer = 0;
        state = CARD_STATE.IDLE;
        first_produce = 1;
    }
} else {
	if state != CARD_STATE.GROW{
	    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	        attack_timer++;
	    } else if (attack_timer <= cycle) {
	        attack_timer++;
	        state = CARD_STATE.ATTACK;
	    } else {
	        // 生产火苗（调用子类特定方法）
	        event_user(1);  // 用户事件1用于生产
        
	        attack_timer = 0;
	        state = CARD_STATE.IDLE;
	    }
	}
}

