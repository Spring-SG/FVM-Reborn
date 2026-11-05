// 精灵先画进裁剪面再贴出来：超出裁剪框的部分被裁掉，不会盖住相邻格子。
// 缩放按「普通 / BOSS」两档固定值，不随画布大小变化。
// 锚点：水平居中、**底边贴住实例 y**（和原来"精灵原点在脚底"的视觉位置一致，
// 否则整排预览会比原来低半个框高；悬停判定见 Draw_64，也按 y - h .. y 算）。
var _sc = is_boss ? scale_boss : scale_normal
sprite_clip_draw("mouse_preview", sprite_index, image_index, x, y, clip_box_w, clip_box_h, _sc, image_alpha)
