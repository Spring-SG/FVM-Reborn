if (!surface_exists(info_surface)) {
    // 创建表面用于绘制圆形头像
    info_surface = surface_create(surface_width, surface_height);
}
if (!surface_exists(anim_surf)) {
    // 过渡用：整个菜单先画到这个整屏 surface，再分左右两半错开贴上 —— 这样文字/贴图也能整体淡入
    anim_surf = surface_create(room_width, room_height);
}