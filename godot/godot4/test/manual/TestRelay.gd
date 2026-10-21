extends Node
## Headless functional check for the relay baton (RacingGame.gd + Baton.gd + CargoManager passable gate).
## Run with: godot --headless --path godot res://godot4/test/manual/TestRelay.tscn

var _ok := true

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: ", msg)
	else:
		print("FAIL: ", msg)
		_ok = false

func _ready() -> void:
	var scene : PackedScene = load("res://godot4/minigames/ring-racing/pve/2p.tscn")
	var arena = scene.instantiate()
	add_child(arena)

	for i in range(10):
		await get_tree().process_frame

	# simulate both human players finishing the ready-wheel (no input is driving it headlessly)
	for player in arena.get_active_players():
		Events.player_ready.emit(player)

	for i in range(30):
		await get_tree().process_frame

	var ship_by_id := {}
	for ship in get_tree().get_nodes_in_group("Ship"):
		ship_by_id[ship.get_player().get_id()] = ship

	var ship1 = ship_by_id.get("P1")
	var ship2 = ship_by_id.get("P2")
	_check(ship1 != null and ship2 != null, "both ships spawned")
	if ship1 == null or ship2 == null:
		print("RESULT: FAILED (ships missing)")
		get_tree().quit(1)
		return

	var racing_game = arena.get_node("Managers/RacingGame")
	var gates = racing_game._ordered_gates
	_check(gates.size() > 0, "course has gates (%d)" % gates.size())

	_check(ship1.has_cargo_class(Baton), "P1 starts holding the baton")
	_check(not ship2.has_cargo_class(Baton), "P2 starts without the baton")
	_check(racing_game._relay_teams.get("GG", false), "team GG is flagged as a relay team")
	_check(racing_game._progress.get("GG", -1) == 0, "team GG progress starts at 0")
	_check(not ship1.get_cargo_manager().get_cargo().passable, "P1's fresh baton starts not-passable")
	_check(ship1.get_node("%Message").text == "", "P1 shows no ambient message while running their leg")
	_check(ship2.get_node("%Message").text == "", "P2 shows no ambient message while benched")
	_check(racing_game._pen_doors.has("GG"), "P2 starts boxed in a holding pen with a closed door")
	_check(not racing_game._pen_doors["GG"].is_queued_for_deletion(), "the pen door is still standing before the lap is done")

	# a bump right now must NOT exchange a baton that hasn't done a lap yet
	ship1.swap_cargo(ship2)
	_check(ship1.has_cargo_class(Baton), "baton stays with P1 before a lap is completed")
	_check(not ship2.has_cargo_class(Baton), "P2 doesn't receive the baton before P1 completes a lap")

	# P2 (no baton) crosses gate 0: must NOT advance the shared progress
	racing_game._on_gate_crossed(ship2, gates[0], true)
	_check(racing_game._progress["GG"] == 0, "non-baton crossing is ignored")

	# drive P1 through every gate except the last one: the lap isn't done, pen stays shut
	for i in range(len(gates) - 1):
		racing_game._on_gate_crossed(ship1, gates[i], true)
	_check(racing_game._pen_doors.has("GG"), "pen door is still shut mid-lap")

	# crossing the gate just before the start: release the teammate early, like a real exchange zone
	racing_game._on_gate_crossed(ship1, gates[-1], true)
	_check(not racing_game._pen_doors.has("GG"), "pen door opens a beat before the lap actually finishes")
	_check(not ship1.get_cargo_manager().get_cargo().passable, "...but the baton itself isn't passable yet")

	# now cross the start gate again: the lap is actually complete
	racing_game._on_gate_crossed(ship1, gates[0], true)
	_check(racing_game._progress["GG"] == 1, "team progress reflects every baton-holder crossing along the lap")
	_check(ship1.get_cargo_manager().get_cargo().passable, "P1's baton becomes passable after completing a lap")
	_check(ship1.get_node("%HatSprite").material.get_shader_parameter("color") != Color.WHITE, "P1's baton outline glows once passable")
	_check(ship1.get_cargo_manager()._baton_pulse_tween != null, "P1's baton icon starts pulsing once passable")
	_check(ship1.get_node("%Message").text == racing_game.MSG_PASS_IT, "P1 (holder, lap done) briefly flashes PASS IT!")

	# let the pulse actually animate a bit and confirm the icon is moving, not just tagged as pulsing
	await get_tree().create_timer(0.2).timeout
	_check(ship1.get_node("%HatSprite").scale != Vector2.ONE, "P1's baton icon has visibly scaled up mid-pulse")

	# the flash is temporary: it must clear itself after FLASH_DURATION, with no lingering nag
	await get_tree().create_timer(racing_game.FLASH_DURATION + 0.2).timeout
	_check(ship1.get_node("%Message").text == "", "P1's flash message clears itself")

	# P1 keeps the baton and tries to just keep going instead of handing off: must NOT score more
	racing_game._on_gate_crossed(ship1, gates[1], true)
	_check(racing_game._progress["GG"] == 1, "the same holder can't start a second lap without handing off first")

	# now the bump should succeed
	ship1.swap_cargo(ship2)
	_check(ship2.has_cargo_class(Baton), "baton transferred to P2 after P1 completes a lap and bumps")
	_check(not ship1.has_cargo_class(Baton), "P1 no longer holds the baton after handing off")
	_check(not ship2.get_cargo_manager().get_cargo().passable, "P2's baton resets to not-passable after the hand-off")
	_check(ship1.get_cargo_manager()._baton_pulse_tween == null, "P1's pulse stops once they no longer hold the baton")
	_check(ship1.get_node("%HatSprite").scale == Vector2.ONE, "P1's baton icon scale resets after the pulse stops")
	_check(ship2.get_node("%HatSprite").material.get_shader_parameter("color") == Color.WHITE, "P2's baton outline resets to plain white after the hand-off")
	_check(ship1.get_node("%HatSprite").material != ship2.get_node("%HatSprite").material, "P1 and P2 have independent outline materials (not a shared global resource)")

	# P2 just received it: a bump must be blocked again until P2 completes their own lap
	ship2.swap_cargo(ship1)
	_check(ship2.has_cargo_class(Baton), "bump is blocked again until the new holder completes a lap too")

	# P1 (no longer holding) crossing does not advance progress
	racing_game._on_gate_crossed(ship1, gates[1], true)
	_check(racing_game._progress["GG"] == 1, "ex-holder's crossing after hand-off is ignored")

	# P2 (current holder) crossing advances progress
	racing_game._on_gate_crossed(ship2, gates[1], true)
	_check(racing_game._progress["GG"] == 2, "new baton holder's crossing advances team progress")

	print("RESULT: ", "ALL PASS" if _ok else "SOME FAILED")
	get_tree().quit(0 if _ok else 1)
