extends Diamondz

class_name BigDiamondz

func _ready():
	super.set_points(3)

func on_collected_by(collector):
	super.on_collected_by(collector)
	SoundEffects.play($AudioStreamPlayer2D)
