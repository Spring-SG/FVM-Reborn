if global.is_paused{
	exit
}

timer++
image_index = floor(timer/5) mod 4

// 向左飞行
x -= move_speed

// 命中判定：同一行、接触范围内、还没被这颗子弹打过的卡片，结算一次伤害
with obj_card_parent{
	if grid_row == other.row &&
	abs(x - other.x) <= 60 &&
	array_get_index(other.hit_list,id) == -1 &&
	plant_id != "player" && plant_type != "coffee" && plant_type != "lilypad" && !invincible && plant_id != "cotton_candy"{
		array_push(other.hit_list,id)
		hp -= other.damage
		event_user(2)
	}
}

// 到达第 0 列（最左列）后消失
if x <= global.grid_offset_x{
	instance_destroy()
}