// Inherit the parent event
event_inherited();

mouse_id = "mouse_train_1"
jump_times = 0
skill_timer = 0
state = BOSS_STATE.APPEAR
hp = 200000
maxhp = 200000
immune_to_ash = true
wait_time = 120
move_time = 250
cave = noone
sprite_index = spr_mouse_train_1_body_idle
is_boss = true

skill_choose = 0
skill_count = 0
image_alpha = 1
appear = false
avaliable_pos = ds_list_create()
missle_coord = []

skill_change_style = 0

x_move_speed = 0
y_move_speed = 0

train_head = noone
is_reversed = false
