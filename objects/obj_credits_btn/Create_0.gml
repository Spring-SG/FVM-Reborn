/// 致谢按钮：使用 spr_credits_btn（第 0 帧 = 普通，第 1 帧 = 悬停）
/// 精灵原点在左中（xorigin 0 / yorigin 10），和右侧的图标按钮同一套锚点
sprite_index = spr_credits_btn
image_speed  = 0
// 精灵只有 30×20，按 2 倍绘制（60×40），与右侧 78×48@0.9 ≈ 70×43 的图标按钮同一档大小
image_xscale = 1.8
image_yscale = 1.8

// 实际绘制矩形（Step 的命中判定 / Draw 的提示框定位共用）
dw = sprite_get_width(sprite_index) * image_xscale
dh = sprite_get_height(sprite_index) * image_yscale
dx = sprite_get_xoffset(sprite_index) * image_xscale
dy = sprite_get_yoffset(sprite_index) * image_yscale

hover = false      // 鼠标是否停在按钮上（决定用第几帧 + 是否出提示框）
armed = false      // 已在本按钮上按下、等待松开
