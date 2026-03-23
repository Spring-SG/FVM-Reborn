event_inherited()
image_xscale = 1.8
image_yscale = 1.8
image_speed = 0
//sprite_index = spr_mario_mouse_idle
atk = 10 //每次攻击伤害
atk_cycle = 0.6 * 60 //攻击间隔
move_speed = 0.32 //移动速度（像素/秒）
hp = 180
maxhp = 180
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
is_slowdown = false
ice_timer = 0
is_frozen = false
frozen_timer = 0
ice_sprite = spr_mouse_frozen
current_frozen = false

// 加载Shader
shader_hit = hit_effect_2
u_progress = shader_get_uniform(shader_hit, "u_progress");
u_flashColor = shader_get_uniform(shader_hit, "u_flashColor");

flash_color = #FFFFFF

grid_col = 99
grid_row = 99