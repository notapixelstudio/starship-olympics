extends Node

export var AlienScene: PackedScene
export var y := 1800.0
export var width := 4000.0

func _ready():
	Events.connect("holdable_replaced", self, '_on_holdable_replaced')
	Events.connect("holdable_swapped", self, '_on_holdable_swapped')

func start():
	$AnimationPlayer.play("Spawn")

func spawn_alien():
	var alien = AlienScene.instance()
	alien.position = Vector2(width*(randf()-0.5), y)
	global.arena.battlefield.add_child(alien)
	alien.start()

func _on_holdable_replaced(old, new, ship):
	if old is Alien and new is Alien and old.get_kind() == new.get_kind():
		# a match is worth 2 points
		old.queue_free()
		ship.get_cargo().empty()
		global.the_match.add_score(ship.get_player().id, 2)
		global.arena.show_msg(ship.get_player().species, 2, ship.position)

func _on_holdable_swapped(holdable1, holdable2, ship1, ship2):
	if holdable1 is Alien and holdable2 is Alien and holdable1.get_kind() == holdable2.get_kind():
		# a match made by two players is worth 1 point each
		ship1.get_cargo().empty()
		global.the_match.add_score(ship1.get_player().id, 1)
		global.arena.show_msg(ship1.get_player().species, 1, ship1.position)
		
		ship2.get_cargo().empty()
		global.the_match.add_score(ship2.get_player().id, 1)
		global.arena.show_msg(ship2.get_player().species, 1, ship2.position)
		
