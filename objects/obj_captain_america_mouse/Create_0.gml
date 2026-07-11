// Inherit the parent event
event_inherited();

mouse_id = "captain_america_mouse"
jump_times = 0
skill_timer = 0
state = BOSS_STATE.APPEAR
hp = 90000
maxhp = 90000
immune_to_ash = true
wait_time = 120
cave = noone
sprite_index = spr_captain_america_mouse_appear1
is_boss = true

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false
target_coord = []

skill_change_style = 0

x_move_speed = 0
y_move_speed = 0

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}
