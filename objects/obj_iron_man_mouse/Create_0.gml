// Inherit the parent event
event_inherited();

mouse_id = "iron_man_mouse"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 90000
maxhp = 90000
immune_to_ash = true
appear = false
wait_time = 0
skill_choose = 0
sprite_index = spr_iron_man_mouse_drop
is_boss = true
death_spr = spr_iron_man_mouse_death

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