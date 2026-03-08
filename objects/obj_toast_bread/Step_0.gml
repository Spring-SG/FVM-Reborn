// obj_plant_parent 的 Step 事件
if global.is_paused{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
var flash_offset = 0
if hp <= 0.67 * max_hp flash_offset = 12
if hp <= 0.33 * max_hp flash_offset = 24
// 计算深度值
//var depth_value = -((y + depth_offset) * 10 + x);
//depth = depth_value - depth_group * 100;

if hp <= 0{
	instance_destroy()
}

if flash_value >0{
	
	flash_value -= 10
	
}
var grid_pos = get_grid_position_from_world(x,y)

grid_col = grid_pos.col
grid_row = grid_pos.row
depth = calculate_plant_depth(grid_col, grid_row, plant_type)
if instance_exists(banding_star_obj){
banding_star_obj.depth = depth - 1
}
if is_frozen{
	exit
}
// 动画计时器
if timer < current_flash_speed - 1 {
    timer++;
} else {
    switch (state) {
        case CARD_STATE.IDLE:
            if image_index < (11+flash_offset) image_index++;
            else image_index = flash_offset;
            break;
            
        case CARD_STATE.ATTACK:
            if (image_index >= 12 && image_index <= 12 + attack_anim) image_index++;
            else image_index = 12;
            break;
    }
    timer = 0;
}



