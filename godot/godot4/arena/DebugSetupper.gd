extends DebugNode

@export var test_ships : Array[Ship]

const test_players := [
	"P1",
	"P2",
	"P3",
	"P4"
]

const test_species := [
	preload("res://selection/characters/mantiacs_1.tres"),
	preload("res://selection/characters/robolords_1.tres"),
	preload("res://selection/characters/trixens_1.tres"),
	preload("res://selection/characters/umidorians_1.tres")
]

func _ready():
	var teams : Array[String] = []
	super._ready()
	if self.is_host_standalone():
		for i in len(test_ships):
			var test_ship = test_ships[i]
			var fake_player = Player.new()
			fake_player.set_id(test_players[i])
			fake_player.set_species(test_species[i])
			test_ship.set_player(fake_player)
			teams.append(test_players[i])
	%ScoreManager.set_teams(teams)
