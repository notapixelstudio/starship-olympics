extends VBoxContainer

signal name_inserted(player_name: String)

const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
var current_letter_selected := 0
var cursor := 0
var name_input: LineEdit
var updating := false
var held_stick_actions := {}

func _ready() -> void:
	set_process_input(false)

func setup(input: LineEdit) -> void:
	name_input = input
	name_input.gui_input.connect(func(_event): _sync_cursor.call_deferred())
	name_input.text_changed.connect(func(_text): _sync_cursor())
	_sync_cursor()

func _sync_cursor() -> void:
	if not updating:
		_move_cursor(name_input.caret_column)
		_update_label()

func _input(event: InputEvent) -> void:
	if name_input == null or not is_processing_input() or not is_visible_in_tree():
		return
	# Keep printable keys (including the WASD menu bindings) for normal typing.
	if event is InputEventKey and event.unicode >= 32:
		return
	var action := ""
	for candidate in ["ui_up", "ui_down", "ui_left", "ui_right", "name_add", "name_delete", "name_clear"]:
		if not event.is_action(candidate):
			continue
		var pressed := event.is_action_pressed(candidate)
		if event is InputEventJoypadMotion:
			var stick_action := "%d:%s" % [event.device, candidate]
			var was_pressed: bool = held_stick_actions.get(stick_action, false)
			held_stick_actions[stick_action] = pressed
			pressed = pressed and not was_pressed
		if pressed:
			action = candidate
	if action.is_empty():
		return
	if cursor != name_input.caret_column:
		_sync_cursor()
	updating = true
	get_viewport().set_input_as_handled()
	match action:
		"ui_up", "ui_down":
			var step := -1 if action == "ui_up" else 1
			# END is only available after the last character.
			var choices := LETTERS.length() + (1 if cursor == name_input.text.length() else 0)
			current_letter_selected = wrapi(current_letter_selected + step, 0, choices)
			if cursor < name_input.text.length():
				name_input.text = name_input.text.substr(0, cursor) + LETTERS[current_letter_selected] + name_input.text.substr(cursor + 1)
		"ui_left":
			_move_cursor(maxi(0, cursor - 1))
		"name_add", "ui_right":
			if cursor < name_input.text.length():
				_move_cursor(cursor + 1)
			elif current_letter_selected == LETTERS.length():
				set_process_input(false)
				name_inserted.emit(name_input.text)
			else:
				name_input.text += LETTERS[current_letter_selected]
				_move_cursor(cursor + 1)
		"name_delete":
			if cursor > 0:
				name_input.text = name_input.text.erase(cursor - 1, 1)
				_move_cursor(cursor - 1)
		"name_clear":
			name_input.clear()
			_move_cursor(0)
	_update_selection()
	updating = false

func _move_cursor(position: int) -> void:
	cursor = position
	current_letter_selected = maxi(0, LETTERS.find(name_input.text[cursor].to_upper())) if cursor < name_input.text.length() else 0

func _update_selection() -> void:
	name_input.caret_column = cursor
	if cursor < name_input.text.length():
		name_input.select(cursor, cursor + 1)
	else:
		name_input.deselect()
	_update_label()

func _update_label() -> void:
	var letter := "END" if current_letter_selected == LETTERS.length() else ("SPACE" if LETTERS[current_letter_selected] == " " else LETTERS[current_letter_selected])
	$Selection.text = "[%s] · %d" % [letter, cursor + 1]
