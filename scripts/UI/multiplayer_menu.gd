extends Control
class_name MultiplayerMenu

@onready var tabcont_base : TabContainer = $TabContainer
@onready var tabcont_join_host : TabContainer = $TabContainer/TabContainerJoinHost

@onready var host_panel : PanelContainer = $"TabContainer/TabContainerJoinHost/Host A Room"
@onready var join_panel : VBoxContainer = $"TabContainer/TabContainerJoinHost/Join A Room"
@onready var room_menu : RoomMenu = $TabContainer/RoomMenu

var peer := ENetMultiplayerPeer.new()

var player_span_array : Array[PlayerSpan] = []

func _ready() -> void:
	multiplayer.allow_object_decoding = true
	host_panel.create_room.connect(_on_host_pressed)
	join_panel.join_room.connect(_on_join_pressed)


func _on_host_pressed(room_name:String, password:String, port:int) -> void:
	var room_info := RoomMenu.RoomInfo.new()
	room_info.name = room_name
	room_info.password = password
	room_info.ip = NetworkUtils.get_local_ip()
	room_info.port = port
	print("Creating room with RoomInfo=",room_info._to_string())
	
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)

	room_menu.room_info = room_info
	room_menu.vbox_room_settings.set_multiplayer_authority(1,true)
	tabcont_base.current_tab = 1
	var player_span : PlayerSpan = PlayerSpan.DEFAULT_SPAN_SCENE.instantiate()
	room_menu.player_list.add_child(player_span)
	player_span_array.append(player_span)
	player_span.set_multiplayer_authority(1,true)
	player_span.player_info.host = true
	player_span.player_info.deck = Deck.DEFAULT_DECK
	player_span.player_info.player_name = "Hostman"
	player_span.player_info.player_title = "The Dev"
	print("Server created.")

func _on_join_pressed(ip:String,port:int) -> void :
	print("Connecting to server")
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	
	tabcont_base.current_tab = 1

func on_peer_connected(id : int) -> void :
	print("("+str(multiplayer.get_unique_id())+") Peer Connected ! Name's ",id)
	var player_span : PlayerSpan = PlayerSpan.DEFAULT_SPAN_SCENE.instantiate()
	room_menu.player_list.add_child(player_span)
	player_span_array.append(player_span)
	player_span.set_multiplayer_authority(id,true)
	player_span.player_info.host = false
	player_span.player_info.deck = Deck.DEFAULT_DECK
	player_span.player_info.player_name = "Player"
	player_span.player_info.player_title = "Apprentice"

func on_peer_disconnected() -> void:
	print("("+str(multiplayer.get_unique_id())+") Peer disconnected!")

func on_connected_to_server() -> void:
	print("("+str(multiplayer.get_unique_id())+") Connected to server!")
	ask_room_info.rpc_id(1)

func on_connection_failed() -> void:
	print("("+str(multiplayer.get_unique_id())+") Connection failed!")

func on_server_disconnected() -> void:
	print_debug("("+str(multiplayer.get_unique_id())+") Server disconnected!")

## Used by clients to ask the server to send them the room's information.
@rpc("any_peer", "reliable")
func ask_room_info() -> void:
	if multiplayer.is_server():
		var asker := multiplayer.get_remote_sender_id()
		give_room_info.bind(room_menu.room_info.to_dict()).rpc_id(asker)

## Used by the server to answer a client's [method ask_room_info]'s demand.
@rpc("authority", "reliable")
func give_room_info(info:Dictionary) -> void:
	print_debug("("+str(multiplayer.get_unique_id())+") Server sent info : ", info)
	room_menu.room_info = RoomMenu.RoomInfo.from_dict(info)

## Used by clients to send player info to everyone else.
@rpc("any_peer", "call_remote", "reliable")
func give_player_info(info:Dictionary) -> Error :
	# TO ALL CLIENTS
	# HERE IS A PLAYER'S INFODICT, CREATE A SPAN
	print_debug("("+str(multiplayer.get_unique_id())+") Client sent playerinfo : ", info)
	return OK
