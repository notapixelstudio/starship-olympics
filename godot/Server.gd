# Server.gd
extends Node

var server := UDPServer.new()
var peers = []
var clients := {} 
onready var pingTime = OS.get_ticks_msec() 

signal remote_disconnected()
signal new_remote_connected()
signal remote_command_received() 

func _ready():
	server.listen(4242)

func _process(delta):
	server.poll() # Important!
	
	checkForNewMessages()
	checkForNewConnections()
	sendPing()

func checkForNewMessages():
	var postForDisconnect = []
	
	for i in range(0, peers.size()):
		if peers[i].get_available_packet_count ()>0:
			var pkt = peers[i].get_packet()	
			var cmd = pkt.get_string_from_utf8()
			#print("Received data: %s" % [cmd])
			var CmdArray = cmd.split(':')
			if CmdArray[0] == "cmd":
				emit_signal("remote_command_received",i+1,CmdArray[1],CmdArray[2])
			if CmdArray[0] == "disconnect":
				postForDisconnect.append(i)
	for i in postForDisconnect:
		var stringArray = peers[i].get_packet_ip().split(':')
		var ipKey = stringArray[0]
		clients.erase(ipKey)
		peers.remove(i)
		emit_signal("remote_disconnected",i+1)
		pass

func checkForNewConnections():
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var pkt = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [pkt.get_string_from_utf8()])
		var stringArray = peer.get_packet_ip().split(':')
		var ipKey = stringArray[0]
		if (clients.has(ipKey)):
			print("already connected")
		else:
			# Reply so it knows we received the message.
			peer.put_packet("OK".to_utf8())
			# Keep a reference so we can keep contacting the remote peer.
			peers.append(peer)
			clients[ipKey] = len(clients) +1
			emit_signal("new_remote_connected",clients[ipKey])

func sendPing():
	var timeNow = OS.get_ticks_msec() 
	if (timeNow - pingTime> 4500):
		for i in range(0, peers.size()):
			peers[i].put_packet("ping".to_utf8())
		pingTime = timeNow

func sendVibration(id):
	peers[id].put_packet("vibrate".to_utf8())

func get_connected_remotes():
	return len(clients)

		
