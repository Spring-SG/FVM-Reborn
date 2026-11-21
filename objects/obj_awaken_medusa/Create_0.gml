// Inherit the parent event
event_inherited();

mouse_id = "awaken_medusa"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 150000
maxhp = 150000
immune_to_ash = true
wait_time = 300
cave = noone
sprite_index = spr_awaken_medusa_idle
is_boss = true

x_move_speed = 0
y_move_speed = 0

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false

// ===== 技能1：三行齐射 =====
skill1_damage = 50				// 子弹对每张卡片的伤害（每张卡片每颗子弹只吃一次）
skill1_bullet_speed = 8		// 子弹每帧左移像素
skill1_rows = 1					// 以自身所在行为中心，向前方 2*1+1 = 3 行各射一颗
skill1_fire_time = 9 * 5		// 第 9 张图时开火
skill1_anim_frames = 18			// 技能1 动画半段帧数

// ===== 技能2：全场冰封 =====
skill2_freeze_time = 600		// 冰冻帧数（不做加法，低于该值直接补到 600）
skill2_col_min = 0				// 冰封列范围（0 基，含）：1 基的第 1 列
skill2_col_max = 5				// 冰封列范围（0 基，含）：1 基的第 6 列
skill2_freeze_time_point = 10 * 5	// 第 10 张图时结算冰封
skill2_anim_frames = 18			// 技能2 动画半段帧数

// ===== 技能3：治疗与提速 =====
skill3_heal = 600				// 全场老鼠回复的生命值
skill3_speed_add = 0.15			// 全场老鼠 move_speed 增量
skill3_ready_time = 10 * 5		// 准备动画（spr_awaken_medusa_skill_3_ready 10 帧）
skill3_cast_time = 69 * 5		// 施法动画（spr_awaken_medusa_skill_3 23 帧）
skill3_return_time = 5 * 5		// 返回动画（spr_awaken_medusa_skill_3_return 5 帧）

// ===== 技能3 提速记录 =====
// 每项为 { inst: 老鼠实例, add: 本次增加的速度 }，技能结束 / BOSS 被击杀时原样还原
speedup_enemy_list = []

/// 还原技能3 提速过的老鼠：技能结束、BOSS 被击杀时都会调用，可重复调用
release_speedup = function(){
	if array_length(speedup_enemy_list) <= 0{
		return
	}
	for(var i = 0 ; i < array_length(speedup_enemy_list) ; i++){
		var _item = speedup_enemy_list[i]
		if instance_exists(_item.inst){
			_item.inst.move_speed -= _item.add
		}
	}
	speedup_enemy_list = []
}

/// 技能3 生效：全场老鼠回血，存活的非 BOSS 老鼠提速，并记下来等技能结束还原
apply_heal_and_speedup = function(){
	release_speedup()
	with obj_enemy_parent{
		if hp > 0{
			hp = min(hp + other.skill3_heal,maxhp)
			var _effect = instance_create_depth(x,y-45,depth-1,obj_card_heal_effect)
			_effect.sprite_index = spr_mouse_heal_effect
		}
		if move_speed > 0 && !is_boss{
			move_speed += other.skill3_speed_add
			array_push(other.speedup_enemy_list,{inst: id, add: other.skill3_speed_add})
		}
	}
}

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}