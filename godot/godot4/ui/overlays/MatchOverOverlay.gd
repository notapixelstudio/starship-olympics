extends ColorRect

@export var players : Array[Player] : set = set_players
@export var session : Session : set = set_session
@export var hall_of_fame_scene: PackedScene

func hide() -> void:
	modulate = Color(0,0,0,0)

func show() -> void:
	%AnimationPlayer.play("appear")
	
func _on_appear() -> void:
	%Leaderboard.reorder()

func set_players(v:Array[Player]) -> void:
	players = v

func set_session(v:Session) -> void:
	session = v

func _ready() -> void:
	redraw()
	
func redraw() -> void:
	%Leaderboard.players = players
	%Leaderboard.session = session
	%Leaderboard.redraw()

func update_scores() -> void:
	%Leaderboard.update_scores()

func enable_continue() -> void:
	# hackish, I know
	Engine.time_scale = 1 # doesn't work as expected
	%PressAnyKey.enable()
	

func _on_press_any_key_any_key_pressed() -> void:
	%Leaderboard.visible = false
	var s: HallOfFame = hall_of_fame_scene.instantiate()
	s.session=session
	s.set_new_scores(session.scores[-1])
	add_child(s)
	%PressAnyKey.disable()
	
	# get_tree().paused = false
	# Events.continue_after_match_over.emit()
	
