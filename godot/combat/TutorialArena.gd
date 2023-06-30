extends Arena

signal over

func _ready():
	$'%DescriptionMode'.set_gamemode(game_mode)
	$'%DescriptionMode'.appears()

	if global.is_match_running():
		$'%DescriptionMode'.set_draft_card(global.the_match.get_draft_card())


func _on_DescriptionMode_ready_to_fight():
	set_process(false)
	emit_signal("over")
