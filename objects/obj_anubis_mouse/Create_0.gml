// Inherit the parent event
event_inherited();

mouse_id = "anubis_mouse"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 60000
maxhp = 60000
immune_to_ash = true
wait_time = 240
sprite_index = spr_anubis_mouse_idle
is_boss = true

x_move_speed = 0
y_move_speed = 0

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}
