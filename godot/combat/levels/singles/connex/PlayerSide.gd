extends Area2D
class_name PlayerSide

func get_klass():
	return 'Tile'

export var side_owner : NodePath
var player = null
export var source := true

var enabled := true
var neighbours := []
var on := false

func _ready():
	var player_spawner = get_node(side_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
	else:
		set_player(null)
		
	# need to wait for other tiles to settle
	yield(get_tree(), "idle_frame")
	# tiles don't change neighbours over time
	neighbours = []
	for area in $Neighbourhood.get_overlapping_areas():
		if area != self and area.has_method('get_klass') and area.get_klass() == 'Tile': # trick to avoid circular references
			neighbours.append(area)
			
	if not Engine.is_editor_hint(): # watch out for deleting this node when this is executed as a tool script!
		$Neighbourhood.queue_free() # delete areas to save physics computations
		
	set_off()
	if is_source():
		on = true # sources are always on
		modulate = Color(1.1,1.1,1.1)
	
func set_player(v : InfoPlayer):
	player = v
	if player != null:
		$ColorBand.modulate = player.species.color
		$'%PlayerLabel'.text = player.get_username().to_upper()
		
func get_player():
	return player
	
func get_conquering_player():
	return null

func propagate():
	for neighbour in neighbours:
		neighbour.set_on(get_player())
		
func set_on(on_player):
	if is_source() or on_player != player:
		return
	on = true
	modulate = Color(1.2,1.2,1.2)
	set_process(true)
	
func set_off():
	on = false
	modulate = Color(0.7,0.7,0.7)
	set_process(false)

func is_source() -> bool:
	return source
	
func _process(delta):
	global.the_match.add_score_to_team(player.team, delta)

func attempt_fortification():
	pass # player sides are already fortified
	
