// Inherit the parent event
event_inherited();

mouse_id = "war_god"
jump_times = 0
state = BOSS_STATE.IDLE
hp = 250000
maxhp = 250000
immune_to_ash = true
wait_time = 18 * 60
move_speed = 0.072
sprite_index = spr_war_god_idle
is_boss = true
skill_count = 0

appear = false
image_alpha = 0

var up_pos = get_world_position_from_grid(8,1)
up_inst = instance_create_depth(up_pos.x,up_pos.y+38,-800,obj_war_god_duck)
var down_pos = get_world_position_from_grid(8,5)
down_inst = instance_create_depth(down_pos.x,down_pos.y+38,-800,obj_war_god_duck)

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}