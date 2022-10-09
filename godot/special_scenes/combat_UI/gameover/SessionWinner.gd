extends Control

export var hall_of_fame: PackedScene

onready var last_winner:= InfoChampion.new()

func _ready():
	var this_session: TheSession = global.get("session")
	var session_info = {}
	if this_session:
		
		last_winner.player = this_session.get_last_winners()[0].to_dict()
		last_winner.session_info = this_session.to_dict()
		
	else:
		var info_player := InfoPlayer.new()
		info_player.set_species(global.get_species(TheUnlocker.unlocked_elements["species"].keys()[randi()%4]))
		last_winner.player = info_player.to_dict()
		
	$"%InsertName".grab_focus()
	$"%WinnerBanner".set_player(last_winner)

func _on_InsertName_name_inserted(player_real_name: String):
	$"%CanvasLayer".queue_free()
	$"%WinnerBanner".set_player_name(player_real_name)
	$"%Timer".start()


func _on_Timer_timeout():
	var scene = hall_of_fame.instance()
	add_child(scene)
	$CelebrateWinner.queue_free()
	scene.setup(last_winner)
	
func _on_Continue():
	Events.emit_signal("nav_to_map")
