// Inherit the parent event
event_inherited();

mouse_id = "spider_man_mouse"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 120000
maxhp = 120000
immune_to_ash = true
appear = false
wait_time = 180
skill_choose = 0
sprite_index = spr_spider_man_mouse_idle
image_alpha = 0
is_boss = true
target_type = "air"
skill_timer = 0

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}

target_pos = {"row":-1,"col":-1}
target_coord = []

x_move_speed = 0
y_move_speed = 0