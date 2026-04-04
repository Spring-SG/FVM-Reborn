// Inherit the parent event
event_inherited();

mouse_id = "fog_julie"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 50000
maxhp = 50000
immune_to_ash = true
wait_time = 240
cave = noone
sprite_index = spr_fog_julie_idle
idle_spr = spr_fog_julie_idle
idle_anim = 12
is_boss = true

y_move_speed = 0
x_move = 0

fog_summoned = false
banding_summon_obj = noone

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false
avaliable_pos = ds_list_create()
missle_coord = []

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}
