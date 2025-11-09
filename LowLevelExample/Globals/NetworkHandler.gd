extends Node

#Server Side Signals
signal onPeerConected(peerId : int)
signal onPeerDisconected(peerId : int)
signal onServerPacket(senderPeerId : int, packet : PackedByteArray)

#Client Side Signals
signal onConectedToServer()
signal onDisconectedToServer()
signal onClientPacket(packet : PackedByteArray)

#Server Side Variable
var availiblePeerIds : Array = range(255, -1, -1)
var clientPeers : Dictionary[int, ENetPacketPeer]

#Client Side Variables
var serverPeer : ENetPacketPeer

#General Varibales
var connection : ENetConnection
var isServer : bool = false

func _ready() -> void:
	DisplayServer.window_move_to_foreground()
	
	var args = OS.get_cmdline_args()
	var launchAsServer : bool = "--server" in args
	if launchAsServer:
		get_window().position = Vector2(0.0, 0.0)
		
		startServer()
	else:
		if "--window_bl" in args:
			get_window().position = Vector2(200.0, DisplayServer.screen_get_size().y - get_window().size.y - 200.0)
		if "--window_br" in args:
			get_window().position = Vector2(DisplayServer.screen_get_size().x - get_window().size.x - 200.0, DisplayServer.screen_get_size().y - get_window().size.y - 200.0)
		
		startClient()

func _process(_delta: float) -> void:
	if connection == null: return
	
	handleEvents()
	

func handleEvents() -> void:
	var packetEvent : Array = connection.service()
	var eventType : ENetConnection.EventType = packetEvent[0]
	
	while(eventType != ENetConnection.EVENT_NONE):
		var peer : ENetPacketPeer = packetEvent[1]
		
		match eventType:
			ENetConnection.EVENT_ERROR:
				push_warning("Package resulted in an unknown error...")
				return
				
			ENetConnection.EVENT_CONNECT:
				if isServer:
					peerConnected(peer)
				else:
					connectedToServer()
			
			ENetConnection.EVENT_DISCONNECT:
				if isServer:
					peerDisconnected(peer)
				else:
					disconnectedFromServer()
					return #return, conection is now null
			
			ENetConnection.EVENT_RECEIVE:
				if isServer:
					onServerPacket.emit(peer.get_meta("id"), peer.get_packet())
				else:
					onClientPacket.emit(peer.get_packet())
		
		#Handle any remaining packets in the current while loop
		packetEvent = connection.service()
		eventType = packetEvent[0]
		
		


#Server Functions
func peerDisconnected(peer : ENetPacketPeer) -> void:
	var peerId = peer.get_meta("id")
	availiblePeerIds.push_back(peerId)
	clientPeers.erase(peerId)
	
	print("Sucessfully Disconected: ", peerId, " From the Server!")
	onPeerDisconected.emit(peerId)

func peerConnected(peer : ENetPacketPeer) -> void:
	var peerId : int = availiblePeerIds.pop_back()
	peer.set_meta("id", peerId)
	clientPeers[peerId] = peer
	
	print("Peer conected with id: " + str(peerId))
	onPeerConected.emit(peerId)

func startServer(ipAdress : String = "127.0.0.1", port : int = 6767) -> void:
	connection = ENetConnection.new()
	var error : Error = connection.create_host_bound(ipAdress, port)
	if error:
		printerr("Server Failed to start: " + error_string(error))
		connection = null
		return
	isServer = true
	print("Server Started!")


#Client Functions
func disconnectedFromServer() -> void:
	print("Sucessfully Disconected From Server!")
	onDisconectedToServer.emit()
	connection = null

func connectedToServer() -> void:
	print("Peer Connected to Server!")
	onConectedToServer.emit()

func disconectClient() -> void:
	if isServer: return
	serverPeer.peer_disconnect()

func startClient(ipAdress : String = "127.0.0.1", port : int = 6767) -> void:
	connection = ENetConnection.new()
	var error : Error = connection.create_host(1)
	if error:
		printerr("Client Failed to start: " + error_string(error))
		connection = null
		return
	isServer = false
	serverPeer = connection.connect_to_host(ipAdress, port)
	print("Client Started")
