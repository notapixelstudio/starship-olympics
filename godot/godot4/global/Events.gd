extends Node

signal bumper_created(bumper)

signal ship_spawned(ship)
signal ship_repaired(ship)
signal ship_damaged(ship, hazard, damager)
signal ship_died(ship, killer, for_good)

signal sths_bumped(sth1, sth2) # just one for pair

signal tappable_entered(tappable, ship)
signal tappable_exited(tappable, ship)
signal sth_tapped(tapper, tappee)

signal card_revealed(card)
signal card_taken(card, player, ship)
signal card_destroyed(card)

signal holdable_loaded(holdable, ship)
signal holdable_dropped(holdable, ship, cause)
signal holdable_replaced(old, new, ship)
signal holdable_swapped(holdable1, holdable2, ship1, ship2)
signal holdable_obtained(holdable, ship)
signal holdable_lost(holdable, ship)

signal planet_reached(planet, sth)

signal ship_dive_in(ship)
signal ship_dive_out(ship)

signal sth_collided_with_ship(sth, ship) # on enter, no distinction between body or area, includes NearArea
signal sth_is_overlapping_with_ship(sth, ship) # continuous check (opt-in), no distinction between body or area, NearArea only

# BEGIN 4.x events

# after character selection
signal versus_game_start(players_data:Array[Player])
signal campaign_game_start(players_data:Array[Player])

# players ready
signal player_ready(player)
signal team_ready(id, members)
signal battle_start

# clock
signal clock_ticked(t:float, t_secs:int)
signal clock_expired

signal collision(ship:Ship, collider:CollisionObject2D, tag:String)
signal spawn_request(object_to_spawn:Node)

signal ship_captured(ship:Ship, trap)#, capturer) maybe?
signal ship_released(ship:Ship, trap)#, capturer, saviour)

signal sth_crossed_gate(sth, gate:Gate)
signal beat(period:int)
signal new_objective(objective:Variant)

signal points_scored(amount:float, team:String)
signal score_updated(new_value:float, team:String, new_standings:Array)
signal score_threshold_passed(team:String) # maybe add threshold metadata?

signal log(message:String)
signal message(message:Variant, color:Color, global_position:Vector2)

signal match_over(data:Dictionary)
signal force_match_over(reason:String)

signal sth_collected(collector, collectee)
#signal sth_impacted(actor, environment:StaticBody2D)

signal blocks_cleared(blocks_field, amount, global_position)

signal start_charging(charger)
signal tap(tapper)

signal camera_updated(camera_state:Dictionary)

# match over
signal continue_after_match_over

signal loading_screen_done

# END 4.x events

signal sth_conquered(conqueror, conquered)

signal sth_countdown_expired(sth)

signal navigation_zone_changed(zone)

# Arena
signal ask_to_spawn
signal spawned

signal minigame_selected(picked_card)

signal execution_started
signal game_started
signal session_started
signal match_started
signal match_ended(match_dict)
signal session_ended
signal game_ended
signal execution_ended
signal analytics_enabled
signal analytics_disabled

signal continue_after_game_over(session_ended)
signal continue_after_session_ended

signal nav_to_menu
signal nav_to_map
signal nav_to_character_selection
signal nav_to_scene(scene)

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

# draftcard 
signal card_tapped(author, card)
signal starting_deck_selected(starting_deck)
signal selection_starting_deck_over
signal draft_ended(choices, hand)

# settings
signal glow_setting_changed
signal difficulty_selection_done
signal language_changed

# analytics
signal analytics_event(event_dictionary, event_name)

# persistence
signal store_settings

# Hall Of Fame
signal new_entry_hall_of_fame(new_champion)
