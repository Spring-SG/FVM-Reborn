// Inherit the parent event
event_inherited();

mouse_id = "medusa"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 50000
maxhp = 50000
immune_to_ash = true
wait_time = 240
cave = noone
sprite_index = spr_medusa_idle
is_boss = true

x_move_speed = 0
y_move_speed = 0

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false

// ===== 技能参数 =====
skill1_heal = 600			// 技能1：全场老鼠回复的生命值
skill1_speed_add = 2		// 技能1：全场老鼠 move_speed 增量
skill2_freeze_time = 600	// 技能2：冰冻帧数
skill2_front_cols = 4		// 技能2：自身前方冰封的列数
skill2_row_range = 1		// 技能2：以自身为中心的上下行数（1 即 3 行）

// ===== 技能3 催眠记录 =====
// 每项为 { inst: 卡片实例, prev_state: 催眠前的状态 }
hypno_card_list = []

/// 恢复被催眠的卡片：技能结束、BOSS 被击杀时都会调用，可重复调用
release_hypno = function(){
	if array_length(hypno_card_list) <= 0{
		return
	}
	for(var i = 0 ; i < array_length(hypno_card_list) ; i++){
		var _item = hypno_card_list[i]
		if instance_exists(_item.inst){
			with _item.inst{
				state = _item.prev_state
			}
		}
	}
	hypno_card_list = []
}

/// 催眠全场卡片：只记录原本没睡着的卡片，记下原状态，便于结束后原样恢复
apply_hypno = function(){
	release_hypno()
	with obj_card_parent{
		if state != CARD_STATE.SLEEP{
			array_push(other.hypno_card_list, {inst: id, prev_state: state})
			state = CARD_STATE.SLEEP
		}
	}
}

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}