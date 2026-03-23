// Inherit the parent event
event_inherited();

mouse_id = "blonde_mary"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 30000
maxhp = 30000
immune_to_ash = true
wait_time = 300
cave = noone
sprite_index = spr_blonde_mary_appear
is_boss = true

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false
avaliable_pos = ds_list_create()

awake_card_id_list = []

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}
