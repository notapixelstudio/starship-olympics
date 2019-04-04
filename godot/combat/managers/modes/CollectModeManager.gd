extends ModeManager

const MULTIPLIER = 2

signal score
func _on_sth_collected(collector, collectee):
	if collectee is Coin:
		assert collector is Ship
		emit_signal('score', collector.species, MULTIPLIER)
		
func _on_coins_dropped(dropper, amount):
	emit_signal('score', dropper.species, -MULTIPLIER*amount)
	