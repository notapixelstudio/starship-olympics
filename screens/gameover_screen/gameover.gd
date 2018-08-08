extends "res://screens/basic_screen.gd"

var p2_sprite = preload("res://assets/tmp_red_team.jpg")
var p1_sprite = preload("res://assets/green_team.jpg")

func _input(event):
	if event is InputEventMouseButton:
		change_scene()

func _ready():
	var winner
	var win_count = 0
	var other 
	for player in global.scores:
		if winner:
			if global.scores[player] > win_count:
				winner = player
				win_count = global.scores[player]
			else:
				other = player
		else:
			winner = player 
			win_count = global.scores[player]

	for player in global.scores:
		if player != winner:
			other = player
	if winner=="p2":
		$Sprite.set_texture(p2_sprite)
	print(winner)
	print(other)
	$Winner.text = "The winner is " + str(winner) + " with "+ str(win_count) +" - " + str(global.scores[other])+" points "
	
	