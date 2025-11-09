extends CharacterBody2D
class_name Player

@export var jumpHeight : float = 20.0
@export var jumpDistance : float = 25.0
@export var maxMoveSpeed : float = 70.0

var jumpForce : float:
	get: return (-2.0 * jumpHeight) / timeInAir
var g : float:
	get: return (2.0 * jumpHeight) / pow(timeInAir, 2.0)
var timeInAir : float:
	get: return jumpDistance / maxMoveSpeed

var isAuthority : bool:
	get: return !NetworkHandler.isServer and ownerId == ClientNetworkGlobals.id

var ownerId : int


func _enter_tree() -> void:
	ServerNetworkGlobals.handlePlayerData.connect(serverHandlePlayerData)
	ClientNetworkGlobals.handlePlayerData.connect(clientHandlePlayerData)

func _exit_tree() -> void:
	ServerNetworkGlobals.handlePlayerData.disconnect(serverHandlePlayerData)
	ClientNetworkGlobals.handlePlayerData.disconnect(clientHandlePlayerData)

var walkVelocity := Vector2.ZERO
var jumpVelocity := Vector2.ZERO
func _physics_process(delta: float) -> void:
	if !isAuthority:
		move_and_slide() #maybe only move and slide if your a client?
		return
	
	var xInput = Input.get_axis("MoveLeft", "MoveRight")
	var yInput = Input.get_axis("MoveUp", "MoveDown")
	
	
	walkVelocity.x = xInput * maxMoveSpeed * delta * 60.0
	
	jumpVelocity.y += delta * g
	if is_on_floor() and jumpVelocity.y > 0.0:
		jumpVelocity.y = 0.0
	
	velocity = walkVelocity + jumpVelocity
	
	move_and_slide()
	
	
	
	PlayerDataPacket.create(ownerId,
	global_position,
	velocity,
	$AnimationMapperComponent.getCurrentAnimationIndex(),
	$AnimationMapperComponent.getCurrentAnimationTimeStamp()
	).send(NetworkHandler.serverPeer)

func jump():
	jumpVelocity.y = jumpForce

func align():
	if velocity.x > 0.0:
		$Sprite.flip_h = false
	if velocity.x < 0.0:
		$Sprite.flip_h = true

func serverHandlePlayerData(peerId : int, packet : PlayerDataPacket) -> void:
	if ownerId != peerId: return #only modify the position of the player thats sending the data
	
	global_position = packet.position #update the player position on the server
	velocity = packet.velocity
	$AnimationMapperComponent.updateAnimator(packet.animationIndex, packet.animationTimeStamp)
	
	PlayerDataPacket.create(ownerId,
	packet.position,
	packet.velocity,
	packet.animationIndex,
	packet.animationTimeStamp).broadcast(NetworkHandler.connection) #Broadcast the new player position to all the other players

func clientHandlePlayerData(packet : PlayerDataPacket) -> void:
	if isAuthority or ownerId != packet.id: return #only update the corect player and never update me
	
	global_position = packet.position
	velocity = packet.velocity
	$AnimationMapperComponent.updateAnimator(packet.animationIndex, packet.animationTimeStamp)
