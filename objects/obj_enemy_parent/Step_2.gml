damage_amount = 0
damage_type = ""

if not hp_modified{
	if global.difficulty == 0{
		maxhp *= 0.8
		hp *= 0.8
		helmet_hp *= 0.8
		helmet_max_hp *= 0.8
		shield_hp *= 0.8
		shield_max_hp *= 0.8
	}
	if global.difficulty >= 3{
		if global.map_id != "tower_cake"{
			maxhp *= 1.2
			hp *= 1.2
			helmet_hp *= 1.2
			helmet_max_hp *= 1.2
			shield_hp *= 1.2
			shield_max_hp *= 1.2
		}
		else{
			maxhp *= 1.2
			hp *= 1.2
			helmet_hp *= 1.2
			helmet_max_hp *= 1.2
			shield_hp *= 1.2
			shield_max_hp *= 1.2
		}
	}
	if is_real(global.level_file.version) && !is_boss{
		maxhp *= global.level_file.hp_modify
		hp *= global.level_file.hp_modify
		helmet_hp *= global.level_file.hp_modify
		helmet_max_hp *= global.level_file.hp_modify
		shield_hp *= global.level_file.hp_modify
		shield_max_hp *= global.level_file.hp_modify
	}

	hp_modified = true
}
with obj_lava{
	if other.grid_row == row && other.grid_col == col &&
	(other.target_type == "normal" || other.target_type == "dance" || other.target_type == "air" || other.target_type == "obstacle"){
		other.move_speed_modify = 2
		break
	}
	else{
		other.move_speed_modify = 1
	}
}

// Boss状态切换到技能时广播给客户端
if (global.network.mode == "server" && is_boss && state != _state_prev) {
	{
		if (ds_map_exists(global.network.map_instance_id_net_id, id)) {
			var _net_id = global.network.map_instance_id_net_id[? id];
			var _ps = { state: state, timer: timer, x: x, y: y };
			if (variable_instance_exists(id, "x_move_speed"))      { _ps.x_move_speed      = x_move_speed;      }
			if (variable_instance_exists(id, "y_move_speed"))      { _ps.y_move_speed      = y_move_speed;      }
			if (variable_instance_exists(id, "target_pos"))        { _ps.target_pos        = target_pos;        }
			if (variable_instance_exists(id, "skill_timer"))       { _ps.skill_timer       = skill_timer;       }
			if (variable_instance_exists(id, "jump_times"))        { _ps.jump_times        = jump_times;        }
			if (variable_instance_exists(id, "skill_move_type"))   { _ps.skill_move_type   = skill_move_type;   }
			if (variable_instance_exists(id, "skill_choose"))      { _ps.skill_choose      = skill_choose;      }
			if (variable_instance_exists(id, "skill_change_style")){ _ps.skill_change_style = skill_change_style;}
			if (variable_instance_exists(id, "is_reversed"))       { _ps.is_reversed       = is_reversed;       }
			if (variable_instance_exists(id, "image_angle"))       { _ps.image_angle       = image_angle;       }
			if (variable_instance_exists(id, "image_xscale"))      { _ps.image_xscale      = image_xscale;      }
			if (variable_instance_exists(id, "image_alpha"))       { _ps.image_alpha       = image_alpha;       }
			if (variable_instance_exists(id, "move_time"))         { _ps.move_time         = move_time;         }
			if (variable_instance_exists(id, "grid_col"))          { _ps.grid_col          = grid_col;          }
			if (variable_instance_exists(id, "grid_row"))          { _ps.grid_row          = grid_row;          }
			var _props = json_stringify(_ps);
			var _list = global.network.connected_clients;
			for (var _i = 0; _i < array_length(_list); _i++) {
				send_message(_list[_i], MSG_MODIFY_PROP, _net_id, _props);
			}
		}
	}
}
_state_prev = state;
