extends Node


func _ready():
	await get_tree().process_frame
	Events.battle_start.emit()
