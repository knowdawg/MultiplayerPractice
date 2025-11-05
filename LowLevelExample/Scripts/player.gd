extends CharacterBody2D
class_name Player

var acelleration : float = 2000.0
var friction : float = 400.0
var maxSpeed : Vector2 = Vector2(600.0, 600.0)

var isAuthority : bool:
	get: return !NetworkHandler.isServer and ownerId == ClientNetworkGlobals.id

var ownerId : int


func _enter_tree() -> void:
	ServerNetworkGlobals.handlePlayerData.connect(serverHandlePlayerData)
	ClientNetworkGlobals.handlePlayerData.connect(clientHandlePlayerData)

func _exit_tree() -> void:
	ServerNetworkGlobals.handlePlayerData.disconnect(serverHandlePlayerData)
	ClientNetworkGlobals.handlePlayerData.disconnect(clientHandlePlayerData)

func _physics_process(delta: float) -> void:
	if !isAuthority: return
	
	var xInput = Input.get_axis("MoveLeft", "MoveRight")
	var yInput = Input.get_axis("MoveUp", "MoveDown")
	
	velocity += Vector2(xInput, yInput) * acelleration * delta
	
	#if abs(xInput) < 0.01:
		#velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	#if abs(yInput) < 0.01:
		#velocity.y = move_toward(velocity.y, 0.0, friction * delta)
	
	velocity = velocity.clamp(-maxSpeed, maxSpeed)
	
	var collisiondata = move_and_collide(velocity * delta)
	if collisiondata:
		velocity = velocity.bounce(collisiondata.get_normal())
	
	
	PlayerDataPacket.create(ownerId, global_position).send(NetworkHandler.serverPeer)


func serverHandlePlayerData(peerId : int, packet : PlayerDataPacket) -> void:
	if ownerId != peerId: return #only modify the position of the player thats sending the data
	
	global_position = packet.position #update the player position on the server
	
	PlayerDataPacket.create(ownerId, packet.position).broadcast(NetworkHandler.connection) #Broadcast the new player position to all the other players

func clientHandlePlayerData(packet : PlayerDataPacket) -> void:
	if isAuthority or ownerId != packet.id: return #only update the corect player and never update me
	
	global_position = packet.position
