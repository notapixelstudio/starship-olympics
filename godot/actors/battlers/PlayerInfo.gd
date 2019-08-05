extends Position2D

export var target_path: NodePath = @".."

export var primary_texture : Texture
export var secondary_texture : Texture

onready var target = get_node(target_path) as Node2D if has_node(target_path) else null
onready var player_id = $Scaled/Colored/PlayerID
onready var target_entity = ECM.E(target)

func _ready():
	if target.info_player:
		player_id.text = tr(target.info_player.id)
	$Scaled/Colored.modulate = target.species_template.color
	print("sHOULD WE be a timmatto?" + str(target.info_player.team))
	print("We are " + str(target.species_template.id))
	if target.species_template.id >= 100 and target.info_player.team:
		$Scaled/Colored/Circle.set_texture(secondary_texture)
	else:
		$Scaled/Colored/Circle.set_texture(primary_texture)
		
	update_scale()
	update_rotation()
	update_crown()
	
func _enter_tree():
	if target:
		update_rotation()
		
	if target_entity:
		update_crown()
	
func _process(delta):
	if target:
		update_rotation()
		
	if target_entity:
		update_crown()
		
	update_scale()
	
func update_scale():
	scale = target.arena.camera.zoom
	
func update_rotation():
	rotation = -target.rotation
	
func update_crown():
	$Scaled/Crown.set_visible(target_entity.has('Royal'))
	
var partial_score = 0
func update_score(score):
	partial_score += score
	$Scaled/Colored/PointsScored.set_points(partial_score)
	

func _on_Royal_enabled():
	$Scaled/Colored/PointsScored.visible = true

func _on_Royal_disabled():
	$Scaled/Colored/PointsScored.appear()
	yield($Scaled/Colored/PointsScored, "end")
	$Scaled/Colored/PointsScored.visible = false
	