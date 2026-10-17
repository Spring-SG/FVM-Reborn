// Pre-Draw：比所有 depth 图层、Draw GUI 都早。
// 这个项目房间的背景层是隐藏的（room_map 的 Background 层 visible=false），场景没画到的像素
// 会保留上一帧 —— UI 滑过又离开后那些像素就留在屏幕上。每帧先把整块 application_surface
// 铺成不透明黑：之后照常被场景覆盖，只有「谁都不画」的地方会变成黑，不再留上一帧的东西。
draw_clear(c_black)
