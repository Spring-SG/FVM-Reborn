


// ── 精灵异步加载：每帧处理3个 ──
var _loader_q = global._loader_sprite_queue;
for(var _i=0;_i<3;_i++){
if (_loader_q != undefined && ds_list_size(_loader_q) > 0) {
    var _queue = ds_list_find_value(_loader_q, 0);
    if (!_queue.done) {
        sprite_manager_async_process_one(_queue);
    }
    if (_queue.done) {
        ds_list_delete(_loader_q, 0);
    }
}
}

var q = global._destroy_queue;
var i = 0;
while (i < ds_list_size(q)) {
    var entry = ds_list_find_value(q, i);
    entry.timer--;
    if (entry.timer <= 0 || !instance_exists(entry.inst)) {
        if (instance_exists(entry.inst)) {
			global.network.client_able = true;
            instance_destroy(entry.inst);
			global.network.client_able = false;
        }
        ds_list_delete(q, i);
    } else {
        i++;
    }
}
  

// feather disable all
// feather ignore all
if (saveHistory) {
	if (!loadedSavedHistory) {
		self._load_history();
		loadedSavedHistory = true;
	} else if (!loadedHistoryScrolled && isOpen) {
		targetScrollPosition = maxScrollPosition;
		scrollPosition = maxScrollPosition;
		loadedHistoryScrolled = true;
	}
}

if (!isOpen) {
	if (self._key_combo_pressed(openModifiers, openKey)||keyboard_check_pressed(vk_f1)) {
		self.open();
	}
} else {
	var prevConsoleString = consoleString;
	
	if (metaDeleted && keyboard_check_released(vk_backspace)) {
		metaDeleted = false;
	}
	if (metaMovedLeft && keyboard_check_released(vk_left)) {
		metaMovedLeft = false;
	}
	if (metaMovedRight && keyboard_check_released(vk_right)) {
		metaMovedRight = false;
	}
	
	if (keyboard_check_pressed(vk_escape)||self._key_combo_pressed(openModifiers, openKey)||keyboard_check_pressed(vk_f1)) {
		if (isAutocompleteOpen) {
			self._close_autocomplete();
		} else {
			self.close()
		}
	} else if (self._key_combo_pressed([metaKey], ord("A")) || keyboard_check_pressed(vk_home)) {
		// Jump to beginning of line
		cursorPos = 1;
		targetScrollPosition = maxScrollPosition;
	} else if (self._key_combo_pressed([metaKey], ord("E")) || keyboard_check_pressed(vk_end)) {
		// Jump to end of line
		cursorPos = string_length(consoleString) + 1;
		targetScrollPosition = maxScrollPosition;
	} else if (self._key_combo_pressed([metaKey], ord("K"))) {
		// bash-style "kill" (aka delete all characters following cursor)
		var leftSide = string_copy(consoleString, 0, cursorPos - 1);
		var rightSide = string_copy(consoleString, cursorPos, string_length(consoleString) - cursorPos + 1);
		killedString = rightSide;
		consoleString = leftSide;
		cursorPos = string_length(consoleString) + 1;
		targetScrollPosition = maxScrollPosition;
	} else if (self._key_combo_pressed([metaKey], ord("Y"))) {
		// bash-style "yank" (aka append the "killed" string at the prompt)
		consoleString += killedString;
		killedString = "";
		cursorPos = string_length(consoleString) + 1;
		targetScrollPosition = maxScrollPosition;
	} else if (self._key_combo_pressed([metaKey], ord("C"))) {
		// GNU-style "sigint" (aka abort the current message)
		array_push(output, ">" + consoleString + "^C");
		consoleString = "";
		cursorPos = 1;
		targetScrollPosition = maxScrollPosition;
	} else if (self._key_combo_pressed([metaKey], vk_backspace) || (metaKey == vk_control && ord(keyboard_string) == 127)) {
		// delete characters from the cursor position to the preceding space or start of the line
		var precedingSpaceIndex = 1;
		// don't want to check for space at or before the cursor position, so start 2 back
		for (var i = cursorPos - 2; i > 1; i--) {
			if (string_char_at(consoleString, i) == " ") {
				precedingSpaceIndex = i;
				break;
			}
		}
		consoleString = string_delete(consoleString, precedingSpaceIndex, cursorPos - precedingSpaceIndex);
		cursorPos = precedingSpaceIndex;
		targetScrollPosition = maxScrollPosition;
		keyboard_string = "";
		metaDeleted = true;
	} else if (self._key_combo_pressed([metaKey], vk_left)) {
		// jump left to the preceding word
		var precedingSpaceIndex = 1;
		// don't want to check for space at or before the cursor position, so start 2 back
		for (var i = cursorPos - 2; i > 1; i--) {
			if (string_char_at(consoleString, i) == " ") {
				precedingSpaceIndex = i;
				break;
			}
		}
		cursorPos = precedingSpaceIndex;
		targetScrollPosition = maxScrollPosition;
		metaMovedLeft = true;
	} else if (self._key_combo_pressed([metaKey], vk_right)) {
		var nextSpaceIndex = string_length(consoleString) + 1;
		// jump right to the following word
		for (var i = cursorPos + 2; i <= string_length(consoleString) + 1; i++) {
			if (string_char_at(consoleString, i) == " ") {
				nextSpaceIndex = i;
				break;
			}
		}
		cursorPos = nextSpaceIndex;
		targetScrollPosition = maxScrollPosition;
		metaMovedRight = true;
	} else if (self._keyboard_check_delay(vk_backspace)) {
		if (!metaDeleted) {
			consoleString = string_delete(consoleString, cursorPos - 1, 1);
			cursorPos = max(1, cursorPos - 1);
			targetScrollPosition = maxScrollPosition;
		}
	} else if (self._keyboard_check_delay(vk_delete)) {
		consoleString = string_delete(consoleString, cursorPos, 1);
		targetScrollPosition = maxScrollPosition;
	} else if (self._keyboard_check_delay(vk_left)) { 
		if (!metaMovedLeft) {
			cursorPos = max(1, cursorPos - 1);
			targetScrollPosition = maxScrollPosition;
		}
	} else if (self._keyboard_check_delay(vk_right)) {
		if (!metaMovedRight) {
			if (cursorPos == string_length(consoleString) + 1 &&
				array_length(filteredSuggestions) != 0) {
				var suggestion = filteredSuggestions[suggestionIndex];
				var consoleWords = self._input_string_split(consoleString);
				var currentWordLength = string_length(consoleWords[array_length(consoleWords) - 1]);
				consoleString += string_copy(suggestion, currentWordLength + 1, string_length(suggestion) - currentWordLength);
				cursorPos = string_length(consoleString) + 1;
			} else {
				cursorPos = min(string_length(consoleString) + 1, cursorPos + 1);
			}
			targetScrollPosition = maxScrollPosition;
		}
	} else if (self._key_combo_pressed(historyUpModifiers, historyUpKey) && !isAutocompleteOpen) {
		if (historyPos == array_length(history)) {
			savedConsoleString = consoleString;
		}
		historyPos = max(0, historyPos - 1);
		if (array_length(history) != 0) {
			consoleString = array_get(history, historyPos);
			cursorPos = string_length(consoleString) + 1;
		}
		targetScrollPosition = maxScrollPosition;
	} else if (self._key_combo_pressed(historyDownModifiers, historyDownKey) && !isAutocompleteOpen) {
		if (historyPos < array_length(history)) {
			historyPos = min(array_length(history), historyPos + 1);
			if (historyPos == array_length(history)) {
				consoleString = savedConsoleString;
			} else {
				consoleString = array_get(history, historyPos);
			}
			cursorPos = string_length(consoleString) + 1;
		}
		targetScrollPosition = maxScrollPosition;
	} else if (keyboard_check_pressed(vk_enter)) {
		if (string_trim(consoleString) != "") {
			if (isAutocompleteOpen) {
				self._confirm_current_suggestion();
			} else {
				var args = self._input_string_split(consoleString);
				if (array_length(args) > 0) {
					var metadata = functionData[$ args[0]];
					if (!is_undefined(metadata)) {
						var deferred = false;
						if (variable_struct_exists(metadata, "deferred")) {
							deferred = metadata.deferred;
						}
						if (deferred) {
							ds_queue_enqueue(deferredQueue, args);
							array_push(history, consoleString);
							array_push(output, ">" + consoleString);
							array_push(output, "Execution deferred until shell is closed.");
							self._update_positions();
						} else {
							_execute_script(args);
						}
					} else {
						_execute_script(args);
					}
				} else {
					array_push(output, ">");
					consoleString = "";
					savedConsoleString = "";
					cursorPos = 1;
				}
			}
		} else {
			array_push(output, ">");
			consoleString = "";
			savedConsoleString = "";
			cursorPos = 1;
		}
		commandSubmitted = true;
	} else if (self._key_combo_pressed(cycleSuggestionsModifiers, cycleSuggestionsKey) || keyboard_check_pressed(vk_down)) {
		if (array_length(filteredSuggestions) != 0) {
			// Auto-complete up to the common prefix of our suggestions
			var uncompleted = consoleString;
			consoleString = self._find_common_prefix();
			cursorPos = string_length(consoleString) + 1;
			// If we're already autocompleted as far as we can go, rotate through suggestions
			if (uncompleted == consoleString) {
				suggestionIndex = (suggestionIndex + 1) % array_length(filteredSuggestions);
				if (isAutocompleteOpen) {
					self._calculate_scroll_from_suggestion_index()
				}
			}
		}
	} else if (self._key_combo_pressed(cycleSuggestionsReverseModifiers, cycleSuggestionsReverseKey) || keyboard_check_pressed(vk_up)) {
		if (array_length(filteredSuggestions) != 0) {
			suggestionIndex = (suggestionIndex + array_length(filteredSuggestions) - 1) % array_length(filteredSuggestions);
			if (isAutocompleteOpen) {
				self._calculate_scroll_from_suggestion_index()
			}
		}
	} else if (keyboard_check_pressed(vk_insert)) {
		insertMode = !insertMode;
	} else if (keyboard_string != "") {
		var t = keyboard_string;
		if (!insertMode) { consoleString = string_delete(consoleString, cursorPos, string_length(t)); }
		consoleString = string_insert(t, consoleString, cursorPos);
		cursorPos += string_length(t);
		keyboard_string = "";
		targetScrollPosition = maxScrollPosition;
	}
	
	// Handle scrolling
	if (isAutocompleteOpen) {
		var x1 = autocompleteOriginX;
		var y1 = autocompleteOriginY;
		var x2 = x1 + autocompleteMaxWidth + font_get_size(consoleFont) + (autocompletePadding * 2) - scrollbarWidth;
		var y2 = y1 + (string_height(prompt) * min(array_length(filteredSuggestions), autocompleteMaxLines)) + autocompletePadding;
		if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), x1, y1, x2, y2)) {
			if (mouse_wheel_down()) {
				autocompleteScrollPosition++;
				autocompleteScrollPosition = clamp(array_length(filteredSuggestions) - autocompleteMaxLines, 0, autocompleteScrollPosition);
			}
			if (mouse_wheel_up()) {
				autocompleteScrollPosition--;
				autocompleteScrollPosition = max(autocompleteScrollPosition, 0);
			}
		} else if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), shellOriginX, shellOriginY, shellOriginX + width, shellOriginY + height)) {
			if (mouse_wheel_down()) {
				targetScrollPosition = targetScrollPosition + scrollSpeed;
			}
			if (mouse_wheel_up()) {
				targetScrollPosition = targetScrollPosition - scrollSpeed;
			}
		}
	} else {
		if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), shellOriginX, shellOriginY, shellOriginX + width, shellOriginY + height)) {
			if (mouse_wheel_down()) {
				targetScrollPosition = targetScrollPosition + scrollSpeed;
			}
			if (mouse_wheel_up()) {
				targetScrollPosition = targetScrollPosition - scrollSpeed;
			}
		}
	}
	
	// Updating scrolling
	var lerpValue = (scrollSmoothness == 0) ? 1 : self._remap(scrollSmoothness, 1, 0, 0.08, 0.4);
	scrollPosition = lerp(scrollPosition, targetScrollPosition, lerpValue);
	scrollPosition = clamp(scrollPosition, 0, maxScrollPosition)
	if (scrollPosition == 0 || scrollPosition == maxScrollPosition) {
		targetScrollPosition = clamp(targetScrollPosition, 0, maxScrollPosition);
	}
	
	if (consoleString != prevConsoleString) {
		// If the text at the prompt has changed, update the list of possible
		// autocomplete suggestions
		self._update_filtered_suggestions();
		autocompleteScrollPosition = 0;
	}
	
	// Recalculate shell properties if certain variables have changed
	if (self._shell_properties_hash() != shellPropertiesHash) {
		self._recalculate_shell_properties();
	}
}

// Handle mouse argument data
if (!is_undefined(activeMouseArgType)) {
	if (activeMouseArgType == mouseArgumentType.worldX) {
		activeMouseArgValue = mouse_x;
	} else if (activeMouseArgType == mouseArgumentType.worldY) {
		activeMouseArgValue = mouse_y;
	} else if (activeMouseArgType == mouseArgumentType.guiX) {
		activeMouseArgValue = device_mouse_x_to_gui(0);
	} else if (activeMouseArgType == mouseArgumentType.guiY) {
		activeMouseArgValue = device_mouse_y_to_gui(0);
	} else if (activeMouseArgType == mouseArgumentType.instanceId) {
		var instAtCursor = instance_position(mouse_x, mouse_y, all);
		if (instAtCursor != noone) {
			activeMouseArgValue = instAtCursor;
		} else {
			activeMouseArgValue = "";
		}
	} else if (activeMouseArgType == mouseArgumentType.objectId) {
		var instAtCursor = instance_position(mouse_x, mouse_y, all);
		if (instAtCursor != noone) {
			activeMouseArgValue = instAtCursor.object_index;
		} else {
			activeMouseArgValue = "";
		}
	}
}

