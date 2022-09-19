extends Node

signal bumper_created(bumper)

signal ship_damaged(ship, hazard, damager)
signal ship_died(ship, killer, for_good)

signal sths_bumped(sth1, sth2) # just one for pair

signal tappable_entered(tappable, ship)
signal tappable_exited(tappable, ship)
signal tap(tapper)
signal sth_tapped(tapper, tappee)

signal holdable_loaded(holdable, ship)
signal holdable_dropped(holdable, ship, cause)
signal holdable_replaced(old, new, ship)
signal holdable_swapped(holdable1, holdable2, ship1, ship2)

signal planet_reached(planet, sth)

signal sth_collided_with_ship(sth, ship) # on enter, no distinction between body or area, includes NearArea
signal sth_is_overlapping_with_ship(sth, ship) # continuous check (opt-in), no distinction between body or area, NearArea only

signal sth_collected(collector, collectee)
# Arena
signal ask_to_spawn
signal spawned

signal minigame_selected(picked_card)

signal execution_started
signal game_started
signal session_started
signal match_started
signal match_ended
signal session_ended
signal game_ended
signal execution_ended

signal continue_after_game_over(session_ended)

signal nav_to_menu
signal nav_to_map
signal nav_to_character_selection

signal sth_unhid(what, by_what) # e.g., Set by MapPlanet
signal sth_unlocked(what, by_what) # e.g., Set by MapPlanet

# Option menu UI
signal ui_back_menu
signal ui_nav_to(title, scene)

# this is being used to show some additional information
signal show_info(what_to_show)
signal hide_info
signal ask_mapping_action(complete_action, remap_action_node)
# signal remap_event(event, complete_action) # Decided to connect directly the nodes
signal remap_done(remap_action_node) 

# players ready
signal player_ready(player_info)

# draftcard 
signal card_tapped(author, card)
signal starting_deck_selected(starting_deck)
signal selection_starting_deck_over
