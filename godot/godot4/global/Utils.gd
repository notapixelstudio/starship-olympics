extends Node
const E = 2.71828

###############################
##### FILE SYSTEM UTILS #######
###############################


func dir_contents(path:String, starts_with:String = "", extension:String = ".tscn"):
	"""
	@param path:String given the path 
	@return a list of filename
	"""
	var list_files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(extension):
					if not starts_with or file_name.find(starts_with) == 0: 
						list_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list_files

func mod(a,b):
	"""
	Modulus: Maybe fposmod and fmod will do the trick by its own
	"""
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret

func get_resources(base_path: String) -> Dictionary:
	var ret := {}
	var resources = dir_contents(base_path, "", ".tres")
	for filename in resources:
		var this_res = load(base_path.path_join(filename))
		var res_id = this_res.get_id()
		ret[res_id] = this_res
	return ret

func end_execution():
	# trigger quit
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	
func _notification(what):
	# actual quitting
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Thanks for playing")
		Events.emit_signal('execution_ended')
		await get_tree().create_timer(1).timeout
		print("Closing everything")
		get_tree().quit() # default behavior

func sigmoid(x, width):
	return 1-1/(1+pow(E, -10*(x/width-0.5)))

func is_action_strong(action:String) -> bool:
	return Input.get_action_strength(action) > 0.5

func are_controls_at_rest(controls:String) -> bool:
	return Input.get_action_strength(controls+"_down") < 0.1 and Input.get_action_strength(controls+"_up") < 0.1 and Input.get_action_strength(controls+"_left") < 0.1 and Input.get_action_strength(controls+"_right") < 0.1

func inject_input_action(pressed: bool, strength: float, action: String) -> void:
	var s := absf(strength)
	var active := pressed and s > 0.0
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = active
	ev.strength = s
	Input.parse_input_event(ev)
	if active:
		Input.action_press(action, s)
	else:
		Input.action_release(action)

func inject_input_fire(cmd: String, action: String) -> void:
	var pressed := cmd == "1" or cmd == "2"
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	ev.strength = 1.0 if pressed else 0.0
	Input.parse_input_event(ev)
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)

signal touch_fire(controls: String, pressed: bool)

func is_mobile_touch_device() -> bool:
	return DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")

func notify_touch_fire(controls: String, pressed: bool) -> void:
	touch_fire.emit(controls, pressed)
	if pressed and _press_any_callback.is_valid() and not is_mobile_touch_device():
		_press_any_callback.call()

func notify_screen_touch() -> void:
	if _press_any_callback.is_valid():
		_press_any_callback.call()

var _press_any_callback := Callable()
var _character_select_callback := Callable()
var _mouse_was_down := false

func register_press_any(callback: Callable) -> void:
	_press_any_callback = callback
	_mouse_was_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_fire_edge_state.clear()
	_update_input_processing()

func unregister_press_any() -> void:
	_press_any_callback = Callable()
	_fire_edge_state.clear()
	_update_input_processing()

func register_character_select(callback: Callable) -> void:
	_character_select_callback = callback
	_update_input_processing()

func unregister_character_select() -> void:
	_character_select_callback = Callable()
	_update_input_processing()

func _update_input_processing() -> void:
	var listening := _press_any_callback.is_valid() or _character_select_callback.is_valid()
	set_process_input(listening)
	set_process_unhandled_input(_press_any_callback.is_valid())
	set_process(_press_any_callback.is_valid())

func _input(event: InputEvent) -> void:
	if _press_any_callback.is_valid() and _is_press_any_event(event):
		_press_any_callback.call()
		return
	if _character_select_callback.is_valid():
		_character_select_callback.call(event)

func _unhandled_input(event: InputEvent) -> void:
	if _press_any_callback.is_valid() and _is_press_any_event(event):
		_press_any_callback.call()

func _process(_delta: float) -> void:
	if not _press_any_callback.is_valid() or is_mobile_touch_device():
		return

	var mouse_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if mouse_down and not _mouse_was_down:
		_press_any_callback.call()
	_mouse_was_down = mouse_down

	for action in InputMap.get_actions():
		if not (action.ends_with("_fire") or action.begins_with("ui_")):
			continue
		var down := Input.is_action_pressed(action)
		if down and not _fire_edge_state.get(action, false):
			_press_any_callback.call()
		_fire_edge_state[action] = down

var _fire_edge_state := {}

func _is_press_any_event(event: InputEvent) -> bool:
	if is_mobile_touch_device():
		return event is InputEventScreenTouch and event.pressed
	if event is InputEventScreenTouch:
		return event.pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		return event.pressed
	if not event.is_pressed():
		return false
	if event is InputEventJoypadButton or event is InputEventKey:
		return true

	for action in InputMap.get_actions():
		if not (action.ends_with("_fire") or action.begins_with("ui_")):
			continue
		if event.is_action_pressed(action):
			return true

	return false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("hard_quit"):
		Utils.end_execution()
	elif event.is_action_pressed("fullscreen"):
		Settings.toggle_fullscreen()

func read_file_by_line(path: String) -> Array:
	# When we load a file, we must check that it exists before we try to open it or it'll crash the game
	if not FileAccess.file_exists(path):
		print("The file does not exist.")
		return []
	var file = FileAccess.open(path, FileAccess.READ)
	print("We are going to load from this JSON: ", file.get_path_absolute())
	# parse file data - convert the JSON back to a dictionary
	var data = []
	var num_lines = 1
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		var content = file.get_line()
		if content == "":
			continue
		var test_json_conv = JSON.new()
		test_json_conv.parse(content)
		data.append(test_json_conv.get_data())
		num_lines += 1
	print("Read {lines}".format({"lines":num_lines}))
	file.close()
	return data
