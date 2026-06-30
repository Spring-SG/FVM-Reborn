// feather disable all
// feather ignore all
if (isOpen) {
	draw_set_font(consoleFont);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	// pre-calculate one "em" of width & height
	var emWidth = string_width("M");
	var emHeight = string_height("M");
	
	if (!surface_exists(shellSurface)) {
		shellSurface = surface_create(display_get_gui_width(), display_get_gui_height());
		self._recalculate_shell_properties();
	} else if (surface_get_width(shellSurface) != display_get_gui_width() || surface_get_height(shellSurface) != display_get_gui_height()) {
		surface_resize(shellSurface, display_get_gui_width(), display_get_gui_height());
	}
	
	var promptXOffset = consolePaddingH + string_width(prompt) + anchorMargin;
	
	outputHeight = 0;
	for (var i = 0; i < array_length(output); i++) {
		outputHeight += string_height_ext(output[i], -1, visibleWidth - promptXOffset);
	}
	if (!surface_exists(scrollSurface)) {
		scrollSurface = surface_create(display_get_gui_width(), visibleHeight);
	} else if (surface_get_width(scrollSurface) != display_get_gui_width() || 
			   surface_get_height(scrollSurface) != visibleHeight) {
		surface_resize(scrollSurface, display_get_gui_width(), visibleHeight);
	}
	
	// Updating this here removes jitter as the scroll bar draws one frame in the old position
	// and then jumps to the bottom. This fixes that
	var newMaxScroll =  max(0, outputHeight - visibleHeight + emHeight);
	if (maxScrollPosition != newMaxScroll) {
		maxScrollPosition = newMaxScroll;
		if (scrollSmoothness == 0) { scrollPosition = maxScrollPosition; }
		targetScrollPosition = maxScrollPosition;
		commandSubmitted = false;
	}
	
	surface_set_target(scrollSurface);
		draw_clear_alpha(c_black, 0.0);
		var yOffset = -scrollPosition;
		
		// Add some blank space if our output is too short so things appear to come from 
		// the bottom of the panel
		if (outputHeight < visibleHeight - emHeight) {
			yOffset += visibleHeight - outputHeight - emHeight;
		}
		
		
		// Draw output history
		for (var i = 0; i < array_length(output); i++) {
			var outputStr = output[i];
			if (string_char_at(outputStr, 1) == ">") {
				draw_set_color(fontColorSecondary);
				draw_text(shellOriginX + consolePaddingH, yOffset, prompt);
				draw_text_ext(shellOriginX + promptXOffset, yOffset, string_delete(outputStr, 1, 1), -1, visibleWidth - promptXOffset);
			} else {
				draw_set_color(fontColor);
				draw_text_ext(shellOriginX + promptXOffset, yOffset, outputStr, -1, visibleWidth - promptXOffset);
			}
			yOffset += string_height_ext(outputStr, -1, visibleWidth - promptXOffset);
		}
		
		// Draw our command prompt
		draw_set_color(promptColor);
		draw_text(shellOriginX + consolePaddingH, yOffset, prompt);
	
		// Draw whatever text has been entered so far
		draw_set_color(fontColor);
		draw_text(shellOriginX + promptXOffset, yOffset, consoleString);
		
		// Draw text cursor
		var cursorPosX = shellOriginX + promptXOffset + string_width(string_copy(consoleString + " ", 1, cursorPos - 1));
		if (insertMode) {
			if (delayFrames > 1 || current_time % 1000 < 600) {
				draw_line_width(cursorPosX, yOffset, cursorPosX, yOffset + emHeight, 1);
			} else if (keyboard_check(vk_anykey)) {
				draw_line_width(cursorPosX, yOffset, cursorPosX, yOffset + emHeight, 1);
			}
		} else {
			draw_line_width(cursorPosX + (emWidth / 2) - 1, yOffset, cursorPosX + (emWidth / 2) - 1, yOffset + emHeight, emWidth);
			draw_set_color(promptColor);
			draw_text(cursorPosX, yOffset, string_copy(consoleString, cursorPos, 1));
		}
		
		// Draw current suggestion & argument hints
		if (array_length(inputArray) > 0) {
			var ff = (array_length(filteredSuggestions) > 0 && array_length(inputArray) == 1) ? filteredSuggestions[suggestionIndex] : inputArray[0];
			var data = functionData[$ ff];
			var spaceCount = array_length(inputArray) - 1;
			
			var suggestion = spaceCount == 0 ? ff : "";
			if (!is_undefined(activeMouseArgType) && spaceCount > 0) {
				// If we have active mouse argument data, show that as the suggestion
				// unless the user has started typing in an argument themselves
				if ((inputArray[array_length(inputArray) - 1]) == "") {
					suggestion = string(activeMouseArgValue);
					if (mouse_check_button_pressed(mb_left)) {
						self._confirm_current_mouse_argument_data();
						self._update_filtered_suggestions();
					}
				}
			} 
			if (data != undefined) {
				var args = "";
				if (array_length(filteredSuggestions) > 0 && spaceCount > 0) {
					if (array_length(inputArray) > spaceCount) {
						args += string_copy(filteredSuggestions[suggestionIndex], string_length(inputArray[array_length(inputArray) - 1]) + 1, string_length(filteredSuggestions[suggestionIndex]));
					} else {
						args += filteredSuggestions[suggestionIndex];
					}
				}
				for (var i = spaceCount; i < array_length(data[$ "arguments"]); i++) {
					args += " ";
					args += data.arguments[i];
					
				}
				suggestion += args;
				if (spaceCount == 0) {
					suggestion = string_copy(suggestion, string_length(consoleString) + 1, string_length(suggestion) - string_length(consoleString));
				}
			} else {
				suggestion = string_copy(ff, string_length(consoleString) + 1, string_length(ff) - string_length(consoleString));
			}

			draw_set_color(fontColorSecondary);
			draw_text(shellOriginX + promptXOffset + string_width(consoleString), yOffset, suggestion);
		}		
	surface_reset_target();
	
	surface_set_target(shellSurface);
		// Draw shell background
		draw_clear_alpha(c_black, 0.0);
		if (consoleBackground != noone) {
			draw_sprite_stretched(consoleBackground, 0, shellOriginX, shellOriginY, width, height);
		} else {
			draw_set_alpha(consoleAlpha);
			draw_set_color(consoleColor);
			draw_roundrect_ext(shellOriginX, shellOriginY, shellOriginX + width, shellOriginY + height, cornerRadius, cornerRadius, false);
		}
		
		// Draw the scroll surface
		draw_surface(scrollSurface, 0, shellOriginY + 1 + consolePaddingV);
		
		// Draw scrollbar
		if (outputHeight > visibleHeight - emHeight) {
			var x1 = shellOriginX + width - consolePaddingH - scrollbarWidth;
			var y1 = shellOriginY + consolePaddingV + 1;
			var x2 = x1 + scrollbarWidth;
			var y2 = shellOriginY + height - consolePaddingV;
			
			draw_set_color(fontColorSecondary);
			draw_rectangle(x1, y1, x2, y2, false);
			
			var containerHeight = y2 - y1;
			
			var scrollProgress = scrollPosition / (outputHeight - visibleHeight + emHeight);
			var scrollbarHeight = (visibleHeight / (outputHeight + emHeight)) * containerHeight;
			var scrollbarPosition = (containerHeight - scrollbarHeight) * scrollProgress;
			
			y1 = y1 + scrollbarPosition;
			y2 = y1 + scrollbarHeight;
			
			draw_set_color(fontColor);
			draw_rectangle(x1, y1, x2, y2, false);
		}
		
		// Draw autocomplete box
		if (array_length(filteredSuggestions) > 0) {
			if (enableAutocomplete && autocompleteMaxLines > 0) {
				isAutocompleteOpen = true;
				var suggestionsAmount = min(autocompleteMaxLines, array_length(filteredSuggestions));
				
				var stringParts = self._input_string_split(consoleString);
				var suggestXOffset = 0;
				for (var i = 0; i < array_length(stringParts) - 1; i++) {
					suggestXOffset += string_width(stringParts[i]) + emWidth;
				}
				
				var x1 = shellOriginX + promptXOffset + suggestXOffset - autocompletePadding;
				var y1 = shellOriginY + height - (emHeight) - (suggestionsAmount * emHeight) - (autocompletePadding * 2) - consolePaddingV;
				var x2 = x1 + autocompleteMaxWidth + (autocompletePadding * 2) + ((suggestionsAmount < array_length(filteredSuggestions)) ? scrollbarWidth : 0);
				var y2 = y1 + (suggestionsAmount * emHeight) + (autocompletePadding * 2);
				
				if (screenAnchorPointV == "top") {
					y1 = shellOriginY + height - consolePaddingV;
					y2 = y1 + (suggestionsAmount * emHeight);
				}
				
				// Store x1 & y1 for later use with scrolling mouse detection
				autocompleteOriginX = x1;
				autocompleteOriginY = y1;
				
				// Draw autocomplete background
				if (suggestionsBackground != noone) {
					draw_sprite_stretched(suggestionsBackground, 0, x1, y1, x2 - x1, y2 - y1);
				} else {
					draw_set_color(autocompleteBackgroundColor);
					draw_rectangle(x1, y1, x2, y2, false);
					draw_set_color(fontColorSecondary);
					draw_rectangle(x1, y1, x2, y2, true);
				}
				
				// Draw autocomplete scrollbar
				if (suggestionsAmount < array_length(filteredSuggestions)) {
					draw_rectangle(x2 - (scrollbarWidth / 2), y1, x2, y2, false);
					var scrollbarTotalHeight = y2 - y1;
					var scrollbarHeight = (suggestionsAmount / array_length(filteredSuggestions)) * scrollbarTotalHeight;
					var scrollbarProgress = (array_length(filteredSuggestions) - autocompleteScrollPosition) / array_length(filteredSuggestions);
					var yScroll1 = y1 + (scrollbarTotalHeight * (1 - scrollbarProgress)) + 1;
					var yScroll2 = yScroll1 + scrollbarHeight - 1;
				
					draw_set_color(fontColor);
					draw_rectangle(x2 - (scrollbarWidth / 2), yScroll1, x2 + 1, yScroll2, false);
				}
				
				// Draw autocomplete suggestions
				draw_set_color(fontColor);
				for (var i = 0; i < array_length(filteredSuggestions); i++) {
					if (i < suggestionsAmount) {
						// Enable mouse detection
						var y1Col = y1 + (i * emHeight);
						var y2Col = y1 + (i * emHeight) + emHeight - 1 + autocompletePadding;
						if (point_in_rectangle(device_mouse_x_to_gui(0) - 1, device_mouse_y_to_gui(0) - 1, x1, y1Col, x2, y2Col)) {
							if (device_mouse_x_to_gui(0) != mousePreviousX || device_mouse_y_to_gui(0) != mousePreviousY) {
								suggestionIndex = i + autocompleteScrollPosition;
								mousePreviousX = device_mouse_x_to_gui(0);
								mousePreviousY = device_mouse_y_to_gui(0);
							}
							if (mouse_check_button_pressed(mb_left)) {
								if (suggestionIndex == i + autocompleteScrollPosition) {
									self._confirm_current_suggestion();
									self._update_filtered_suggestions();
									break;
								} else {
									suggestionIndex = i + autocompleteScrollPosition;
								}
							}
						}
						
						if ((i + autocompleteScrollPosition) == suggestionIndex) {
							draw_set_color(promptColor);
						} else {
							draw_set_color(fontColorSecondary);
						}
						
						draw_text(x1 + autocompletePadding, y1 + (i * emHeight) + autocompletePadding, filteredSuggestions[i + autocompleteScrollPosition]);
					}
				}
			}
		} else {
			isAutocompleteOpen = false;
			autocompleteScrollPosition = 0;
		}
		
		draw_set_color(c_white);
		draw_set_alpha(1);
		draw_set_font(-1);
	surface_reset_target();
	
	draw_surface(shellSurface, 0, 0);
}
