extends Node

signal handleLocalIdAssignment(localId : int)
signal handleRemoteIdAssignment(remotreId : int)
signal handlePlayerData(packet : PlayerDataPacket)

var id : int = -1
var remoteIds : Array[int]

func _ready() -> void:
	NetworkHandler.onClientPacket.connect(onClientPacket)


func onClientPacket(data : PackedByteArray) -> void:
	var packetDataType : int = data.decode_u8(0)
	
	match packetDataType:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			manageIds(IdAssignmentPacket.createFromData(data))
			
		PacketInfo.PACKET_TYPE.PLAYER_DATA:
			handlePlayerData.emit(PlayerDataPacket.createFromData(data))
			
		_:
			push_error("Packet Type with index: ", packetDataType, " unhandled!")
			return

func manageIds(packet : IdAssignmentPacket):
	if id == -1:
		id = packet.id
		handleLocalIdAssignment.emit(packet.id)
		
		remoteIds = packet.remoteIds
		for remId in remoteIds:
			if remId == id: continue
			handleRemoteIdAssignment.emit(remId)
	
	else:
		remoteIds.append(packet.id)
		handleRemoteIdAssignment.emit(packet.id)
	
