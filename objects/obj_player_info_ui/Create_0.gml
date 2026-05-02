#macro kDefaultAvatar spr_player_character_icon
image_xscale = 1.8
image_yscale = 1.8
menu_type = 0
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
    .set_sprite_scale(1.5)
    .set_use_custom_scale(true)
    .finish_init()
self.avatar = _avatar

