extends Diamond

class_name BigDiamond

func _ready():
	super.set_points(3)

func on_collected_by(collector):
	super.on_collected_by(collector)
	SoundEffects.play($AudioStreamPlayer2D)
