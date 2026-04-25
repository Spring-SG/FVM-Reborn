/// @function show_notice(notice_text,life)
/// @description 在屏幕上显示通知
/// @param {string} notice_text 通知文本
/// @param {real} life 通知存在的时间
function show_notice(notice_text, life) {
    // 创建通知数据结构
    var notice = {
        text: notice_text,
        life: life,
        total_life: life,
        frames: 0,
        alpha: 0,
        scale: 1.2,
        pos_x: room_width / 2,
        pos_y: room_height / 3,
        target_y: camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) / 3
    };
    
    // 如果没有全局通知列表，则创建一个
    if (!variable_global_exists("notice_list")) {
        global.notice_list = [];
    }
    
    // 将新通知添加到列表
    array_push(global.notice_list, notice);
}

// 在某个控制对象的步事件中更新所有通知
function update_notices() {
    if (!variable_global_exists("notice_list")) return;
    
    var camera_x = camera_get_view_x(view_camera[0]);
    var camera_y = camera_get_view_y(view_camera[0]);
    var camera_w = camera_get_view_width(view_camera[0]);
    var camera_h = camera_get_view_height(view_camera[0]);
    
    for (var i = array_length(global.notice_list) - 1; i >= 0; i--) {
        var notice = global.notice_list[i];
        notice.frames++;
        
        // 更新位置以确保通知保持在屏幕中心偏上
        notice.pos_x = room_width / 2;
        //notice.target_y = camera_y + camera_h / 3;
        //notice.pos_y = notice.target_y;
        
        // 前20帧：淡入和缩放效果
        if (notice.frames <= 10) {
            notice.alpha = notice.frames / 10;
            notice.scale = 2.2 - (0.2 * (notice.frames / 10));
        }
        // 生命周期结束前的阶段
        else if (notice.frames > notice.life) {
            // 向上移动并淡出
            notice.pos_y -= 2;
            notice.alpha = 1 - ((notice.frames - notice.life) / 20);
            
            // 当完全透明时移除通知
            if (notice.alpha <= 0) {
                array_delete(global.notice_list, i, 1);
                continue;
            }
        }
        
        global.notice_list[i] = notice;
    }
}

// 在绘制事件中绘制所有通知
function draw_notices() {
    if (!variable_global_exists("notice_list")) return;
    
    for (var i = 0; i < array_length(global.notice_list); i++) {
        var notice = global.notice_list[i];
        
        // 设置字体和颜色
        var text = notice.text;
        var pos_x = notice.pos_x;
        var pos_y = notice.pos_y;
        var alpha = notice.alpha;
        var scale = notice.scale;
        
		draw_set_font(font_yuan);
		
        // 计算文本尺寸
        var text_width = string_width(text) * scale;
        var text_height = string_height(text) * scale;
        
        // 绘制半透明黑色背景框
        var padding = 5 * scale;
        draw_set_alpha(0.7 * alpha);
        draw_set_color(c_black);
        draw_roundrect(
            pos_x - text_width/2 - padding,
            pos_y - text_height*scale + padding,
            pos_x + text_width/2 + padding,
            pos_y - text_height + padding*2,
            false // 不绘制轮廓
        );
        
        // 绘制白色描边
        draw_set_alpha(alpha);
        draw_set_color(c_white);
        //draw_set_line_width(2 * scale);
        draw_roundrect(
            pos_x - text_width/2 - padding,
            pos_y - text_height*scale + padding,
            pos_x + text_width/2 + padding,
            pos_y - text_height + padding*2,
            true // 绘制轮廓
        );
        
        // 绘制绿色文本
        draw_set_color(make_color_rgb(0, 255, 0)); // 绿色
        draw_set_font(font_yuan);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_alpha(alpha);
        draw_text_ext_transformed(
            pos_x, pos_y-3, text,90,1920,scale,scale,0
        );
        
        // 重置绘制设置
        draw_set_alpha(1);
        draw_set_color(c_white);
        //draw_set_line_width(1);
    }
}