extends Resource

class_name Session
var scores: Array[Scores] = []

## Items carried through this run: player id -> items they hold. The empty key [code]""[/code] is the whole session.
## Effects live in the arena ItemManager.
@export var items : Dictionary[String, Array] = {}

var uuid : String
var players : Array
var timestamp_local : String
var timestamp : String

func get_last_score()->Scores:
	return scores[-1]
	
func add_match_results(match_results:Dictionary) -> void:
	var s = Scores.new(match_results)
	scores.append(s)
	for player_id in items:
		items[player_id] = items[player_id].filter(func(item : Item) -> bool: return item.survives_game())

## Grants a copy of [param item] to [param player_id], or to the whole session when empty.
func grant_item(item : Item, player_id := "") -> void:
	assert(item != null)
	var copy := item.duplicate() as Item # each copy counts down its own games
	copy.games_left = item.duration
	items.get_or_add(player_id, []).append(copy)

## A hit shatters every glass item held by [param player_id].
func break_glass(player_id : String) -> void:
	if items.has(player_id):
		items[player_id] = items[player_id].filter(func(item : Item) -> bool: return not item.glass)

## How many copies of [param item_id] are held, optionally only by [param player_id].
func count_items(item_id : StringName, player_id = null) -> int:
	var total := 0
	for pid in items:
		if player_id == null or pid == player_id:
			total += items[pid].filter(func(item : Item) -> bool: return item.id == item_id).size()
	return total

# virtual
func is_over() -> bool:
	return false

# virtual
func is_winner(team:String) -> bool:
	return false
