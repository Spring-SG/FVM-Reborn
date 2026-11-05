image_speed = 0

tooltip_text = ""
on_click = false
is_boss = false          // 由 obj_level_preview 的 BOSS 行置 true，决定用哪一档缩放

// ── 预览裁剪框 + 统一缩放（可配置）────────────────────────────────────
// 老鼠贴图尺寸差异极大（平民鼠 108×104，美杜莎 575×432），而且**画布留白占比从 0.12 到 0.9 不等**。
// 所以这里不按画布大小自适应缩放（那会让留白多的贴图被额外缩小、看起来比同伴小一圈），
// 改成「普通鼠军 / BOSS」各给一个固定缩放值，超出裁剪框的部分由 surface 裁掉。
//   clip_box_w / clip_box_h  裁剪框大小（= surface 尺寸），建议 ≤ 格子间距 170 / 230
//   scale_normal             普通鼠军统一缩放
//   scale_boss               BOSS 统一缩放（BOSS 区格子更大、裁剪框 300×250，所以不用压太小）
// 缩放作用在**裁掉透明留白后的内容**上（见 sprite_trim_get），同类贴图看起来大小一致。
clip_box_w   = 160
clip_box_h   = 210
scale_normal = 1.0
scale_boss   = 0.9
