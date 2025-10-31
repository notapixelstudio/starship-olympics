extends Control

class_name WinnerBanner

var this_champion : Dictionary # InfoChampion
@export var minigame_logo : PackedScene
@export var headshot_scene: PackedScene

func _ready():
	$"%PlayerName".visible = true
	$"%HBoxContainer".visible = false
	$"%LogoMinigame".queue_free()
	
func set_player_name(player_name: String):
	$"%PlayerName".text = player_name


func set_banner(champion: Dictionary):
	this_champion = champion
	
	$"%PlayerName".text = champion.get("nickname", "GITTIZIO0")
	var players = champion.get("players", {})
	var i = 0
	
	for player in players:
		var p_info = Player.new(player)
		var headshot = headshot_scene.instantiate()
		headshot.set_player(p_info)
		
		$"%HeadshotContainer".add_child(headshot)
		#$"%HeadshotContainer".move_child(headshot, i)
		
		headshot.visible = true
		i+=1
	
	$"%DateSession".text = cleanup_datetime_str(Time.get_datetime_string_from_system(false, true))
	"""
	$"%Background".modulate = Settings.get_species(champion.player.species).get_color()
	$"%PlayerName".modulate = Settings.get_species(champion.player.species).get_color()
	$"%InsertName".modulate = Settings.get_species(champion.player.species).get_color()
	"""
	$"%InsertName".placeholder_text = $"%PlayerName".text
	
	%Score.text = str(int(champion.get('score', 0)))
	if champion.get('achievement') != null:
		%Medal.texture = load("res://assets/sprites/medals/"+champion.get('achievement')+'.png')
	else:
		%Medal.texture = null
		
	
func insert_name():
	$"%InsertName".connect("name_inserted", Callable(self, "_on_InsertName_name_inserted"))
	$"%PlayerName".visible = false
	$"%HBoxContainer".visible = true
	$"%InsertName".grab_focus()
	$"%InsertName".set_process_input(true)


func _on_InsertName_name_inserted(player_name: String):
	set_player_name(player_name)
	$"%PlayerName".visible = true
	$"%HBoxContainer".queue_free()
	$"%PlayerName".text = player_name
	this_champion.set("nickname", player_name)
	
	Events.new_entry_hall_of_fame.emit(this_champion)
	

func cleanup_datetime_str(datetime_str: String):
	return datetime_str.replace("T", " ")
