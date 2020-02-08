extends Position2D

export var target_path: NodePath = @".."

export var primary_texture : Texture
export var secondary_texture : Texture

onready var target = get_node(target_path) as Node2D if has_node(target_path) else null
onready var player_id = $Scaled/Colored/PlayerID
onready var target_entity = ECM.E(target)
onready var point_score = $Scaled/Colored/PointsScored

func _ready():
	if target.info_player:
		player_id.text = tr(target.info_player.id)
		if target.info_player.cpu:
			player_id.text = tr("CPU")
	$Scaled/Colored.modulate = target.species.color
	
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
		update_score_ring()
		
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
	point_score.set_points(partial_score)
	
func update_score_ring():
	$Scaled/Colored/ScoreRing.fraction = target.info_player.score / target.arena.scores.target_score

func _on_Royal_enabled():
	$Scaled/RoyalGlow.visible = true
	return
	point_score.show()

func _on_Royal_disabled():
	$Scaled/RoyalGlow.visible = false
	return
	point_score.appear()
	yield(point_score, "end")
	point_score.hide()
	
