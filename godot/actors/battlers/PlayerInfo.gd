extends Position2D

export var target_path: NodePath = @".."

onready var target = get_node(target_path) as Node2D if has_node(target_path) else null
onready var player_id = $Wrapper/Scaled/Colored/PlayerID
onready var target_entity = ECM.E(target)
onready var point_score = $Wrapper/Scaled/Colored/PointsScored

func _ready():
	if target.info_player:
		player_id.text = tr(target.info_player.id)
		if target.info_player.cpu:
			player_id.text = tr("CPU")
	$Wrapper/Scaled/Colored.modulate = target.species.color
	
	update_scale()
	update_rotation()
	
func _enter_tree():
	if target:
		update_rotation()
	
func _process(delta):
	if target:
		update_rotation()
		update_score_ring()
		
	update_scale()
	
	$Wrapper/Ball.rotation += delta
	
func update_scale():
	$Wrapper/Scaled.scale = target.arena.camera.zoom
	
func update_rotation():
	rotation = -target.rotation
	
var partial_score = 0
func update_score(score):
	partial_score += score
	point_score.set_points(partial_score)
	
func update_score_ring():
	$Wrapper/Scaled/Colored/Indicator.fraction = target.info_player.stats.score / target.arena.scores.target_score

func _on_Royal_enabled():
	$Wrapper/Scaled/RoyalGlow.visible = true
	yield(get_tree(), "idle_frame") # wait for cargo to load
	if target_entity.has('Cargo'):
		var what = target_entity.get('Cargo').what
		$Wrapper/Scaled/Crown.visible = what.type == Crown.types.CROWN
		$Wrapper/Ball.visible = what.type == Crown.types.BALL
		if what.type == Crown.types.BALL:
			$Wrapper/Ball.rotation = target.rotation
			$Wrapper/Ball/AnimationPlayer.play('appear')
	return
	point_score.show()

func _on_Royal_disabled():
	$Wrapper/Scaled/RoyalGlow.visible = false
	$Wrapper/Scaled/Crown.visible = false
	$Wrapper/Ball.visible = false
	return
	point_score.appear()
	yield(point_score, "end")
	point_score.hide()
	
