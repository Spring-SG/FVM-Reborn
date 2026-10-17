// Inherit the parent event

if shield_hp > 0 && state != ENEMY_STATE.ACTING{
	sprite_index = spr_repairman_mouse_shield
	move_anim = 8
	attack_anim = 5
	move_speed = 0.6
}
else if shield_hp <= 0 && state != ENEMY_STATE.ACTING{
	sprite_index = spr_repairman_mouse
	move_anim = 8
	attack_anim = 4
	move_speed = 0.3
}
if shield_hp <= 0 && not placed && not armor_dropped{
	var inst = instance_create_depth(x-35,y-75,depth-1,obj_enemy_armor)
	inst.ground_y = y - 30
	inst.type = "shield"
	inst.x_speed = random_range(-3,-5)
	inst.y_speed = random_range(-1,-3)
	inst.cgravity = 0.8
	inst.sprite_index = spr_ladder_shield
	armor_dropped = true
}
event_inherited();
if global.is_paused or is_frozen{
	exit
}
// 前提：目标植物**所在格**里的植物都不能已经有梯子（有一株 have_loder = true 就不放了）
//   —— 免得同一格叠一堆梯子（多个修理工鼠各放一个）
var _cell_free = true;
if (instance_exists(target_plant)) {
	var _gc = target_plant.grid_col;
	var _gr = target_plant.grid_row;
	if (_gc >= 0 && _gc < global.grid_cols && _gr >= 0 && _gr < global.grid_rows) {
		var _plist = ds_grid_get(global.grid_plants, _gc, _gr);
		for (var _i = 0; _i < ds_list_size(_plist); _i++) {
			var _p = ds_list_find_value(_plist, _i);
			if (instance_exists(_p) && _p.have_loder) {
				_cell_free = false;
				break;
			}
		}
	}
}
if (state == ENEMY_STATE.ATTACK && _cell_free && (array_get_index(can_place_list,target_plant.plant_id) != -1) && !placed && shield_hp > 0){
	sprite_index = spr_repairman_mouse_place
	timer = 0
	state = ENEMY_STATE.ACTING
}
if not placed && state = ENEMY_STATE.ACTING{
	if hp <= 0{
		timer = 0
		state = ENEMY_STATE.DEAD
		sprite_index = spr_repairman_mouse
	}
	if shield_hp <= 0{
		timer = 0
		state = ENEMY_STATE.NORMAL
		sprite_index = spr_repairman_mouse
	}
	if hp > maxhp * hurt_rate{
		if shield_hp > shield_max_hp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 6
		}
		else{
			image_index = floor(timer/flash_speed) mod 6 + 5
		}
	}
	else{
		if shield_hp > shield_max_hp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 6 + 11
		}
		else{
			image_index = floor(timer/flash_speed) mod 6 + 17
		}
	}
	if timer >= flash_speed * 6 or hp <= 0{
		if hp > 0 && instance_exists(target_plant){
			// 梯子的宿主反查按**放置者所在格**（不能按梯子自己的坐标算：它在 y-37，靠行下沿会算到上一行）
			var _ld = instance_create_depth(x-50,y-37,depth,obj_ladder)
			_ld.spawn_row = grid_row
			_ld.spawn_col = grid_col
		}
		sprite_index = spr_repairman_mouse
		state = ENEMY_STATE.NORMAL
		shield_hp = 0
		placed = true
	}
}