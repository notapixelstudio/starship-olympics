extends BombSpawner

class_name BombDropper
var dropped_bomb

func spawn():
	$Dashed_container.visible = false
	var bomb = arena.spawn_bomb(position, null, owner_ship)
	ECM.E(bomb).get("Pursuer").disable()
	bomb.connect("detonate",Callable(self,"ready_to_respawn").bind(),CONNECT_ONE_SHOT)
	bomb.gravity_scale = 15.0
	dropped_bomb = bomb
	