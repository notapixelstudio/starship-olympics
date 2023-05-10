extends Control

func _ready():
	Soundtrack.play("Lobby", true)
	Events.connect("nav_to_scene", self, "_navigate_to_scene")
	# TranslationServer.set_locale("es")
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Label.text = tr("DEMO BUILD - v"+ str(global.version))
	$"%Info".text = "Sessions played: {sessions_played}. \n Decks unlocked: {unlocked} - Decks hidden: {hidden} \n Cards unlocked: {cards} \n Press SHIFT+R to reset".format({"sessions_played": global.sessions_played, "unlocked": TheUnlocker.get_unlocked_list("starting_decks"), "cards": TheUnlocker.get_unlocked_list("cards"), "hidden": TheUnlocker.get_unlocked_list("starting_decks", TheUnlocker.HIDDEN)})
	
func _process(delta):
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_R):
		global.sessions_played = 0
		global.reset_shown_cards_from_deck()
		# TheUnlocker.unlock_element("starting_decks", "winter", TheUnlocker.LOCKED)
		TheUnlocker.reset_unlocks()
		$"%Info".text = "Sessions played: {sessions_played}. \n Decks unlocked: {unlocked} - Decks hidden: {hidden} \n Cards unlocked: {cards} \n Press SHIFT+R to reset".format({"sessions_played": global.sessions_played, "unlocked": TheUnlocker.get_unlocked_list("starting_decks"), "cards": TheUnlocker.get_unlocked_list("cards"), "hidden": TheUnlocker.get_unlocked_list("starting_decks", TheUnlocker.HIDDEN)})
		persistance.save_game()

func _navigate_to_scene(scene: PackedScene):
	var instance = scene.instance()
	add_child(instance)
