extends NinePatchRect

func change_life_texture(new_texture): 
	get_node("life_texture").texture = new_texture
	
func get_lives(lives):
	get_node("Number").text = str(lives)