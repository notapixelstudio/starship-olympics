extends ColorRect

@export var players : Array[Player] : set = set_players
@export var session : Session : set = set_session

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
	set_process_unhandled_input(false)
	redraw()
	
func redraw() -> void:
	%Leaderboard.players = players
	%Leaderboard.session = session
	%Leaderboard.redraw()

func update_scores() -> void:
	%Leaderboard.update_scores()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventKey:
		get_tree().paused = false
		
		Events.continue_after_match_over.emit()
		

func enable_continue() -> void:
	# hackish, I know
	Engine.time_scale = 1 # doesn't work as expected
	set_process_unhandled_input(true)
	%ContinueAnimationPlayer.play("blink")
	
