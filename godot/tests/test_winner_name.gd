extends SceneTree
# Run: godot --headless --path godot --script res://tests/test_winner_name.gd

var saved: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func send(event: InputEvent) -> void:
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	var release := event.duplicate()
	release.pressed = false
	Input.parse_input_event(release)
	Input.flush_buffered_events()

func key(code: Key, unicode_value: int = 0) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.unicode = unicode_value
	send(event)

func button(code: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = code
	event.device = 2
	send(event)

func run() -> void:
	var scene = load("res://special_scenes/combat_UI/gameover/WinnerBanner.tscn")
	root.get_node("Events").new_entry_hall_of_fame.connect(func(champion): saved.append(champion.nickname))
	for use_start in [false, true]:
		var banner = scene.instantiate()
		root.add_child(banner)
		var wheel = banner.get_node("%ArcadeWheel")
		var input = banner.get_node("%InsertName")
		assert(wheel.name_input == input)
		button(JOY_BUTTON_A)
		assert(input.text.is_empty()) # Hidden banners ignore input.
		banner.insert_name()
		await process_frame
		await process_frame
		var bounds: Rect2 = banner.get_node("%Container").get_global_rect()
		assert(bounds.size.y == 150)
		assert(bounds.encloses(wheel.get_global_rect()))
		assert(bounds.encloses(input.get_global_rect()))
		assert(input.global_position.y - wheel.get_global_rect().end.y == 4)
		key(KEY_A, 97)
		key(KEY_B, 98)
		assert(input.text == "ab") # Printable menu bindings must still type.
		await process_frame
		assert(wheel.cursor == 2)
		key(KEY_LEFT)
		key(KEY_DOWN)
		assert(input.text == "aC") # Wheel edits a keyboard-entered letter.
		button(JOY_BUTTON_A)
		button(JOY_BUTTON_A)
		assert(input.text == "aCA")
		key(KEY_D, 100)
		assert(input.text == "aCAd") # Keyboard continues after wheel input.
		key(KEY_BACKSPACE)
		button(JOY_BUTTON_B)
		assert(input.text == "aC")
		button(JOY_BUTTON_Y)
		button(JOY_BUTTON_B) # Empty deletion is safe.
		for i in range(20):
			key(KEY_RIGHT)
		assert(input.text == "A".repeat(20))
		await process_frame
		assert(bounds.encloses(input.get_global_rect()))
		input.text = "é-"
		input.caret_column = 1
		key(KEY_DOWN) # Unsupported characters remain editable without invalid indexes.
		assert(input.text == "éB")
		key(KEY_RIGHT)
		if use_start:
			button(JOY_BUTTON_START)
		else:
			key(KEY_ENTER)
		assert(saved.back() == "ÉB")
		banner._on_InsertName_name_inserted("LATE")
		assert(not wheel.is_processing_input() and not input.is_processing_input())
		banner.free()
	assert(saved.size() == 2)
	print("Shared winner name checks passed")
	quit()
