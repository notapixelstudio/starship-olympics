extends ScrollContainer

export var MinigameListItemScene : PackedScene

const DECK_PATH = "res://map/draft/"
const CARD_POOL_PATH = "res://map/draft/pool"

func _ready():
	var classic_minigames = load(DECK_PATH+'/classic.tres').minigames
	var pool = load(CARD_POOL_PATH+'/the_card_pool.tres').cards
	var minigames = classic_minigames + pool
	
	for minigame in minigames:
		var item = MinigameListItemScene.instance()
		item.set_minigame(minigame)
		$VBoxContainer.add_child(item)
		
