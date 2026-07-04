// Inherit the parent event
event_inherited();

mouse_id = "angelababy"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 60000
maxhp = 60000
immune_to_ash = true
wait_time = 180
skill_choose = 0
skill_change_style = 0
skill_timer = 0
skill_move_type = "act"
sprite_index = spr_angelababy_appear
is_boss = true

image_alpha = 0
appear = false

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}

target_pos = {"row":-1,"col":-1}
target_coord = []
avaliable_pos = ds_list_create()

x_move_speed = 0
y_move_speed = 0