extends Position2D

export var target_path: NodePath = @".."

onready var target = get_node(target_path) as Node2D if has_node(target_path) else null
onready var player_id = $Wrapper/Scaled/Colored/PlayerID
onready var player_team_outline = $Wrapper/Scaled/PlayerIDTeamOutline
onready var target_entity = ECM.E(target)
onready var point_score = $Wrapper/Scaled/Colored/PointsScored
onready var ammo = $Wrapper/Scaled/Colored/AmmoIndicator
onready var minisun = $Wrapper/Scaled/Colored/Minisun
onready var minimoon = $Wrapper/Scaled/Colored/Minimoon
onready var minisun_outline = $Wrapper/Scaled/Minisun
onready var minimoon_outline = $Wrapper/Scaled/Minimoon

func _ready():
	if target.info_player:
		player_id.text = tr(target.info_player.id)
		if target.info_player.cpu:
			player_id.text = tr("CPU")
			
		if target.info_player.has_proper_team():
			player_team_outline.visible = true
			player_team_outline.text = tr(target.info_player.id)
			
			minisun_outline.visible = target.info_player.team == 'A'
			minimoon_outline.visible = target.info_player.team == 'B'
			minisun.visible = target.info_player.team == 'A'
			minimoon.visible = target.info_player.team == 'B'
			
			var team_color = target.info_player.get_team_color()
			player_team_outline.modulate = team_color
			minisun_outline.material.set_shader_param('color', team_color)
			minimoon_outline.material.set_shader_param('color', team_color)
			
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
	
func update_scale():
	$Wrapper/Scaled.scale = Vector2(5,5) if not target.camera or not target.camera.enabled else target.camera.zoom
	
func update_rotation():
	rotation = -target.rotation
	
var partial_score = 0
func update_score(score):
	partial_score += score
	point_score.set_msg(partial_score)
	
func update_score_ring():
	if global.is_match_running() and target.info_player and target.info_player.stats:
		$Wrapper/Scaled/Colored/Indicator.fraction = target.info_player.stats.score / global.the_match.target_score

func _on_Royal_enabled():
	$Wrapper/RoyalGlow.visible = true
	yield(get_tree(), "idle_frame") # wait for cargo to load
	if target_entity.has('Cargo'):
		var what = target_entity.get('Cargo').what
		$Wrapper/Crown.visible = what.type == Crown.types.CROWN
		$Wrapper/Ball.visible = what.type == Crown.types.BALL
		if what.type == Crown.types.BALL:
			$Wrapper/Ball.rotation = target.rotation
			$Wrapper/Ball/AnimationPlayer.play('appear')
		$Wrapper/SoccerBall.visible = what.type == Crown.types.SOCCERBALL
		$Wrapper/RoyalGlow.modulate = target.species.color
		if what.type == Crown.types.SOCCERBALL:
			$Wrapper/SoccerBall.rotation = target.rotation
			$Wrapper/SoccerBall/AnimationPlayer.play('appear')
		$Wrapper/TennisBall.visible = what.type == Crown.types.TENNISBALL
		$Wrapper/RoyalGlow.modulate = target.species.color
		if what.type == Crown.types.TENNISBALL:
			$Wrapper/TennisBall.rotation = target.rotation
			$Wrapper/TennisBall/AnimationPlayer.play('appear')
	# point_score.show()
	return
	

func _on_Royal_disabled():
	$Wrapper/RoyalGlow.visible = false
	$Wrapper/Crown.visible = false
	$Wrapper/Ball.visible = false
	$Wrapper/SoccerBall.visible = false
	$Wrapper/TennisBall.visible = false
	
	# point_score.appear()
	# yield(point_score, "end")
	# point_score.hide()
	return
	
func reset_health(amount):
	$Wrapper/Scaled/Colored/HealthBar.set_total(amount)

func update_health(amount):
	$Wrapper/Scaled/Colored/HealthBar.set_amount(amount)
