extends Orchestrator

@export var turret_threshold := 30
@export var boss_music : AudioStream

func _ready():
	await super()
	
	# FIXME implement more score threshold besides medals
	Events.score_updated.connect(_maybe_new_turret_phase)
	
func _maybe_new_turret_phase(score, team, standings):
	if score < turret_threshold:
		return
		
	Events.log.emit("Turret phase 2")
	Events.score_updated.disconnect(_maybe_new_turret_phase)
	%BubbleBulletWeaponBack.enabled = true
	%BubbleBulletWeaponBack.visible = true
	
	await Events.score_threshold_passed
	%TimeManager.stop()
	%SpawnerWaveManager.stop()
	%Turrets.queue_free()
	DeeJay.fade_out()
	await DeeJay.effect_done
	await get_tree().create_timer(1).timeout
	DeeJay.play(boss_music)
	await get_tree().create_timer(1).timeout
	
	var boss = %DiamondBoss
	boss.next_phase()
	
	%TimeManager.start()
	%SpawnerWaveManagerBoss.start()
	
	await Events.score_threshold_passed
	%TimeManager.stop()
	boss.next_phase()
	%TimeManager.start()
	
	await Events.score_threshold_passed
	%TimeManager.stop()
	boss.next_phase()
	%TimeManager.start()
