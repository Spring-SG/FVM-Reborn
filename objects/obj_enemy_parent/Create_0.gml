image_xscale = 1.8
image_yscale = 1.8
image_speed = 0
atk = 10 //每次攻击伤害
atk_cycle = 0.6 * 60 //攻击间隔
move_speed = 0.32 //移动速度（像素/秒）
move_speed_modify = 1
hp = 100
maxhp = 100
hurt_rate = 0.5 //切换至受伤状态所需生命值比例
state = ENEMY_STATE.NORMAL //状态
flash_speed = 6
attack_anim = 4 //攻击动画帧数
move_anim = 8
death_anim = 13
flash_value = 0 //受伤闪光计时器
timer = 0
attack_timer = 0
target_plant = noone
attack_range = 90
immune_to_ash = false
ice_timer = 0
is_slowdown = false
frozen_timer = 0
is_frozen = false
ice_sprite = spr_mouse_frozen
helmet_hp = 0
helmet_max_hp = 0
shield_hp = 0
shield_max_hp = 0
special_ash = false
current_frozen = false
is_stun = false
stun_timer = 0
stun_sprite = spr_mouse_stun
mouse_id = ""
giant_type = false
target_type = "normal"
is_boss = false
can_dropped = false

// =======猫驱赶相关=======
is_scare = false
scare_timer = 0
y_move = 0
left_move_flashs = 0

// 加载Shader
shader_hit = hit_effect_2
u_progress = shader_get_uniform(shader_hit, "u_progress");
u_flashColor = shader_get_uniform(shader_hit, "u_flashColor");

flash_color = #FFFFFF

grid_col = 99
grid_row = 99

damage_amount = 0
damage_type = ""

hit_sound = snd_hit1

water_effect_timer = 0
hp_modified = false