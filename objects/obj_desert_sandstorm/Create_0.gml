// ===== 沙尘暴（按格生成的覆盖层，思路同 obj_fog） =====
// spr_desert_sandstorm 共 30 帧，贴图里自带出现与消失动画：
//   0 ~ 5     出现
//   6 ~ 22    循环
//   23 ~ 29   消失
frame_appear_end = 6
frame_loop_start = 7
frame_loop_end = 21
frame_vanish_start = 22
frame_vanish_last = 29

sprite_index = spr_desert_sandstorm
image_speed = 0
image_index = 0
image_xscale = 1.8
image_yscale = 1.8
image_alpha = 1

// 状态：appear(出现动画) / idle(循环) / vanish(消失动画)
state = "appear"
anim_frame = 0
anim_timer = 0
anim_delay = 5

col = -1
row = -1

// 被覆盖前的格子特性，退场时原样还原（参考 obj_barrier）
current_grid_type = ""
grid_claimed = false

depth = -800

/// 开始播放消失动画（被 obj_ventilation_fan 吹散时调用，可重复调用）
start_vanish = function(){
	if state == "vanish"{
		return
	}
	state = "vanish"
	anim_frame = frame_vanish_start
	anim_timer = 0
}