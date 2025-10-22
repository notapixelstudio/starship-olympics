class_name Orchestrator
extends Node


func _ready():
	await %PlayersReadyWheels.all_players_ready
	Events.battle_start.emit()
