function find_priority_enemy() {
    var priority_enemy = noone;
    var closest_left_enemy = noone;
	var air_enemy = noone
    var min_x = room_width; // 初始化为房间宽度
    var max_hp = 0;
    
    // 检查右边一格内是否有敌人（假设一格为80像素）
    with (obj_enemy_parent) {
        if (hp > 0 && can_hit(other.target_type,target_type) && y > 0) { // 只考虑存活的敌人
			
            // 同时寻找最左侧且生命值最高的敌人
            if (x < min_x || (x == min_x && hp > max_hp)) {
                min_x = x;
                max_hp = hp;
                closest_left_enemy = id;
            }
        }
    }
    
    // 优先返回右边一格内的敌人，如果没有则返回最左侧敌人
    if (priority_enemy != noone) {
        return priority_enemy;
    }
	if (air_enemy != noone){
		return air_enemy
	}
    return closest_left_enemy;
}
var target = find_priority_enemy()
var inst = instance_create_depth(x,y-95,depth-500,obj_tanghulu_bullet)
inst.damage = atk
inst.move_speed = 10
inst.target_enemy = target
inst.banding_card_obj = id
inst.row = grid_row
if shape == 1{inst.sprite_index = spr_tanghulu_bullet_1}
if shape == 2{inst.sprite_index = spr_tanghulu_bullet_2}