/// @function array_deep_copy(array)
/// @param {array} arr 要拷贝的数组
/// @return {array} 全新的深拷贝数组
/// @description 深拷贝数组
function array_deep_copy(arr) {
    if (!is_array(arr)) return arr; // 非数组直接返回
    
    var rows = array_length(arr);
    var copy = array_create(rows); // 创建新数组
    
    for (var i = 0; i < rows; i++) {
        var elem = arr[i];
        if (is_array(elem)) {
            // 嵌套数组，递归拷贝
            copy[i] = array_deep_copy(elem);
        } else {
            // 基本类型（数值、字符串、布尔等）直接赋值
            copy[i] = elem;
        }
    }
    return copy;
}