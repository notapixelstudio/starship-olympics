extends MarginContainer

export(String) var p_name = "BOH"
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var container = $NinePatchRect/Container
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	container.get_node("Label").text = p_name
	pass

func get_life_count():
	var count = 0
	for node in $NinePatchRect/Container.get_children():
		if node.is_in_group("lives"):
			count +=1
	return count
	
func remove_life():
	$NinePatchRect/Container.remove_child($NinePatchRect/Container.get_child(get_child_count()))

func add_life():
	var life_texture = load("res://actors/"+global.chosen_species[p_name]+"_ship_plain.png")
	var life = load("res://screens/game_screen/life_rect.tscn").instance()
	life.set_texture(life_texture)
	container.add_child(life)
	

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	$NinePatchRect.rect_min_size.y = $NinePatchRect/Container.rect_size.y + 10
