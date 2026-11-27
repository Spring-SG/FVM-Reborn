#macro kDefaultAvatar spr_player_character_icon
image_xscale = 0.9
image_yscale = 0.9
menu_type = 0
// 致谢按钮（spr_credits_btn，左中锚点、2 倍绘制成 60×40）挂在全屏按钮正上方：
// 与全屏按钮同一左沿 x+385，中心 y = 73 - 40 = 33
instance_create_depth(x + 405,y + 35,depth-1,obj_credits_btn)
instance_create_depth(x + 385,y + 73,depth-1,obj_fullscreen_btn)
instance_create_depth(x + 362,y + 113,depth-1,obj_edit_btn)
instance_create_depth(x + 339,y + 153,depth-1,obj_config_btn)
// 创建事件中初始化变量

self.avatar_size = 115;
/// @type {Asset.GMObject.ClipRRect} 
var _avatar = instance_create_depth(x + 30, y + 20, depth - 1, ClipRRect)
_avatar.set_sprite(kDefaultAvatar)
    .set_size(avatar_size, avatar_size)
    .set_radius(avatar_size / 2)
    .set_sprite_offset(64, 64)
    .set_sprite_scale(1)
    .set_use_custom_scale(true)
    .finish_init()
self.avatar = _avatar

