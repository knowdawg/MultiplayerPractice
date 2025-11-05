extends PacketInfo
class_name IdAssignmentPacket

var id : int
var remoteIds : Array[int]

static func create(packetId : int, packetRemoteIds : Array[int]) -> IdAssignmentPacket:
	var info : IdAssignmentPacket = IdAssignmentPacket.new()
	info.packetType = PACKET_TYPE.ID_ASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = packetId
	info.remoteIds = packetRemoteIds
	
	return info

static func createFromData(data : PackedByteArray) -> IdAssignmentPacket:
	var info : IdAssignmentPacket = IdAssignmentPacket.new()
	info.decode(data)
	return info
	

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(2 + remoteIds.size())
	data.encode_u8(1, id)
	for i in remoteIds.size():
		data.encode_u8(2 + i, remoteIds[i])
	return data

func decode(data : PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	for i in range(2, data.size()):
		remoteIds.append(data.decode_u8(i))
	
