/// @function save_file(file_slot)
/// @desc 将全局变量global.save_data保存到存档文件中
/// @param {real} file_slot 存档槽位
function save_file(file_slot) {
	var file_path = "saves/"+"save" + string(file_slot) + ".json"
    // 将数据转换为JSON字符串
    var json_string = json_stringify(global.save_data);
    
    // 打开文件进行写入
    var file = file_text_open_write(file_path);
    if (file == -1) {
		show_notice("存档保存失败，请重试",60)
        show_debug_message("无法创建存档文件!");
        return false;
    }
    
    // 写入数据
    file_text_write_string(file, json_string);
    file_text_close(file);
    
    show_debug_message("存档保存成功!");
    return true;
}