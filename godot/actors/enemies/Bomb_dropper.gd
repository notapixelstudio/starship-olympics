extends BombSpawner

class_name BombDropper
var dropped_bomb

func spawn():
	$Dashed_container.visible = false
	var bomb = arena.spawn_bomb(position, null, owner_ship)
	ECM.E(bomb).get("Pursuer").disable()
	bomb.connect("detonate", self, "ready_to_respawn",[], CONNECT_ONESHOT)
	bomb.gravity_scale = 15.0
	dropped_bomb = bomb
	