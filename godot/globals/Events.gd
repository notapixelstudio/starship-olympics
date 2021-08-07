extends Node

signal bumper_created(bumper)
signal sth_tapped(tapper, tappee)

signal holdable_loaded(holdable, ship)
signal holdable_dropped(holdable, ship)

signal sth_collided_with_ship(sth, ship) # on enter, no distinction between body or area, includes NearArea
signal sth_is_overlapping_with_ship(sth, ship) # continuous check (opt-in), no distinction between body or area, NearArea only

signal minigame_selected(minigame)
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
