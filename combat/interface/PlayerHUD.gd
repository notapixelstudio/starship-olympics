extends MarginContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var points_container = get_node("NinePatchRect/Container/LivesCounter")
func _ready():
	if name.to_lower() in global.scores:
		get_scores()

	
func get_scores():
	var species = global.chosen_species[name.to_lower()].to_lower()
	get_node("NinePatchRect/Container/Label").text = name
	# adding to the grid
	var life_texture = load("res://actors/"+species+"_ship_plain.png")
	points_container.change_life_texture(life_texture)
	points_container.get_lives(global.scores[name.to_lower()])

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
