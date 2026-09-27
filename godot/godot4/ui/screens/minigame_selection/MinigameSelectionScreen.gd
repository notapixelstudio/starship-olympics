extends BackScreen

@export var next_scene : PackedScene
@export var minigame_button_scene : PackedScene

func _ready() -> void:
	Events.level_selection_screen_ready.emit(self)
	
func list_levels_for_session(session:Session) -> void:
	if session is SinglePveMatchSession:
		_populate_list(Utils.list_levels(len(session.players), 'pve'))
	elif session is SinglePvpMatchSession:
		_populate_list(Utils.list_levels(len(session.players), 'pvp'))
	
func _populate_list(levels) -> void:
	for level in levels:
		var minigame_button : Button = minigame_button_scene.instantiate()
		minigame_button.set_data(level)
		minigame_button.selected.connect(_on_minigame_button_selected)
		%MinigamesList.add_child(minigame_button)
		%MinigamesList.move_child(minigame_button, 0)
		
func enter():
	super.enter()
	%MinigamesList.get_child(0).grab_focus()

func _on_minigame_button_selected(level) -> void:
	var modifiers : Array[String] = []
	if %CheckBoxWinter.is_pressed():
		modifiers.append(&'winter')
		
	SoundEffects.play(%AudioStreamPlayer)
	Events.level_selected.emit(level['scene'], modifiers)
	
	next.emit(next_scene.instantiate())
