extends Node

const PLAYER_SCENE = preload("res://LowLevelExample/Scenes/player.tscn")


func _ready() -> void:
	#Spawn a player whenever I conecet and whenever someone else conects and for all players already on the server
	NetworkHandler.onPeerConected.connect(spawnPlayer)
	ClientNetworkGlobals.handleLocalIdAssignment.connect(spawnPlayer)
	ClientNetworkGlobals.handleRemoteIdAssignment.connect(spawnPlayer)

func spawnPlayer(id : int) -> void:
	var player : Player = PLAYER_SCENE.instantiate()
	player.ownerId = id
	player.name = str(id) #optional
	
	call_deferred("add_child", player)
