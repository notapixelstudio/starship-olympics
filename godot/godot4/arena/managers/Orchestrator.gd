class_name Orchestrator
extends Node


func _ready():
	# TBD intro animation
	
	# apply modifiers, if any
	%ModifierManager.apply_all()
	# TBD animated modifiers
	
	# TBD animation with minigame title
	
	await %PlayersReadyWheels.all_players_ready
	Events.battle_start.emit()
	
