extends TileMap
class_name Parade

export var alien_scene : PackedScene
export var mine_scene : PackedScene

export var min_col := -10
export var max_col := 10
export var starting_row := 10

var row := 0

const MINE = 0
const ALIEN = 1

func _ready():
	visible = false
	
func start():
	row = starting_row
	$Timer.wait_time = 2.0 - 0.25*global.the_game.get_number_of_players()
	$Timer.start()

func _on_Timer_timeout():
	spawn()
	
func spawn():
	position.y = -200*(row-starting_row)
	for col in range(min_col, max_col+1):
		if get_cell(col, row) == ALIEN:
			var alien = alien_scene.instance()
			alien.global_position = to_global(map_to_world(Vector2(col, row))) + Vector2(100, 100)
			get_parent().add_child(alien)
			# set speed according to player count
			var dive_speed = 200 + 50*global.the_game.get_number_of_players()
			alien.set_dive_speed(dive_speed)
			alien.start()
		elif get_cell(col, row) == MINE:
			var mine = mine_scene.instance()
			mine.global_position = to_global(map_to_world(Vector2(col, row))) + Vector2(100, 100)
			get_parent().add_child(mine)
			# set speed according to player count
			var dive_speed = 200 + 50*global.the_game.get_number_of_players()
			mine.set_dive_speed(dive_speed)
			mine.diving = true
			mine.start()
			
	row += 1
	
