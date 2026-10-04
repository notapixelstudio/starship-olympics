extends Collectable

func collect(collector):
	super(collector)
	
	_ctx.time_gained.emit(5)
	Events.message.emit("+5 sec", collector.get_color(), global_position, true)
