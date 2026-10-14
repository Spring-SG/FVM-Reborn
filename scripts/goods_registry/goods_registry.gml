function goods_registry_init(){
	global.goods_map = ds_map_create()
	global.goods_id_pool = []
}

function register_goods(goods_id,data){
	global.goods_map[? goods_id] = data
	array_push(global.goods_id_pool,goods_id)
}