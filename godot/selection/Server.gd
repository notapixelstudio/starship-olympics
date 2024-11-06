# Server.gd
extends Node

var server := UDPServer.new()
var peers = []

signal new_player_connected()
signal up_received()
signal left_received()
signal right_received()
signal down_received()
signal fire_received()


func _ready():
	server.listen(4242)

func _process(delta):
	server.poll() # Important!
	
	for i in range(0, peers.size()):
		if peers[i].get_available_packet_count ()>0:
			var pkt = peers[i].get_packet()	
			var cmd = pkt.get_string_from_utf8()
			#print("Received data: %s" % [cmd])
			var CmdArray = cmd.split(':')
			if CmdArray[0] == "cmd":
				var cmds = CmdArray[1]
				#print("Received data: %s" % cmds)
				if cmds[0] == "1":
					emit_signal("up_received")
				if cmds[1] == "1":
					emit_signal("left_received")
				if cmds[2] == "1":
					emit_signal("right_received")
				if cmds[3] == "1":
					emit_signal("down_received")
				if cmds[4] == "1":
					emit_signal("fire_received")
						
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var pkt = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [pkt.get_string_from_utf8()])
		# Reply so it knows we received the message.
		peer.put_packet("OK".to_utf8_buffer())
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)
		var stringArray = peer.get_packet_ip().split(':')
		var ipSplitted = stringArray[0].split('.')
		
		emit_signal("new_player_connected",ipSplitted[3])



		
