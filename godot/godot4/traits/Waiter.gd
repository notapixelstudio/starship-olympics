extends Trait

func validate():
	super.validate()
	assert(host.has_method('start'))
	
func _ready():
	super._ready()
	Events.battle_start.connect(host.start)
