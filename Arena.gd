extends Node

func update_score(player):
	var updated_label
	if player == 'p1':
		updated_label = get_node('/root/Arena/Label2')
	else: 
		updated_label = get_node('/root/Arena/Label1')
	updated_label.update_score()

func _on_Explosion_body_entered(body):
	print('boom')
