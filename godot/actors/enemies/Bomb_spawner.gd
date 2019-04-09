extends Node2D

var arena
export (Resource) var owned_by_species 
export (String) var owned_by_player
export (PackedScene) var bomb_scene
var owner_ship

func initialize(_arena):
	arena = _arena

func spawn():
	$Dashed_container.visible = false
	var bomb = arena.spawn_bomb(position, null, owner_ship)
	ECM.E(bomb).get("StandAlone").enable()
	bomb.connect("detonate", self, "ready_to_respawn",[], CONNECT_ONESHOT)
	
func ready_to_respawn():
	$Dashed_container.visible = true
	yield(get_tree().create_timer(5.0), "timeout")
	spawn()