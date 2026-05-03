/// 
self.state = {
  radius: 0,
  height: 0,
  width: 0,
  initialized: false,
  sprite: undefined,
  sprite_offset_x: 0,
  sprite_offset_y: 0,
  use_custom_scale: false,
  sprite_scale: 1.0,
}

function on_create() {

}

/// @param {Real} _width 
/// @param {Real} _height
/// @returns {Asset.GMObject.ClipRRect} 
function set_size(_width, _height) {
  self.state.width = _width
  self.state.height = _height
  return self
}

/// @param {Real} _radius
/// @returns {Asset.GMObject.ClipRRect} 
function set_radius(_radius) {
  self.state.radius = _radius
  return self
}

/// @param {Asset.GMSprite} _sprite 
/// @returns {Asset.GMObject.ClipRRect} 
function set_sprite(_sprite) {
  self.state.sprite = _sprite
  return self
}

/// @param {Real} _x
/// @param {Real} _y
/// @returns {Asset.GMObject.ClipRRect} 
function set_sprite_offset(_x, _y) {
  self.state.sprite_offset_x = _x
  self.state.sprite_offset_y = _y
  return self
}

/// @param {Real} _scale
/// @returns {Asset.GMObject.ClipRRect}
function set_sprite_scale(_scale) {
  self.state.sprite_scale = _scale
  return self
}

/// @param {Bool} _use_custom_scale
/// @returns {Asset.GMObject.ClipRRect}
function set_use_custom_scale(_use_custom_scale) {
  self.state.use_custom_scale = _use_custom_scale
  return self
}

/// @returns {Asset.GMObject.ClipRRect} 
function finish_init() {
  if (self.state.initialized) return;
  if (self.state.width <= 0 || self.state.height <= 0) return;
  if (self.state.radius < 0) return;
  if (is_undefined(self.state.sprite)) return;

  self.state.initialized = true
  return self
}

function on_draw() {
  if (!self.state.initialized) return

  var _size = [self.state.width, self.state.height]
  var _radius = min(self.state.radius, min(self.state.width, self.state.height) * 0.5)

  var _scale_x = self.state.sprite_scale
  var _scale_y = self.state.sprite_scale

  if (!self.state.use_custom_scale) {
    var _sprite_width = sprite_get_width(self.state.sprite)
    var _sprite_height = sprite_get_height(self.state.sprite)
    _scale_x = self.state.width / _sprite_width
    _scale_y = self.state.height / _sprite_height
  }

  shader_set(ClipRRectShader)
  shader_set_uniform_f_array(shader_get_uniform(ClipRRectShader, "in_size"), _size)
  shader_set_uniform_f(shader_get_uniform(ClipRRectShader, "in_radius"), _radius)
  shader_set_uniform_f_array(shader_get_uniform(ClipRRectShader, "in_origin"), [self.x, self.y])

  draw_sprite_ext(
    self.state.sprite, 0, 
    self.x + self.state.sprite_offset_x, self.y + self.state.sprite_offset_y, 
    _scale_x, _scale_y, 0, c_white, 1)
  shader_reset()
}

/// @description 
on_create()