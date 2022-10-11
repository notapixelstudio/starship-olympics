extends Node

var max_ammo = -1 setget set_max_ammo
var infinite_ammo : bool
var current_ammo = max_ammo
var reload_time setget set_reload_time
var autoreload : bool

func set_max_ammo(v):
	max_ammo = v
	infinite_ammo = max_ammo == -1
	
func set_reload_time(v):
	reload_time = v
	autoreload = reload_time != -1
	$ReplenishTimer.wait_time = reload_time
	
func shot():
	if infinite_ammo:
		return
		
	current_ammo = max(0, current_ammo-1)
	
	if autoreload:
		$ReplenishTimer.stop()
		$ReplenishTimer.start()
	
func reload():
	if infinite_ammo:
		return
		
	current_ammo = min(max_ammo, current_ammo+1)
	
func replenish():
	if infinite_ammo:
		return
		
	current_ammo = max_ammo
	
func is_empty():
	if infinite_ammo:
		return false
		
	return current_ammo == 0

func _on_ReplenishTimer_timeout():
	replenish()
