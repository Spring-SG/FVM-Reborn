 // Inherit the parent event
event_inherited();
hp = 800
maxhp = 800
move_speed = 0.30
move_anim = 12
attack_anim = 6
death_anim = 10
mouse_id = "can_mouse"

cvspeed = 7
chspeed = -4
cgravity = 0.2

land_timer = 0
target_row = 0

can_dropped = false

function armor_drop(){
	var inst = instance_create_depth(x,y-125,depth-1,obj_enemy_armor)
	inst.ground_y = y - 50
	inst.type = "helmet"
	inst.x_speed = random_range(5,8)
	inst.y_speed = random_range(-5,-8)
	inst.cgravity = 0.8
	inst.sprite_index = spr_can
	sprite_index = spr_can_mouse
	can_dropped = true
}

function into_act(){
	if not can_dropped && state != ENEMY_STATE.ACTING && state != ENEMY_STATE.DEAD{
		state = ENEMY_STATE.ACTING
		timer = 0
		target_row = grid_row
		can_dropped = true
	}
}