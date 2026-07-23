// feather disable all
// feather ignore all
/// @description Initialize Native Scripts

/*
 * Display help output.
 */
variable_global_set("sh_help", function(args) {
	if (array_length(args) > 1) {
		// Display specific help for an individual function
		var helpFunction = args[1];
		if (array_contains(allFunctions, helpFunction)) {
			if (variable_struct_exists(functionData, helpFunction)) {
				var metadata = functionData[$ helpFunction];
				var output = helpFunction;
				if (variable_struct_exists(metadata, "arguments")) {
					for (var i = 0; i < array_length(metadata.arguments); i++) {
						output += " " + metadata.arguments[i];
					}
				}
				if (variable_struct_exists(metadata, "description")) {
					output += " - " + metadata.description;
				}
				output += "\n";
				if (variable_struct_exists(metadata, "argumentDescriptions")) {
					for (var i = 0; i < array_length(metadata.argumentDescriptions); i++) {
						var argName = metadata.arguments[i];
						var desc = metadata.argumentDescriptions[i];
						output += argName +  " - " + desc + "\n";
					}
				}
				return output;
			} else {
				return helpFunction + "\nNo additional information present";
			}
		} else {
			return "No command [" + helpFunction + "] exists.";
		}
	} else {
		// Show a listing of all available functions
		var output = "List of available commands:\n";
		var hiddenCount = 0;
		for (var i = 0; i < array_length(availableFunctions); i++) {
			var functionName = availableFunctions[i];
			// #32 : don't display hidden functions in the function list
			var hidden = false;
			var metadata = functionData[$ functionName];
			if (!is_undefined(metadata)) {
				if (variable_struct_exists(metadata, "hidden")) {
					hidden = metadata.hidden;
					hiddenCount += 1;
				}
			}
			if (!hidden) {
				var terminator = "";
				if ((i - hiddenCount) % 2 == 0) {
					var paddingWidth = (width/2) - (anchorMargin + string_width(functionName));
					var spaceCount = paddingWidth/string_width(" ");
					repeat (spaceCount) {
						terminator += " ";
					}
				} else {
					terminator = "\n";
				}
				output += functionName + terminator;
			}
		}
		return output;
	}
});
variable_global_set("meta_help", function() {
	return {
		arguments: ["<command name>"],
		suggestions: [ availableFunctions ],
		description: "display available commands",
		argumentDescriptions: [
			"optional name of a command to display detailed help information for."
		]
	}
});

/*
 * Clear the console
 */
variable_global_set("sh_clear", function(args) {
	if (array_length(args) > 1 && args[1] == "all") {
		array_resize(output, 0);
		array_resize(history, 0);
		return "";
	} else {
		array_push(output, ">" + consoleString);
		draw_set_font(consoleFont);
		var _newLinesCount = floor(visibleHeight / string_height(prompt));
		repeat(_newLinesCount) {
			array_push(output, "\n");
		}
		return "";
	}
});
variable_global_set("meta_clear", function() {
	return {
		arguments: ["<all>"],
		suggestions: [
			["all"]
		],
		description: "clear the console window",
		argumentDescriptions: [
			"If provided, previous console output and command history will be deleted."
		]
	}
});

/*
 * Set the console's width
 */
variable_global_set("sh_shell_set_width", function(args) {
	if (array_length(args) > 1) {
		if (string_digits(args[1]) != "") {
			width = real(string_digits(args[1]));
		} else {
			return "Invalid argument: " + args[1];
		}
	} else {
		return "No argument provided.";
	}
});
variable_global_set("meta_shell_set_width", function() {
	return {
		description: "set the width of the console window",
		arguments: ["width"],
		argumentDescriptions: [
			"The desired width of the console, in pixels."
		]
	}
});

/*
 * Set the console's height
 */
variable_global_set("sh_shell_set_height", function(args) {
	if (array_length(args) > 1) {
		if (string_digits(args[1]) != "") {
			height = real(string_digits(args[1]));
		} else {
			return "Invalid argument: " + args[1];
		}
	} else {
		return "No argument provided.";
	}
});
variable_global_set("meta_shell_set_height", function() {
	return {
		description: "set the height of the console window",
		arguments: ["height"],
		argumentDescriptions: [
			"The desired height of the console, in pixels."
		]
	}
});

/*
 * Set the console's vertical anchor
 */
variable_global_set("sh_shell_set_anchor_v", function(args) {
	if (array_length(args) > 1) {
		var newAnchor = args[1];
		if (newAnchor == "top" || newAnchor == "middle" || newAnchor == "bottom") {
			screenAnchorPointV = newAnchor;
		} else {
			return "Invalid anchor point.\nPossible values: [top, middle, bottom]";
		}
	} else {
		return "No argument provided.";
	}
});
variable_global_set("meta_shell_set_anchor_v", function() {
	return {
		description: "set the vertical anchor point of the console window",
		arguments: ["anchor"],
		suggestions: [
			["top", "middle", "bottom"]
		],
		argumentDescriptions: [
			"The desired vertical anchor point."
		]
	}
});

/*
 * Set the console's horizontal anchor
 */
variable_global_set("sh_shell_set_anchor_h", function(args) {
	if (array_length(args) > 1) {
		var newAnchor = args[1];
		if (newAnchor == "left" || newAnchor == "center" || newAnchor == "right") {
			screenAnchorPointH = newAnchor;
		} else {
			return "Invalid anchor point.\nPossible values: [left, center, right]";
		}
	} else {
		return "No argument provided.";
	}
});
variable_global_set("meta_shell_set_anchor_h", function() {
	return {
		description: "set the horizontal anchor point of the console window",
		arguments: ["anchor"],
		suggestions: [
			["left", "center", "right"]
		],
		argumentDescriptions: [
			"The desired horizontal anchor point."
		]
	}
});