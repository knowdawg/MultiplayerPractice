extends Node

signal handlePlayerData(peerId : int, packet : PlayerDataPacket)

var peerIds : Array[int]

func _ready() -> void:
	NetworkHandler.onPeerConected.connect(onPeerConected)
	NetworkHandler.onPeerDisconected.connect(onPeerDisconected)
	NetworkHandler.onServerPacket.connect(onServerPacket)
	

func onPeerConected(peerId : int):
	peerIds.append(peerId)
	
	IdAssignmentPacket.create(peerId, peerIds).broadcast(NetworkHandler.connection)

func onPeerDisconected(peerId : int):
	peerIds.erase(peerId)
	
	#Create a packet for unassinging peer ids


func onServerPacket(peerId : int, data : PackedByteArray):
	var packetDataType : int = data.decode_u8(0)
	
	match packetDataType:
		PacketInfo.PACKET_TYPE.PLAYER_DATA:
			handlePlayerData.emit(peerId, PlayerDataPacket.createFromData(data))
			
		_:
			push_error("Packet Type with index: ", packetDataType, " unhandled!")
			return
