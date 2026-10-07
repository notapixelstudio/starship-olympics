extends GutTest

const EFFECTS := preload("res://godot4/arena/managers/ItemManager.gd")

var session : Session


func before_each() -> void:
	session = Session.new()


func test_run_item_survives_the_match() -> void:
	session.grant_item(_item("shield", "run"), "P1")
	_end_match()
	assert_eq(session.count_items(&"shield", "P1"), 1)


func test_match_item_is_removed_when_the_match_ends() -> void:
	session.grant_item(_item("boost", "match"), "P1")
	_end_match()
	assert_eq(session.count_items(&"boost"), 0)
	assert_eq(session.scores.size(), 1)


func test_owners_are_isolated() -> void:
	session.grant_item(_item("trophy", "run"))
	session.grant_item(_item("charm", "run"), "P1")
	session.grant_item(_item("charm", "run"), "P2")
	assert_eq(session.count_items(&"charm"), 2)
	assert_eq(session.count_items(&"charm", "P1"), 1)
	assert_eq(session.count_items(&"charm", ""), 0)
	assert_eq(session.count_items(&"trophy", ""), 1)


func test_same_item_can_be_held_twice() -> void:
	var clock := _item("clock", "match")
	session.grant_item(clock, "P1")
	session.grant_item(clock, "P1")
	assert_eq(session.count_items(&"clock", "P1"), 2)


func test_each_session_has_its_own_items() -> void:
	var other := Session.new()
	session.grant_item(_item("trophy", "run"))
	assert_eq(session.count_items(&"trophy"), 1)
	assert_eq(other.count_items(&"trophy"), 0)


func test_head_start_points_per_team() -> void:
	var head_start := load("res://godot4/data/items/starting_points.tres") as Item
	session.grant_item(head_start, "P1")
	session.grant_item(head_start)
	var points: Dictionary = autofree(EFFECTS.new()).opening_points(session, [_player("P1", "A"), _player("P2", "A"), _player("P3", "B")])
	assert_eq(points["A"], 10)
	assert_eq(points["B"], 5)


func test_time_circuits_adds_seconds_for_the_whole_run() -> void:
	var circuits := load("res://godot4/data/items/TimeCircuits.tres") as Item
	assert_true(circuits.is_general())
	session.grant_item(circuits)
	_end_match()
	assert_eq(session.count_items(circuits.id, ""), 1)
	assert_eq(autofree(EFFECTS.new()).opening_seconds(session), 15)


func test_clock_extender_is_a_match_item() -> void:
	var clock := load("res://godot4/data/items/clock_extender.tres") as Item
	assert_eq(clock.id, &"clock_extender")
	assert_true(clock.lasts_one_match())
	session.grant_item(clock, "P1")
	_end_match()
	assert_eq(session.count_items(clock.id), 0)


func _end_match() -> void:
	var players : Array[Player] = []
	var winners : Array[String] = ["A"]
	session.add_match_results({
		"players": players,
		"remaining_time": 0.0,
		"time": 60.0,
		"max_score": 10,
		"minigame": "test",
		"standings": [{"team": "A", "score": 1.0}],
		"winners": winners,
	})


func _item(id : StringName, duration : String) -> Item:
	var item := Item.new()
	item.id = id
	item.name = id
	item.duration = duration
	return item


func _player(id : String, team : String) -> Player:
	var player := Player.new()
	player.set_id(id)
	player.set_team(team)
	return player
