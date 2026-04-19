// Inherit the parent event
event_inherited();

mouse_id = "hot_vajra"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 80000
maxhp = 80000
immune_to_ash = true
wait_time = 300
cave = noone
sprite_index = spr_hot_vajra_appear
is_boss = true

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false
avaliable_pos = ds_list_create()
missle_coord = []
spike_count = 0

band_inst1 = noone
band_inst2 = noone

spike_left_1 = noone
spike_left_2 = noone
spike_right_1 = noone
spike_right_2 = noone

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}

/**
 * 将二维数组中所有值为1的点之间的直线路径上的0改为2
 * @param {number[][]} grid - 输入的二维数组，包含0和1
 * @returns {number[][]} - 修改后的新数组，原数组不变
 */
function connectOnesToTwos(grid) {
    if (!is_array(grid) || array_length(grid) == 0) return [];

    var rows = array_length(grid);
    var cols = array_length(grid[0]);

    // 深拷贝原数组，作为结果数组
    var result = array_deep_copy(grid)

    // 收集所有值为1的坐标 [行, 列]
    var ones = [];
    for (var i = 0; i < rows; i++) {
        for (var j = 0; j < cols; j++) {
            if (grid[i][j] == 1) {
                array_push(ones,[i, j]);
            }
        }
    }

    var n = array_length(ones);
    if (n < 2) return result; // 少于2个1无需连线

    /**
     * Bresenham直线算法，返回从起点到终点经过的所有整数坐标点（包含端点）
     * @param {number} x0 - 起点列坐标
     * @param {number} y0 - 起点行坐标
     * @param {number} x1 - 终点列坐标
     * @param {number} y1 - 终点行坐标
     * @returns {Array<[number, number]>} 坐标点数组，每个点为 [列, 行]
     */
    function bresenham(x0, y0, x1, y1) {
        var points = [];
        var dx = abs(x1 - x0);
        var dy = abs(y1 - y0);
        var sx = x0 < x1 ? 1 : -1;
        var sy = y0 < y1 ? 1 : -1;
        var err = dx - dy;
        var xx = x0, yy = y0;

        while (true) {
            array_push(points,[xx, yy]);
            if (xx == x1 && yy == y1) break;
            var e2 = 2 * err;
            if (e2 > -dy) { err -= dy; xx += sx; }
            if (e2 < dx) { err += dx; yy += sy; }
        }
        return points;
    }

    // 遍历所有点对 (i, j)
    for (var i = 0; i < n; i++) {
        for (var j = i + 1; j < n; j++) {
            // 替代数组解构
            var y1 = ones[i][0];
            var x1 = ones[i][1];
            var y2 = ones[j][0];
            var x2 = ones[j][1];

            var linePoints = bresenham(x1, y1, x2, y2);
            // 替代 for...of 解构
            for (var k = 0; k < array_length(linePoints); k++) {
                var px = linePoints[k][0];
                var py = linePoints[k][1];
                if (py >= 0 && py < rows && px >= 0 && px < cols && grid[py][px] == 0) {
                    result[py][px] = 2;
                }
            }
        }
    }

    return result;
}
