obj_shell.consoleAlpha = 0.9;
obj_shell.consoleColor = make_color_rgb(235, 235, 235);
obj_shell.fontColor = make_color_rgb(40, 40, 45);
obj_shell.fontColorSecondary = make_color_rgb(120, 120, 128);
obj_shell.autocompleteBackgroundColor = obj_shell.consoleColor;
obj_shell.cornerRadius = 12;
obj_shell.anchorMargin = 4;
obj_shell.consolePaddingH = 6;
obj_shell.consolePaddingV = 4;
obj_shell.autocompletePadding = 2;
obj_shell.promptColor = make_color_rgb(29, 29, 196);
obj_shell.prompt = "$";
obj_shell.width = 1024;
obj_shell.height = 600;


global.recv_buf = buffer_create(4194304, buffer_fixed, 1);
global.recv_size = 0;