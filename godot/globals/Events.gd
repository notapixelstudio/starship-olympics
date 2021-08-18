extends Node

signal bumper_created(bumper)
signal sth_tapped(tapper, tappee)

signal minigame_selected(minigame)
signal session_started
signal match_started
signal match_ended
signal continue_after_game_over(session_ended)

signal nav_to_menu
signal nav_to_map
signal nav_to_character_selection

signal sth_unhid(what, by_what) # e.g., Set by MapPlanet
signal sth_unlocked(what, by_what) # e.g., Set by MapPlanet

# Option menu UI
signal ui_back_menu
signal ui_nav_to(title, scene)
