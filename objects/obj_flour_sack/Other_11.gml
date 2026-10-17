// 事件: 自定义事件1 (倭瓜攻击)
var target_x = x;
var target_y = y;
var has_target = false;

// 寻找最近的敌人作为目标
var nearest_enemy = noone;
var nearest_dist = 1000; // 足够大的初始距离

with (obj_enemy_parent) {
    if (hp > 0) {
        var dist = point_distance(x, y, other.x, other.y);
        if (grid_row == other.grid_row && grid_col >= other.grid_col-other.range && grid_col <= (other.grid_col + other.range) && can_target_on(other.target_type,target_type)) {
            nearest_enemy = id;
            nearest_dist = dist;
            has_target = true;
        }
    }
}

// 如果有目标敌人，移动到其头上
if (has_target) {
	var x_distance = min(global.grid_cell_size_x,abs(x - nearest_enemy.x))
	if nearest_enemy.x < x{
		target_x = x - x_distance
	}
	else{
		target_x = x + x_distance
	}
    //target_x = nearest_enemy.x;
    target_y = clamp(nearest_enemy.y-45,y-15,y);
	var delay = 0
	if shape == 0{
		delay = 20
	}
	else{
		delay = 25
	}
    // 移动到目标
    //move_towards_point(target_x, target_y, 20);
	chspeed = (target_x-x)/delay
	cvspeed = (target_y-y)/delay
	alarm[0] = delay; // 设置一个短暂延迟，让倭瓜有时间移动到目标位置
	
	
	
} else {
	var x_distance = min(global.grid_cell_size_x,abs(x - first_target_x))
	if first_target_x < x{
		target_x = x - x_distance
	}
	else{
		target_x = x + x_distance
	}
    //target_x = nearest_enemy.x;
    target_y = first_target_y;
	var delay = 0
	if shape == 0{
		delay = 20
	}
	else{
		delay = 25
	}
    // 移动到目标
    //move_towards_point(target_x, target_y, 20);
	chspeed = (target_x-x)/delay
	cvspeed = (target_y-45-y)/delay
	alarm[0] = delay; // 设置一个短暂延迟，让倭瓜有时间移动到目标位置
}