// Inherit the parent event
event_inherited();

mouse_id = "hulk_mouse"
jump_times = 0
skill_timer = 0
state = BOSS_STATE.APPEAR
hp = 120000
maxhp = 120000
immune_to_ash = true
wait_time = 240
cave = noone
sprite_index = spr_hulk_mouse_appear
is_boss = true

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false
target_coord = []
skill_1_row = [-1,-1]
skill_2_erase_pos = [[3,3],[4,3],[2,3],[3,2],[3,4]]

skill_change_style = 0

x_move_speed = 0
y_move_speed = 0

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}
