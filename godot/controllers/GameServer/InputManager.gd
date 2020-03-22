extends Node

var players = []
var analogic = {}

signal pressed_big_button

func get_local_ip():
	for ip in IP.get_local_addresses():
		if str(ip).is_valid_ip_address() and str(ip).find(":") == -1 and str(ip) != "127.0.0.1":
			pass

func _ready():
	var network = NetworkedMultiplayerENet.new();
	network.create_server(4242, 2); #2 è il numero di giocatori
	get_tree().set_network_peer(network);
	
	network.connect("peer_connected", self, "_peer_connected");
	network.connect("peer_disconnected", self, "_peer_disconnected");
	
	print("IP:", IP.get_local_addresses())
	
func _process(delta):
	pass

func _peer_connected(id):
	#inizializzo il player
	players.append(str(id))
	analogic[str(id)] = Vector2.ZERO
	#instanzio il player
	 
	#debug
	print(str(id) + " connected");
	print(str(get_tree().get_network_connected_peers().size()) + " peers connected");
	#restituisco al player il suo id per conferma di connessione al server
	var welcome_text = str(id);
	get_tree().multiplayer.send_bytes(welcome_text.to_ascii());

func _peer_disconnected(id):
	#trovo il suo spazio e lo resetto, per permettere nuove connessioni al suo post
	analogic[id] = Vector2.ZERO;
	
	#debug
	print(str(id) + " disconnected");
	print(str(get_tree().get_network_connected_peers().size()) + " peers connected");

func get_index_from_id(id):
	return players.find(str(id)); #restituisce la posizione nell'array in base all'id
	
remote func receive_position(id, data):
	print("listening from: " + str(id));
	analogic[str(id)] = data; #salvo la analogic

remote func receive_button_input(id, data): #questa funzione ascolta per A e B
	pass

remote func receive_big_button_input(id, data): #questa funzione ascolta per il bottone grosso
	emit_signal("pressed_big_button", id, data)
