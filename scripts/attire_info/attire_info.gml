///@function is_attire_unlocked(attire_id)
///@description 判断时装是否解锁
///@param {string}attire_id 时装id
///@return {bool}
function is_attire_unlocked(attire_id){
	var attire_list = global.save_data.attires
	for(var i = 0 ; i < array_length(attire_list) ; i++){
		if attire_list[i].attire_id == attire_id{
			return true
		}
	}
	return false
}

///@function card_equipped_attire_id(card_id)
///@description 找到卡片已装备的时装id。如果没有则返回-1。
///@param {string}card_id 卡片id
///@return {string}
function card_equipped_attire_id(card_id){
	var attire_list = global.save_data.attires
	for(var i = 0 ; i < array_length(attire_list) ; i++){
		var attire_data = get_attire_info(attire_list[i].attire_id)
		if attire_data.target_card == card_id && attire_list[i].state == "equipped"{
			return attire_list[i].attire_id
		}
	}
	//如果没有找到对应时装，则返回-1
	return -1
}

///@function unlock_attire(attire_id)
///@description 解锁时装
///@param {string}attire_id 时装id
function unlock_attire(attire_id){
	//在时装数组中添加对应时装
	if !is_attire_unlocked(attire_id){
		array_push(global.save_data.attires,{"attire_id":attire_id,"state":"unequipped"})
	}
}

///@function get_attire_state(attire_id)
///@description 判断时装装备状态。如果未解锁则返回-1。
///@param {string}attire_id 时装id
///@return {string}
function get_attire_state(attire_id){
	//未解锁则返回-1
	if !is_attire_unlocked(attire_id){
		return -1
	}
	//在时装数组中寻找对应时装并返回状态
	var attire_list = global.save_data.attires
	for(var i = 0 ; i < array_length(attire_list) ; i++){
		if attire_list[i].attire_id == attire_id{
			return attire_list[i].state
		}
	}
}

///@function edit_attire_state(attire_id,new_state)
///@description 修改时装装备状态
///@param {string}attire_id 时装id
///@param {string}new_state 新状态
function edit_attire_state(attire_id,new_state){
	//未解锁则立即退出
	if !is_attire_unlocked(attire_id){
		return
	}
	//在时装数组中寻找对应时装并修改状态
	var attire_list = global.save_data.attires
	for(var i = 0 ; i < array_length(attire_list) ; i++){
		if attire_list[i].attire_id == attire_id{
			global.save_data.attires[i].state = new_state
		}
	}
}

///@function get_card_attire_list(card_id)
///@description 获取一张卡片的全部时装列表
///@param {string}card_id 卡片id
///@return {array}
function get_card_attire_list(card_id){
	var attire_id_list = []
	//遍历时装数组寻找目标卡片为card_id的时装
	var attire_list = global.save_data.attires
	for(var i = 0 ; i < array_length(attire_list) ; i++){
		var attire_data = get_attire_info(attire_list[i].attire_id)
		if attire_data.target_card == card_id{
			//如果找到，加入到时装id数组中
			array_push(attire_id_list,attire_list[i].attire_id)
		}
	}
	return attire_id_list
}

///@function equip_attire(attire_id)
///@description 装备时装
///@param {string}attire_id 要装备的时装id
function equip_attire(attire_id){
	//如果未解锁则退出
	if !is_attire_unlocked(attire_id){
		return
	}
	//获取卡片对应的全部时装
	var attire_data = get_attire_info(attire_id)
	var attire_id_list = get_card_attire_list(attire_data.target_card)
	//将其他时装全部设置为未装备
	for(var i = 0 ; i < array_length(attire_id_list) ; i++){
		edit_attire_state(attire_id_list[i],"unequipped")
	}
	//将自身设置为已装备
	edit_attire_state(attire_id,"equipped")
}

///@function unequip_attire(attire_id)
///@description 取消装备时装
///@param {string}attire_id 要取消的时装id
function unequip_attire(attire_id){
	//如果未解锁则退出
	if !is_attire_unlocked(attire_id){
		return
	}
	//将自身设置为未装备
	edit_attire_state(attire_id,"unequipped")
}
