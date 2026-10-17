
if btn_index >= obj_cookbook_bg.y_offset && btn_index <= obj_cookbook_bg.y_offset + 5{
	y = obj_cookbook_bg.y-145+101*(btn_index-obj_cookbook_bg.y_offset)
}
else{
	y = -1000
}

// 瀑布流入场（等级 2）：逐条从下方 46px 滑上来 + 淡入，非线性 ease-out
if (wf_t < wf_dur) {
        wf_t++;
        var _p = clamp(wf_t / wf_dur, 0, 1);
        var _e = ui_anim_ease(_p);
        wf_off = (1 - _e) * 46;
        wf_a   = _e;
}
else {
        wf_off = 0;
        wf_a   = 1;
}

banding_btn.y = y + wf_off
banding_btn.image_alpha = wf_a
banding_btn.cookbook_id = cookbook_id
banding_btn.cookbook_rank = cookbook_rank