// 卡片飞行动画（顶层副本）：只在卡片还没进入可视卡池范围时画
// 这一份负责卡片从卡槽下来那一路上（还在卡池之外）不被卡组按钮那排挡住的显示
// 卡片进入卡池后交给 Draw_0 里画在卡池 surface 上的那份 —— 那份超出可视卡池的部分会被 surface 裁掉
// 两份的位置算法必须一致；卡池上沿要和 Draw_0 第 124 行 draw_surface 的落点对齐
var _pool_top = y + 375 - 48
var _card_half = 40   // 卡片精灵约半个高度，用来判断"还没完全进入卡池"
if fly_active && sprite_exists(fly_spr){
	var _p = fly_t / fly_dur
	var _e = 1 - (1 - _p) * (1 - _p) * (1 - _p)
	var _fx = lerp(fly_sx, fly_tx, _e)
	var _fy = lerp(fly_sy, fly_ty, _e)
	if _fy - _card_half < _pool_top{
		draw_sprite_ext(spr_slot, 0, _fx, _fy - 3, 0.25, 0.25, 0, c_white, 1)
		draw_sprite_ext(fly_spr, 0, _fx, _fy + 15, 0.7, 0.7, 0, c_white, 1)
	}
}
// 清空时批量飞回卡池的那一份（顶层副本，同样只管"还没进入卡池"的那一段）
for (var _bi = 0; _bi < array_length(fly_batch); _bi++){
	var _b  = fly_batch[_bi]
	var _bp = max(0, _b.t) / _b.dur
	var _be = 1 - (1 - _bp) * (1 - _bp) * (1 - _bp)
	var _bx = lerp(_b.sx, _b.tx, _be)
	var _by = lerp(_b.sy, _b.ty, _be)
	if _by - _card_half < _pool_top{
		draw_sprite_ext(spr_slot, 0, _bx, _by - 3, 0.25, 0.25, 0, c_white, 1)
		draw_sprite_ext(_b.spr, 0, _bx, _by + 15, 0.7, 0.7, 0, c_white, 1)
	}
}
