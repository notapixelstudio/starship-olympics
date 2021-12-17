extends Control

export var Minicard : PackedScene

class_name MapPanel


var player : InfoPlayer = null

var content # could be Set
var rest_text = "select\na planet"
var chosen = false
const deselected_modulate = Color(0.6,0.6,0.6,1)

func get_id() -> String:
	return self.name.to_lower()
	
func _ready():
	if player == null:
		disable()
	$Background.self_modulate = deselected_modulate
	Events.connect("tappable_entered", self, '_on_tappable_entered')
	Events.connect("tappable_exited", self, '_on_tappable_exited')

func set_chosen(chosen_):
	if not is_inside_tree():
		yield(self, "ready")
	chosen = chosen_
	if chosen:
		$Background.self_modulate = Color(1.1,1.1,1.1,1)
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,-30), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	else:
		$Background.self_modulate = deselected_modulate
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,0), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	
func set_player(v : InfoPlayer):
	assert(v != null)
	player = v
	$Sprite.texture = player.species.ship
	$Info.text = rest_text
	$Background.modulate = player.species.color
	
func set_content(v):
	if not is_inside_tree():
		yield(self, "ready")
	if v:
		content = v
		if TheUnlocker.get_status('sets', v.get_id()) == TheUnlocker.UNLOCKED:
			$Label.text = content.name
		else:
			$Label.text = "???"
		$Info.text = content.description
		create_minicards()
	else:
		$Label.text = ""
		$Info.text = rest_text
		destroy_minicards()

func enable():
	modulate = Color(1,1,1,1)
	$Sprite.visible = true
	
func disable():
	modulate = Color(1,1,1,0.1)
	$Sprite.visible = false
	
const dx = 110
const dy = 70
func create_minicards():
	destroy_minicards() # FIXME ugly, but useful
	if not content is Set:
		return
	var i = 0
	for minigame in content.minigames:
		var minicard = Minicard.instance()
		minicard.set_content(minigame)
		$Minicards.add_child(minicard)
		minicard.position = Vector2(dx*(i%2) - dx/2, dy*floor(i/2) - dy/2)
		i += 1
	
func destroy_minicards():
	for minicard in $Minicards.get_children():
		minicard.queue_free()
	
func get_minicards():
	return $Minicards.get_children()

# content preview on hover
func _on_tappable_entered(tappable, ship):
	if ship.get_player() != player:
		return
		
	if tappable is MapPlanet and tappable.get_status() != 'hidden':
		set_content(tappable.get_set())
		
func _on_tappable_exited(tappable, ship):
	if ship.get_player() != player:
		return
		
	set_content(null)
