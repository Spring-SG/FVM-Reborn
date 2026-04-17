/// 

self.state = {
    left: 0,
    top: 0,
    /// @type {Array<Asset.GMObject.Button>} 
    elements: [],
    width: 300,
    height: 300,
    grid_list: undefined
}

function create_widgets() {
    var _items = []

    /// @type {Asset.GMObject.Button} 
    var _laboratory_entrance = instance_create_depth(0, 0, -3, Button)
    _laboratory_entrance.set_sprite(spr_laboratory_icon)
                        .set_scale(1.8)
                        .set_on_click(function() {
                            global.gui_stack.to(room_laboratory)
                        })

    array_push(_items, _laboratory_entrance)

    /// @type {Asset.GMObject.GridList} 
    self.state.grid_list = instance_create_layer(self.state.left, self.state.top, "Instances", GridList)
    self.state.grid_list.set_viewport(self.state.left, self.state.top, self.state.width, self.state.height)
                        .set_items(_items)
                        .set_grid_x(8)
}

/// @param {Real} _left 
/// @param {Real} _top 
/// @returns {Asset.GMObject.EventEntranceList} 
function set_position(_left, _top) {
    self.state.left = _left
    self.state.top = _top
    self.state.grid_list.set_viewport(self.state.left, self.state.top, self.state.width, self.state.height)
    return self
}

function set_size(_width, _height) {
    self.state.width = _width
    self.state.height = _height
    self.state.grid_list.set_viewport(self.state.left, self.state.top, self.state.width, self.state.height)
    return self
}

/// @description Events
function on_create() {
    self.state.left = x
    self.state.top = y
    create_widgets()
}

function on_step() {

}

function on_draw() {
    
}

on_create()