// Inherit the parent event
event_inherited();

mouse_id = "tribal_chief_mouse"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 50000
maxhp = 50000
immune_to_ash = true
wait_time = 300
sprite_index = spr_tribal_chief_mouse_idle
is_boss = true

x_move_speed = 0
y_move_speed = 0

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false

// ===== 技能1：冲锋 =====
skill1_phase = 0			// 0左冲准备 1左冲 2左冲收势 3翻面待机 4纵向换行 5右冲准备 6右冲 7右冲收势 8收尾待机
skill1_row = 3				// 技能1 当前所在行（0 基）
dash_target_x = 0			// 本次冲刺的终点 x
skill1_card_damage_rate = 0.0025	// 每摧毁一张卡片扣除自身最大生命的比例

// ===== 技能2：图腾砸击 =====
skill2_row = 2				// 站位行（0 基）：2 = 1 基第 3 行，4 = 1 基第 5 行
skill2_target_row = 1		// 落点行（0 基）
skill2_target_col = 3		// 落点列（0 基，1 基第 4 列）

// ===== 技能3：冰封 =====
skill3_row = 3
skill3_freeze_time = 600	// 冰冻帧数（不做加法，低于该值直接补满）
skill3_front_cols = 3		// 前方冰封列数

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}