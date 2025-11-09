extends PacketInfo
class_name PlayerDataPacket

var id : int
var position : Vector2
var velocity : Vector2

var animationIndex : int
var animationTimeStamp : float

static func create(packetId : int, packetPosition : Vector2, packetVelocity : Vector2, packetAnimIndex : int = -1, packetAnimTimeStamp : float = 0.0) -> PlayerDataPacket:
	var info : PlayerDataPacket = PlayerDataPacket.new()
	info.packetType = PACKET_TYPE.PLAYER_DATA
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = packetId
	info.position = packetPosition
	info.velocity = packetVelocity
	info.animationIndex = packetAnimIndex
	info.animationTimeStamp = packetAnimTimeStamp
	
	return info

static func createFromData(data : PackedByteArray) -> PlayerDataPacket:
	var info : PlayerDataPacket = PlayerDataPacket.new()
	info.decode(data)
	return info
	

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(23) # 1 for Packet Type, 1 for ID, 4x2 for Position, 4x2 for velocity, 1 for animationIndex, 4 for animationTimeStamp
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, velocity.x)
	data.encode_float(14, velocity.y)
	data.encode_u8(18, animationIndex)
	data.encode_float(19, animationTimeStamp)
	
	
	
	return data

func decode(data : PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector2(data.decode_float(2), data.decode_float(6))
	velocity = Vector2(data.decode_float(10), data.decode_float(14))
	animationIndex = data.decode_u8(18)
	animationTimeStamp = data.decode_float(19)
