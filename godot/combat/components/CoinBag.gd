extends Component

var amount = 0

func add_coin():
	amount += 1
	
func drop_some_coins():
	var how_many = min(amount, 6)
	amount -= how_many
	return how_many
	