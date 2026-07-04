function update_attire() {
	var _avatar_sprite = kDefaultAvatar
	
	var _id = card_equipped_attire_id("player")
	if (_id != -1 && _id != "" && _id != undefined && _id != noone) {
		var _target_sprite = asset_get_index("spr_" + string(_id) + "_icon")
		if (_target_sprite != -1) {
			_avatar_sprite = _target_sprite
		}
	}

	self.avatar.set_sprite(_avatar_sprite)
}


if menu_type == 2{
	if not instance_exists(obj_config_menu){
		instance_create_depth(room_width/2,room_height/2,-5,obj_config_menu)
	}
}
if menu_type == 1{
	if not instance_exists(obj_edit_menu){
		instance_create_depth(room_width/2,room_height/2,-5,obj_edit_menu)
	}
}

update_attire()