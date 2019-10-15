extends Manager

func _on_play_sfx(species, sfx_name, scores):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load('res://assets/audio/FX/diamond_scored.ogg')
	add_child(sfx)
	sfx.pitch_scale = 0.9 + 0.03 * pow(scores.get_score(species),2) / scores.target_score
	sfx.bus = 'SFX_effected'
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()
	