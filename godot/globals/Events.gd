extends Node

signal bumper_created(bumper)
signal sth_tapped(tapper, tappee)

signal minigame_selected(minigame)
signal match_ended
signal continue_after_game_over(session_ended)

# Option menu UI
signal ui_back_menu
signal ui_nav_to(title, scene)
