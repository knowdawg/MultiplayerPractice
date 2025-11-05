extends PacketInfo
class_name PlayerDataPacket

var id : int
var position : Vector2

static func create(packetId : int, packetPosition : Vector2) -> PlayerDataPacket:
	var info : PlayerDataPacket = PlayerDataPacket.new()
	info.packetType = PACKET_TYPE.PLAYER_DATA
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = packetId
	info.position = packetPosition
	
	return info

static func createFromData(data : PackedByteArray) -> PlayerDataPacket:
	var info : PlayerDataPacket = PlayerDataPacket.new()
	info.decode(data)
	return info
	

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(10) # 1 for Packet Type, 1 for ID, 4x2 for Position
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	
	return data

func decode(data : PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector2(data.decode_float(2), data.decode_float(6))
