extends Node

var velocity = Vector2.ZERO;

var oldSentPos = Vector2.ZERO;
var myID = "";

onready var joystick = get_parent().get_node("CanvasLayer/JoyPad/joystick/joystick_button");
onready var textEdit = get_parent().get_node("CanvasLayer/ConnectPanel/TextEdit");
onready var Joystick_PANEL = get_parent().get_node("CanvasLayer/JoyPad");
onready var Buttons_PANEL = get_parent().get_node("CanvasLayer/AB_Buttons");
onready var Connect_PANEL = get_parent().get_node("CanvasLayer/ConnectPanel");
onready var BigButton_PANEL = get_parent().get_node("CanvasLayer/BigButton");

func _ready():
	Joystick_PANEL.set_visible(false);
	Buttons_PANEL.set_visible(false);
	BigButton_PANEL.set_visible(false);
	Connect_PANEL.set_visible(true);
	
	pass
	
func _process(delta):
	send_stuff("position", joystick.get_value());
	
func _on_ConnectBtn_pressed():
	var network = NetworkedMultiplayerENet.new();
	network.create_client(textEdit.text, 4242);
	get_tree().set_network_peer(network);
	network.connect("connection_failed", self, "_on_connection_failed");
	#$CanvasLayer/ConnectBtn.set_disabled(true);
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received");
	myID = get_tree().get_network_unique_id();
	print(myID);
	
	
func _on_connection_failed(error):
	$CanvasLayer/ConnectBtn.set_disabled(false);
	print(error);

func _on_packet_received(id, packet):
	if packet.get_string_from_ascii() == str(myID):
		Joystick_PANEL.set_visible(true);
		Buttons_PANEL.set_visible(false);
		BigButton_PANEL.set_visible(true);
		Connect_PANEL.set_visible(false);
	pass
	
func disconnectClient():
	get_tree().set_network_peer(null);



func send_stuff(type, data):
	if type == "position":
		if get_tree().get_network_peer() == null || data == oldSentPos:
			return;
		oldSentPos = data;
		rpc_unreliable_id(1, "receive_position", myID, data);
		
	if type == "button_input":
		if get_tree().get_network_peer() == null:
			return;
		rpc_unreliable_id(1, "receive_button_input", myID, data); # "a" o "b"
	
	if type == "big_button":
		if get_tree().get_network_peer() == null:
			return;
		rpc_unreliable_id(1, "receive_big_button_input", myID, data); # "bb"
	


func _on_A_Button_pressed():
	send_stuff("button_input", "a");


func _on_B_Button_pressed():
	send_stuff("button_input", "b");


func _on_BigBtn_pressed():
	#OS.vibrate_handheld(500);
	send_stuff("big_button", "bb");



func _on_RefreshBtn_pressed():
	disconnectClient();
	get_tree().reload_current_scene();
