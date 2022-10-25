tool
extends Tile
class_name TriTile

# OVERRIDE!
func refresh_polygon():
	pass

# override
func fortify():
	.fortify()
	$Foreground.scale = Vector2(1,1)
	$Foreground.position = Vector2(0,foreground_offset).rotated(-global_rotation)
	$Graphics/Background.scale = Vector2(1,1)
	$Graphics/Background.position = Vector2(0,0)
	$Graphics/Background.polygon = PoolVector2Array([
		Vector2(-50,50),
		Vector2(-50,-50),
		Vector2(-45,-50),
		Vector2(50,45),
		Vector2(50,50)
	])
