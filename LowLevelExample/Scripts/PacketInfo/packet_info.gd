###------BASE CLASS------###

class_name PacketInfo

enum PACKET_TYPE{ #A maximum of 256
	ID_ASSIGNMENT,
	PLAYER_DATA
}

var packetType : PACKET_TYPE
var flag : int

func encode() -> PackedByteArray:
	var data : PackedByteArray
	data.resize(1)
	data.encode_u8(0, packetType)
	
	return data

func decode(data : PackedByteArray) -> void:
	packetType = data.decode_u8(0) as PACKET_TYPE
	

#clients call send
func send(target : ENetPacketPeer) -> void:
	target.send(0, encode(), flag)

#Server Calls broadcast
func broadcast(server : ENetConnection) -> void:
	server.broadcast(0, encode(), flag)
