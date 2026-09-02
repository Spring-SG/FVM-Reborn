clevel = get_card_info_simple(card_id).level
cshape = get_card_info_simple(card_id).shape
//cskill = get_card_info_simple(card_id).skill
var plant_data = get_plant_data(card_id);
if (plant_data != undefined) {
	
	var card_save_data = get_card_info(card_id)
	clevel = card_save_data.level
	cshape = card_save_data.shape
	cskill = card_save_data.skill
    
    // 应用基础属性
    var upgrade_data = get_plant_data_with_skill(card_id, cshape,clevel,cskill);
    if (upgrade_data != undefined) {
        cost = upgrade_data[? "cost"];
        cooldown = upgrade_data[? "cooldown"];
    }
	//检查食谱
	var cookbook_list = global.save_data.equipped_cookbook
	for(var i = 0 ; i < array_length(cookbook_list) ; i++){
		for(var j = 0 ; j < array_length(cookbook_list[i]) ; j++){
			var cookbook_data = get_cookbook_data(cookbook_list[i][j])
			var modifs = cookbook_data.modif
			for(var k = 0 ; k < array_length(modifs) ; k++){
				if array_get_index(modifs[k].card_id,card_id) != -1{
					if variable_instance_exists(self,modifs[k].modif_type){
						if modifs[k].modif_calc == "plus"{
							variable_instance_set(self,modifs[k].modif_type,variable_instance_get(self,modifs[k].modif_type)+modifs[k].amount)
						}
						else if modifs[k].modif_calc == "multiply"{
							variable_instance_set(self,modifs[k].modif_type,variable_instance_get(self,modifs[k].modif_type)*modifs[k].amount)
						}
					}
				}
			}
		}
	}
	
}
info_got = true