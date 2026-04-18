depth = -1200

// 强制清除application_surface，避免上一房间图像残留
if surface_exists(application_surface){
	surface_set_target(application_surface);
	draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
	surface_reset_target();
}

instance_create_depth(1355,820,-2,obj_startgame_button)
instance_create_depth(100,0,-2,obj_player_info_ui)

/// @type {Asset.GMObject.EventEntranceList} 
var _entrance_list = instance_create_depth(0, 0, -2, EventEntranceList)
_entrance_list.set_position(600,20)
              .set_size(900, 300)


if not instance_exists(obj_menu_music_controller){
	var mus_inst = instance_create_depth(0,0,0,obj_menu_music_controller)
	mus_inst.menu_music = mus_town
}
if not instance_exists(obj_world_map_button){
	instance_create_depth(1670,80,0,obj_world_map_button)
}
instance_create_depth(room_width-210,room_height,-1,obj_player_menu_bg)
timer = 0

/// @description preload textures




self.texture_to_load = [
	"UI",
	// "cards",
	// "enemy_delicious",
	// "enemy_volcanic",
	// "bullet",
	// "effects",
	// "player",
	"maps",
	// "enemy_tower"
]

self.texture_count = array_length(self.texture_to_load)
self.texture_loaded = 0
global.preloaded = variable_global_exists("preloaded") ? global.preloaded : false
self.display_progress = 0

function after_texture_load() {
    scribble_font_set_default("font_hei")
    scribble_font_bake_outline_4dir("font_hei", "font_hei_outline_4dir_black", c_dkgray, false)
    global.preloaded = true;
}

function pre_load_texture() {
    if (global.preloaded) return;

    if (self.animating) {
        var _target = self.texture_loaded;
        self.display_progress = lerp(self.display_progress, _target, 0.1);

        if (abs(self.display_progress - _target) < 0.01) {
            self.display_progress = _target;
            self.animating = false;
            
            if (self.texture_loaded >= self.texture_count) {
                after_texture_load();
            }
        }
        return;
    }

    if (self.texture_loaded < self.texture_count) {
        texture_prefetch(self.texture_to_load[self.texture_loaded]);
        self.texture_loaded += 1;
        self.animating = true;
    }
}


self.total_progress_bar_width = 350
self.active_bg = $fde98b
self.inactive_bg = c_white
self.active_width = 0
self.offset_x = (room_width - self.total_progress_bar_width) / 2
self.offset_y = (room_height - 20) / 2
self.animating = false
function on_draw() {
    if (!self.animating && self.texture_loaded == 0) return;
    if (global.preloaded) return;

    draw_set_colour(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    var _ratio = (self.texture_count > 0) ? (self.display_progress / self.texture_count) : 0;
    var _current_width = self.total_progress_bar_width * _ratio;

    var _x1 = self.offset_x;
    var _y1 = self.offset_y;
    var _bar_h = 20;

    draw_set_color(self.inactive_bg);
    draw_rectangle(_x1 - 2, _y1 - 2, _x1 + self.total_progress_bar_width + 2, _y1 + _bar_h + 2, false);

    draw_set_color(self.active_bg);
    draw_rectangle(_x1, _y1, _x1 + _current_width, _y1 + _bar_h, false);
    
    draw_set_color(c_white);
    draw_set_font(font_yuan);
    var _text = "Loading " + string(self.texture_loaded) + "/" + string(self.texture_count);
    draw_text(_x1, _y1 - 30, _text);
}

