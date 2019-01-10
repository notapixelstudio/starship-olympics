tool

extends Wall

export (int) var apothem = 100*sqrt(3)/2 setget set_apothem
export (int) var radius = 100 setget set_radius

func set_apothem(a):
	apothem = a
	radius = a/sqrt(3)*2
	ar2pts()
	
func set_radius(r):
	radius = r
	apothem = r*sqrt(3)/2
	ar2pts()
	
func ar2pts():
	set_points(PoolVector2Array([
		Vector2(radius*cos(0),radius*sin(0)),
		Vector2(radius*cos(PI/3),radius*sin(PI/3)),
		Vector2(radius*cos(2*PI/3),radius*sin(2*PI/3)),
		Vector2(radius*cos(PI),radius*sin(PI)),
		Vector2(radius*cos(4*PI/3),radius*sin(4*PI/3)),
		Vector2(radius*cos(5*PI/3),radius*sin(5*PI/3))
	])) # clockwise!
	