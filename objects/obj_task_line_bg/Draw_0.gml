// 瀑布流入场（等级 2）：整行从下方 46px 滑上来 + 淡入（wf_off / wf_a 由 obj_task_bg 给初值、这里推进）
// 与食神谱 obj_cookbook_list_btn 逐行同款：46px / wf_dur 18 / 逐行延迟 2 帧（出场顺序自上而下）
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

draw_sprite_ext(sprite_index, image_index, x, y + wf_off, image_xscale, image_yscale, image_angle,
                c_white, image_alpha * wf_a)
draw_set_font(font_yuan)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_middle)
draw_set_alpha(ui_anim_alpha(id) * wf_a)   // 文字不吃 image_alpha
draw_text(x-200, y + wf_off, task_title)
draw_set_alpha(1)
if obj_task_bg.target_task_index == btn_index{
        image_index = 1
}
else{
        image_index = 0
}

var task_id = obj_task_bg.current_task_list[btn_index].id
state = get_task_state(task_id)

var state_index = 0

if state == "new"{
        state_index = 0
}
else if state == "viewed"{
        state_index = 1
}
else if state == "completed"{
        state_index = 2
}
else if state == "claimed"{
        state_index = 3
}

draw_sprite_ext(spr_task_state, state_index, x + 225, y + wf_off, 1.8, 1.8, 0, c_white, image_alpha * wf_a)
draw_sprite_ext(spr_task_split, 1, x, y + wf_off + sprite_height/2, 1.8, 1.8, 0, c_white, image_alpha * wf_a)
