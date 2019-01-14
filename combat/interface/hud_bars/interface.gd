extends Control

signal health_updated(value)
signal rupees_updated(count)

signal health_changed
func _ready():
	get_node("Bars/LifeBar").initialize(120)

func _on_Health_health_changed(health):
	emit_signal("health_updated", health)

func _on_Purse_rupees_changed(count):
	emit_signal("rupees_updated", count)

func _on_Game_update_time(value):
	emit_signal("health_updated", value)
	
func _on_Game_update_counter(value):
	emit_signal("rupees_updated", value)

func _on_Game_reset_lifebar(value):
	$Bars/LifeBar.initialize(value)
