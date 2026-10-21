// 用户事件1 - 发射子弹
var _count = 3
var _start = 0
if shape == 1 && attack_count == 1{
	_count = 2
	_start = 1
}
for(var i = _start ; i < _count ; i++){
	var current_enemy_ins = target_instance_list[i]
	if current_enemy_ins == noone{
		for(var j = 0 ; j < 3 ; j++){
			if target_instance_list[j] != noone
			current_enemy_ins = target_instance_list[j]
		}
	}
	var row_offset = i - 1
	var x_offset = 0
	if (grid_row == 0 && row_offset == -1) || (grid_row == global.grid_rows - 1 && row_offset = 1){
		row_offset = 0
		x_offset = 40
	}
	var inst = instance_create_depth(x-40 + x_offset, y-110+row_offset*global.grid_cell_size_y, depth-500, obj_roastlizardpult_bullet)
	if shape == 1{
		inst.sprite_index = spr_roast_lizard_pult_bullet_1
	}
	if shape >= 2{
		inst.sprite_index = spr_roast_lizard_pult_bullet_2
	}
	global.audio.play(snd_throw, 0, 0)

	// 基本属性
	inst.damage = atk
	inst.original_damage = atk // 保存原始伤害值用于溅射计算
	inst.row = grid_row+row_offset
	inst.thrower_y = y+row_offset*global.grid_cell_size_y // 记录投手的Y坐标用于地面破裂判断

	// 如果有目标敌人，计算预测落点
	if (current_enemy_ins != noone && instance_exists(current_enemy_ins)) {
	    // 获取敌人当前位置和速度
	    var enemy_x = current_enemy_ins.x
	    var enemy_y = current_enemy_ins.y
	    var enemy_speed = current_enemy_ins.move_speed // 假设敌人有move_speed属性
    
	    // 计算子弹飞行时间（基于水平距离和预设速度）
	    var distance_x = enemy_x - inst.x
	    var flight_time = clamp(30 + (distance_x/1000) * 45, 30, 75)
    
	    // 预测敌人未来位置（考虑敌人速度）
	    var predicted_x = enemy_x - enemy_speed * flight_time - 50
		if predicted_x < x predicted_x = x
    
	    // 计算子弹所需的速度向量
	    var total_distance_x = predicted_x - inst.x
	    var total_distance_y = 600//enemy_y - inst.y
    
	    // 抛物线运动参数计算:cite[6]
	    inst.move_speed = total_distance_x / flight_time
		inst.cgravity = (2 * total_distance_y) / (flight_time * flight_time)
	    inst.cvspeed = (total_distance_y - 0 * inst.cgravity * flight_time * flight_time) / flight_time
    
    
	    // 存储目标信息
	    inst.target_enemy = current_enemy_ins
	    inst.has_target = true
	} else {
	    // 没有目标，使用默认抛物线
	    inst.move_speed = 8
	    inst.cvspeed = 6
	    inst.cgravity = 0.2
	    inst.has_target = false
	    inst.target_enemy = noone
	}

	// 子弹状态初始化
	inst.hit_enemy = false
	inst.splashed = false
	inst.shape = shape
}