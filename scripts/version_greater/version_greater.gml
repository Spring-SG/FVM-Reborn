/// version_greater(version1, version2)
/// @param {string} version1 string (e.g., "1.2.3")
/// @param {string} version2 string (e.g., "1.2.4")
/// @return bool 
/// @description 如果v1>v2,则返回true
function version_greater(version1,version2){
	var v1_str = version1;
	var v2_str = version2;

	// 简单分割字符串，这里为了方便手动处理，如果不依赖扩展可以用以下循环
	var v1_arr = [];
	var v2_arr = [];

	// 将 "1.2.3" 转换为数组 [1, 2, 3]
	var temp_str = v1_str;
	var dot_pos = string_pos(".", temp_str);
	while (dot_pos > 0) {
	    var part = real(string_copy(temp_str, 1, dot_pos - 1));
	    array_push(v1_arr, part);
	    temp_str = string_delete(temp_str, 1, dot_pos);
	    dot_pos = string_pos(".", temp_str);
	}
	array_push(v1_arr, real(temp_str)); // 最后一部分

	// 处理第二个版本号
	temp_str = v2_str;
	dot_pos = string_pos(".", temp_str);
	while (dot_pos > 0) {
	    var part = real(string_copy(temp_str, 1, dot_pos - 1));
	    array_push(v2_arr, part);
	    temp_str = string_delete(temp_str, 1, dot_pos);
	    dot_pos = string_pos(".", temp_str);
	}
	array_push(v2_arr, real(temp_str));

	// 比较数组的每一位
	var len = max(array_length(v1_arr), array_length(v2_arr));
	for (var i = 0; i < len; i++) {
	    var num1 = (i < array_length(v1_arr)) ? v1_arr[i] : 0;
	    var num2 = (i < array_length(v2_arr)) ? v2_arr[i] : 0;
    
	    if (num1 > num2) return true;
	    if (num1 < num2) return false;
	}

	return false; // 版本相等
}
