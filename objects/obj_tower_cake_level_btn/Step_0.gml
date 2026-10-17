if obj_tower_cake_bg.level_select == btn_index{
	image_index = 1
}
else{
	image_index = 0
}

// 瀑布流入场（等级 2）：从下方 46px 滑上来 + 淡入，非线性 ease-out
if (wf_t < wf_dur) {
        wf_t++;
        var _p = clamp(wf_t / wf_dur, 0, 1);
        var _e = ui_anim_ease(_p);
        y = wf_y0 + (1 - _e) * 46;
        image_alpha = _e;
} else {
        y = wf_y0;
        image_alpha = 1;
}
