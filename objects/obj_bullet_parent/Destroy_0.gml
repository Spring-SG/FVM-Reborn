/// obj_bullet_parent :: Destroy
/// 统一释放火盆记录，子对象若重写 Destroy 请先调 event_inherited()

if (variable_instance_exists(id, "brazier_list") && brazier_list != -1) {
	ds_list_destroy(brazier_list);
	brazier_list = -1;
}