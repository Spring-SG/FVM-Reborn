if global.is_paused{
	exit
}
event_inherited(); 

// 父对象在 hp <= 0 时会立刻 instance_destroy()，而且 Destroy 事件是同步执行的
// （那里已经解除了本沙拉给 5x5 范围内卡片加的防风与最大生命值加成）。
// 但同一次 Step 事件在被销毁后仍会继续往下跑，如果在这里不返回，
// 下面的代码就会把刚解除的 desert_wind_protect / max_hp 又加回去 ——
// 表现为「被老鼠啃死时防风效果不消失，被铲除时却正常」（铲除是在别的对象里
// 直接 instance_destroy()，不经过本事件）。
if hp <= 0{
	exit
}

var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

if is_frozen || state == CARD_STATE.SLEEP{
	exit
}

if is_slowdown{
	cycle = origin_cycle * 2
}
else{
	cycle = origin_cycle
}

hp_increase_card_list = []
// 本帧重新统计「被本沙拉庇护」的卡片，同时保留上一帧的名单用于解除保护
var _prev_protect_list = desert_wind_card_list
desert_wind_card_list = []

with obj_card_parent{
	if id != other.id{
		var _dr = abs(grid_row - other.grid_row)
		var _dc = abs(grid_col - other.grid_col)
		// 抵御沙漠风：固定以自身为中心的 5x5 格，与 shape 无关
		var _in_wind_range = (_dr <= 2 && _dc <= 2)
		// 回血 / 提升最大生命值：范围仍然与 shape 关联（shape < 1 -> 3x3，否则 5x5）
		var _in_boost_range = (other.shape < 1) ? (_dr <= 1 && _dc <= 1) : _in_wind_range

		if _in_boost_range{
			array_push(other.hp_increase_card_list, id)
			if array_get_index(other.maxhp_increase_card_list, id) == -1{
				array_push(other.maxhp_increase_card_list, id)
				max_hp += other.atk
			}
		}
		else{
			var _idx = array_get_index(other.maxhp_increase_card_list, id)
			if _idx != -1{
				array_delete(other.maxhp_increase_card_list, _idx, 1)
				max_hp -= other.atk
				if hp > max_hp{
					hp = max_hp
				}
			}
		}

		if _in_wind_range{
			array_push(other.desert_wind_card_list, id)
			desert_wind_protect = true
		}
	}
}

// 上一帧还被保护、这一帧已离开 5x5 范围的卡片，取消保护
// 注意：防风草自身自带防风（Create 里直接置 true，不依赖任何沙拉），不能被别人清掉
for(var _i = 0 ; _i < array_length(_prev_protect_list) ; _i ++){
	var _pid = _prev_protect_list[_i]
	if _pid != noone && instance_exists(_pid) && array_get_index(desert_wind_card_list, _pid) == -1{
		with _pid{
			if plant_id != "parsnip_salad"{
				desert_wind_protect = false
			}
		}
	}
}

if (attack_timer <= cycle - attack_anim * current_flash_speed) {
    attack_timer++;
} else if (attack_timer <= cycle) {
    attack_timer++;
    state = CARD_STATE.ATTACK;
} else {
    event_user(1); // 发射子弹
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}