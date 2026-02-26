if global.is_paused{
	exit
}
timer ++
switch (state) {
    case "idle":
        image_index = floor(timer / flash_speed) mod idle_anim
        break;
            
    case "awake":
        image_index = floor(timer / flash_speed) mod awake_anim + idle_anim
        break;
	case "attack":
        image_index = floor(timer / flash_speed) mod attack_anim + awake_anim + idle_anim
        break;
		
}

with obj_enemy_parent{
	if abs(x - other.x) <= 120{
		if other.state == "idle" && other.row == grid_row && hp > 0 && (array_get_index(other.ignore_list,mouse_id) == -1)&& (array_get_index(other.target_ignore,mouse_id) == -1){
			other.state = "awake"
			other.timer = 0
		}
		if other.state != "idle" && other.row == grid_row && hp > 0  && (array_get_index(other.ignore_list,mouse_id) == -1){
			
			var inst = instance_create_depth(x,y,depth,obj_knock_back_effect)
			inst.sprite_index = sprite_index
			inst.image_index = image_index
			instance_destroy()
			
		}
	}
}

if state == "awake"{
	attack_timer ++
	if attack_timer > flash_speed * awake_anim{
		state = "attack"
		flash_speed = 4
		timer = 0
	}
}
if state == "attack"{
	x += 4
	if x > 2200{
		instance_destroy()
	}
}