// obj_text_input 全局鼠标按下事件
// 检查是否点击了输入框
if (point_in_rectangle(mouse_x, mouse_y, x, y, x + width, y + height)) {
    active = true;
    // 屏蔽输入法，防止中文候选框在输入时弹出（只收 ASCII 见 KeyPress_1）
    if (native_disable_ime != undefined) {
        native_disable_ime();
    }
} else {
    active = false;
}