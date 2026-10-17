// 绘制悬停提示（已优化）
if global.is_paused{
	exit
}
        if (hover_alpha > 0) {
            var _tt_extra = "";
            if (!is_ready && global.flame < current_cost && cooldown_timer >= cooldown) _tt_extra = "\n火力不足的火箭";
            else if (!is_ready && cooldown_timer < cooldown) _tt_extra = "\n正在冷却中";
            if (slot_index <= 14) {
                tooltip_set(x, y + 60, description + _tt_extra, 0, 0.7, 0,
                            { fill: make_color_rgb(50, 50, 80), border: merge_color(c_yellow, c_white, 0.3), text_col: c_black });
            } else {
                tooltip_set(x - 47, y + 25, description + _tt_extra, -1, 0.7, 0,
                            { fill: make_color_rgb(50, 50, 80), border: merge_color(c_yellow, c_white, 0.3), text_col: c_black });
            }
        }

        // 提示框：推进尺寸/消失动画并绘制（每帧一次）
        tooltip_draw();