// Inherit the parent event
event_inherited();

mouse_id = "thor"
jump_times = 0
state = BOSS_STATE.IDLE
hp = 800000
maxhp = 800000
immune_to_ash = true
wait_time = 40 * 60
move_speed = 0.3
sprite_index = spr_thor_head_idle
is_boss = true
skill_count = 0

move_stage = 0
body_count = 0
summon_timer = 0

appear = false
image_alpha = 0
target_coord = []

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}