extends CenterContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var species

func setup(species):
	$Sprite.texture = load("res://assets/character_"+species+"_1.png")
	$SelRect.texture = load("res://assets/character_selection_rect_"+species+".png")
func selected():
	$Sprite.modulate = Color(1,1,1)
	$SelRect.visible = true
	$SelRect.texture = load("res://assets/character_selection_rect_"+species+".png")
	
func lose():
	$Sprite.texture = load("res://assets/character_"+species+"_1_beaten.png")
	$SelRect.visible = false
	
func win():
	$Sprite.texture = load("res://assets/character_"+species+"_1.png")
	selected()

func flip(flip_flag):
	# flip if it is odd
	pass
	#$Sprite.flip_h = flip_flag
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
