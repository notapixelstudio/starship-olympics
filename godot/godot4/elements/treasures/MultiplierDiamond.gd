extends Treasure

func collect(collector):
	super(collector)
	
	Events.message.emit("2X", collector.get_color(), global_position, true)
