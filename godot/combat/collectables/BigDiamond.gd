extends Diamond

class_name BigDiamond

func _ready():
	.set_points(3)

func on_collected_by(collector):
	.on_collected_by(collector)
	SoundEffects.play($AudioStreamPlayer2D)
