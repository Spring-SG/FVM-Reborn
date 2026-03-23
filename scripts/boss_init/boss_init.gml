function boss_init(){
	boss_registry_init()
	register_boss("mario_mouse",{"name":"洞君","hp":9000,"icon":spr_mario_mouse_icon})
	register_boss("arno",{"name":"阿诺","hp":8000,"icon":spr_arno_icon})
	register_boss("temple_pharaoh",{"name":"法老原形","hp":12000,"icon":spr_pharaoh_icon})
	register_boss("ice_residue",{"name":"冰渣","hp":12000,"icon":spr_ice_residue_icon})
	register_boss("rumble",{"name":"轰隆隆","hp":20000,"icon":spr_rumble_icon})
	register_boss("abyss_pharaoh",{"name":"法老鼠","hp":35000,"icon":spr_pharaoh_icon})
	register_boss("pink_paul",{"name":"粉红保罗","hp":25000,"icon":spr_pink_paul_icon})
	register_boss("blonde_mary",{"name":"金发玛丽","hp":30000,"icon":spr_blonde_mary_icon})
	register_boss("pete",{"name":"钢爪皮特","hp":40000,"icon":spr_pete_icon})
}