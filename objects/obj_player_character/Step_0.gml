// obj_plant_parent 的 Step 事件
if global.is_paused{
	exit
}
// 动画计时器
if is_placed{
	if timer < flash_speed - 1 {
	    timer++;
	} else {
	    switch (state) {
	        case CARD_STATE.IDLE:
	            if image_index < 7 image_index++;
	            else image_index = 0;
	            break;
            
	        case CARD_STATE.ATTACK:
	            if (image_index >= (7+1) && image_index <= (7+1) + attack_anim) image_index++;
	            else image_index = (7+1);
	            break;
		
	    }
	    timer = 0;
	}
}



// 计算深度值
//var depth_value = -((y + depth_offset) * 10 + x);
//depth = depth_value - depth_group * 100;

if hp <= 0{
	global.is_paused = true
	global.game_over = true
	instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
	audio_play_sound(snd_lose,0,0)
}

if flash_value >0{
	
	flash_value -= 10
	
}
if is_placed{
	var have_platform = false;
	with obj_platform{
		have_platform = true
		break
	}
	if(have_platform==false){
		depth = calculate_plant_depth(grid_col, grid_row, "normal")
	}
}
else{
	depth = -5000
}
if hurt_time > 0 {
	hurt_time --
}
if hurt_time <= 0 and hp < max_hp{
	hp ++
}
//检测自身右方是否有敌人
var has_enemy = false
with(obj_enemy_parent){
	if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && health > 0){
		has_enemy = true
		break
	}
}
//攻击逻辑
if (has_enemy) {
    if (attack_timer <= cycle - attack_anim * flash_speed) {
        attack_timer++;
    } else if (attack_timer <= cycle) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
        //event_user(1); // 发射子弹
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}