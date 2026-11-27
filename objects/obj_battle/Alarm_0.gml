// 关卡引导提示：开战后 1 秒弹一次，持续 600 帧（10 秒）
// 内容由 obj_battle 的 Create 从 global.level_guide_tip 取来（沙漠两关的防龙卷风 / 防沙尘暴提示）
if (guide_tip_text != ""){
	show_notice(guide_tip_text, 600)
	guide_tip_text = ""
}