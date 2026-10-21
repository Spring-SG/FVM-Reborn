if global.is_paused {
    exit;
}
if burnt == 1{
	sprite_index = spr_fire_bullet
}
timer++;
image_index = (floor(timer / 3)) mod 4;

// 水平移动
x += move_speed;

// 处理上下行的子弹移动动画
if variable_instance_exists(id, "target_row"){
    // 计算目标行的y坐标（需要根据你的游戏地图调整计算方式）
    var target_y =global.grid_offset_y + global.grid_cell_size_y*target_row;
    
    
    // 平滑移动到目标行（使用线性插值）
    var transition_speed = 0.15; // 调整这个值来控制移动速度
    y = lerp(y, target_y, transition_speed);
	
	if abs(y - target_y) < 30 {
		row = target_row
	}
}

// 边界检查
if x > 2200 or y > 1200 or x < 0 or y < 0 {
    instance_destroy();
}