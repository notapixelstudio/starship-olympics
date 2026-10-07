extends Collectable

func collect(collector):
	super(collector)
	# the time itself is added by the clock_extender effect in the arena ItemManager
	Events.message.emit("+5 sec", collector.get_color(), global_position, true)
