image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

cookbook_title = "南翔小笼包"
btn_index = 0
desc = ""
spr_index = 0
cookbook_id = "nanxiang_bun"
cookbook_rank = 0

banding_btn = instance_create_depth(x+280,y,depth-1,obj_equipcookbook_btn)

// 瀑布流入场（由 obj_cookbook_bg 的 refresh_cookbook_list 赋值）
wf_t   = 999
wf_dur = 18
wf_off = 0
wf_a   = 1
