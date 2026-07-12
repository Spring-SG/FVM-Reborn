// 强制清除application_surface，避免上一房间图像残留
surface_set_target(application_surface);
draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
surface_reset_target();

global.menu_screen = false
instance_create_depth(1700,883,-2,obj_battlestart_button)
readyroom_music = mus_readyroom

ds_list_clear(global.selected_deck);
//for(var i = 0;i < 21;i++){
//add_to_deck("xiao_long_bao",0);
//}
//add_to_deck("small_fire",get_card_info_simple("small_fire").shape);
//add_to_deck("flour_sack",get_card_info_simple("flour_sack").shape);
//add_to_deck("toast_bread",0)
//add_to_deck("toast_bread",0);
select_card_index = ds_list_create()
hover_card_index = -1
hover_slot_index = -1
slot_rows = 11
slot_cols = 10
slot_surface = -1
map_surface = -1
y_offset = 0

is_submenu_open = false

deck_first_slot_index = 0

selected_custom_deck = 0

for(var i = 1; i < 7;i++){
	var inst = instance_create_depth(x+680+150*i,y+218,depth-5,obj_deck_select_btn)
	inst.deck_index = i
}
instance_create_depth(x+1735,y+215,depth-5,obj_deck_clear_btn)

var prev_btn = instance_create_depth(x+1745,y+105,depth-5,obj_readyroom_slot_btn)
prev_btn.type = "prev"
var next_btn = instance_create_depth(x+1745,y+155,depth-5,obj_readyroom_slot_btn)
next_btn.type = "next"

//统计敌人和BOSS类型
enemy_type_list = []
boss_type_list = []
for(var i = 0;i < global.level_file.total_waves;i ++){
	if global.level_file.waves[i].boss_wave{
		if array_get_index(boss_type_list,global.level_file.waves[i].boss) == -1{
			array_push(boss_type_list,global.level_file.waves[i].boss)
		}
		if is_real(global.level_file.version){
			if array_get_index(boss_type_list,global.level_file.waves[i].boss2) == -1 && global.level_file.waves[i].boss2 != ""{
				array_push(boss_type_list,global.level_file.waves[i].boss2)
			}
		}
	}
	var subwave = global.level_file.waves[i].subwaves
	for(var j = 0 ; j <array_length(subwave);j++){
		var enemy_list = subwave[j].enemy_list
		for(var k = 0 ; k < array_length(enemy_list);k++){
			if array_get_index(enemy_type_list,enemy_list[k].type) == -1{
				array_push(enemy_type_list,enemy_list[k].type)
			}
		}
	}
}

  function _get_needed_sprites() {
      var _list = [];
      var _seen = ds_map_create();

      // 1. 卡组
      for (var i = 0; i < ds_list_size(global.selected_deck); i++) {
          var _cid = ds_list_find_value(global.selected_deck, i);
          // player_deck 是 [key0,val0,key1,val1,...]
          var _card = undefined;
          for (var j = 0; j < ds_list_size(global.player_deck); j += 2) {
              if (global.player_deck[| j] == _cid) {
                  _card = global.player_deck[| j + 1];
                  break;
              }
          }
          if (is_undefined(_card)) continue;
          var _shapes = _card[? "shapes"];
          for (var j = 0; j < ds_list_size(_shapes); j++) {
              var _shape = ds_list_find_value(_shapes, j);
              var _pid = _shape[? "sprite"];
              if (!is_undefined(_pid) && _pid >= 100000) {
                  var _name = sprite_name_from_pid(_pid);
                  if (!is_undefined(_name) && !ds_map_exists(_seen, _name)) {
                      ds_map_add(_seen, _name, true);
                      array_push(_list, _name);
                  }
              }
          }
      }

      // 2. 敌人
      var _all_enemies = [];
      array_copy(_all_enemies, 0, enemy_type_list, 0, array_length(enemy_type_list));
      for (var i = 0; i < array_length(boss_type_list); i++)
          array_push(_all_enemies, boss_type_list[i]);

      for (var i = 0; i < array_length(_all_enemies); i++) {
          var _info = global.enemy_map[? _all_enemies[i]];
          if (is_undefined(_info)) continue;
          var _pid = _info[$ "spr"];
          if (!is_undefined(_pid) && _pid >= 100000) {
              var _name = sprite_name_from_pid(_pid);
              if (!is_undefined(_name) && !ds_map_exists(_seen, _name)) {
                  ds_map_add(_seen, _name, true);
                  array_push(_list, _name);
              }
          }
      }

      ds_map_destroy(_seen);
      return _list;
  }

  function sprite_name_from_pid(_pid) {
      if (is_undefined(global._pid_map)) return undefined;
      var _k = ds_map_find_first(global._pid_map);
      while (!is_undefined(_k)) {
          if (global._pid_map[? _k] == _pid) return _k;
          _k = ds_map_find_next(global._pid_map, _k);
      }
      return undefined;
  }