extends GutTest

var session : Session


func before_each() -> void:
	session = Session.new()


func test_run_item_survives_the_match() -> void:
	session.grant_item(_item("shield", Item.Duration.RUN), "P1")
	_end_match()
	_end_match()
	_end_match()
	assert_eq(session.count_items(&"shield", "P1"), 1)


func test_game_item_is_removed_when_the_match_ends() -> void:
	session.grant_item(_item("boost", Item.Duration.GAME), "P1")
	_end_match()
	assert_eq(session.count_items(&"boost"), 0)
	assert_eq(session.scores.size(), 1)


func test_two_games_item_lasts_two_matches() -> void:
	session.grant_item(_item("boost", Item.Duration.TWO_GAMES), "P1")
	_end_match()
	assert_eq(session.count_items(&"boost"), 1)
	_end_match()
	assert_eq(session.count_items(&"boost"), 0)


func test_copies_of_one_item_count_down_separately() -> void:
	var boost := _item("boost", Item.Duration.TWO_GAMES)
	session.grant_item(boost, "P1")
	_end_match()
	session.grant_item(boost, "P1")
	_end_match()
	assert_eq(session.count_items(&"boost"), 1)
	assert_eq(boost.games_left, 0, "the granted resource itself is untouched")


func test_glass_breaks_only_for_its_holder() -> void:
	var glass := _item("charm", Item.Duration.RUN, true)
	session.grant_item(glass, "P1")
	session.grant_item(glass, "P2")
	session.grant_item(_item("charm", Item.Duration.RUN), "P1")
	session.break_glass("P1")
	assert_eq(session.count_items(&"charm", "P1"), 1)
	assert_eq(session.count_items(&"charm", "P2"), 1)


func test_owners_are_isolated() -> void:
	session.grant_item(_item("trophy", Item.Duration.RUN))
	session.grant_item(_item("charm", Item.Duration.RUN), "P1")
	session.grant_item(_item("charm", Item.Duration.RUN), "P2")
	assert_eq(session.count_items(&"charm"), 2)
	assert_eq(session.count_items(&"charm", "P1"), 1)
	assert_eq(session.count_items(&"charm", ""), 0)
	assert_eq(session.count_items(&"trophy", ""), 1)


func test_same_item_can_be_held_twice() -> void:
	var clock := _item("clock", Item.Duration.GAME)
	session.grant_item(clock, "P1")
	session.grant_item(clock, "P1")
	assert_eq(session.count_items(&"clock", "P1"), 2)


func test_each_session_has_its_own_items() -> void:
	var other := Session.new()
	session.grant_item(_item("trophy", Item.Duration.RUN))
	assert_eq(session.count_items(&"trophy"), 1)
	assert_eq(other.count_items(&"trophy"), 0)


func test_clock_extender_type_loads() -> void:
	var clock := Item.new()
	clock.type = load("res://godot4/data/items/clock_extender.tres") as ItemType
	assert_eq(clock.id, &"clock_extender")
	session.grant_item(clock, "P1")
	_end_match()
	assert_eq(session.count_items(clock.id), 0)


func test_merge_replaces_complete_sets_only() -> void:
	var item_manager := load("res://godot4/arena/managers/ItemManager.gd")
	var parts := {&"gp": [&"bounty", &"head"]}
	assert_eq(item_manager.merge([&"bounty", &"time", &"head"], parts), [&"time", &"gp"])
	assert_eq(item_manager.merge([&"bounty", &"bounty", &"head"], parts), [&"bounty", &"gp"])
	assert_eq(item_manager.merge([&"bounty"], parts), [&"bounty"])


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


func _item(id : StringName, duration : Item.Duration, glass := false) -> Item:
	var item := Item.new()
	item.type = ItemType.new()
	item.type.id = id
	item.type.name = id
	item.duration = duration
	item.glass = glass
	return item
