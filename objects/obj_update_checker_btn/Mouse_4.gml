audio_play_sound(snd_button,0,0)

show_notice("正在检查更新...",60);
// 创建请求头 DS Map
var headers = ds_map_create();
// GitHub API 强制要求 User-Agent，这里填你的游戏名或仓库名
ds_map_add(headers, "User-Agent", "FVM-Reborn"); 

// 使用 http_request 发送 GET 请求
// 参数依次为：URL, 请求方法, 请求头, 请求体(GET请求留空即可)
update_request_id = http_request(github_api_url, "GET", headers, "");

// 销毁请求头 Map，防止内存泄漏
ds_map_destroy(headers);


