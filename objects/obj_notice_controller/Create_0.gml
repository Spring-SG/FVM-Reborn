depth = -9900
// 切换遮罩与 toast 都挂在这个常驻对象上：只留一个实例。
// 出现第二个（先被脚本按需创建、又被房间预置创建）会让切换状态一帧推进两次、遮罩叠画两次 → 看起来就是闪一下。
if (instance_number(obj_notice_controller) > 1){
    instance_destroy()
    exit
}