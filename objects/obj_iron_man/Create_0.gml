// Inherit the parent event
event_inherited();

timer = 0
death_timer = 0
hp = 90000
maxhp = 90000
immune_to_ash = true
image_alpha = 1
state = "appear"
special_ash = true
mouse_id = "iron_man"
target_type = "normal"
train_head = noone
jump_times = 0
erase_pos = [
	{"row":1,"col":irandom_range(0,1)},
	{"row":irandom_range(3,global.grid_rows-1),"col":3},
	{"row":1,"col":irandom_range(7,8)},
	{"row":irandom_range(3,global.grid_rows-1),"col":5},
]