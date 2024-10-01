extends PanelContainer
class_name RoomMenu

@onready var room_name_label : Label = $HBoxContainer/VBoxRoomSettings/PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxInfo/HBoxInfoName/ScrollContainer/Label2
@onready var password_label : Label = $HBoxContainer/VBoxRoomSettings/PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxInfo/HBoxInfoPassword/ScrollContainer/Label2
@onready var ip_label : Label = $HBoxContainer/VBoxRoomSettings/PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxInfo/HBoxInfoIP/ScrollContainer/Label2
@onready var port_label : Label = $HBoxContainer/VBoxRoomSettings/PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxInfo/HBoxInfoPort/ScrollContainer/Label2

@onready var player_list : VBoxContainer = $HBoxContainer/VBoxContainer/PanelContainerPlayerList/VBoxPlayerList


@export var room_info : RoomInfo = RoomInfo.new() :
	set(new_info) :
		room_name_label.text = new_info.name if new_info.name else room_info.name
		password_label.text = "*".repeat(room_info.password.length()) if room_info.password else "None"
		ip_label.text = new_info.ip
		port_label.text = str(new_info.port)
		room_info = new_info

@export var game_settings : GameSettings = GameSettings.DEFAULT_SETTINGS :
	set(new_settings) :
		game_settings = new_settings

@onready var vbox_room_settings : VBoxContainer = $HBoxContainer/VBoxRoomSettings

func _ready() -> void:
	password_label.get_parent_control().mouse_entered.connect(func(): password_label.text = room_info.password if room_info.password else "None")
	password_label.get_parent_control().mouse_exited.connect(func(): password_label.text = "*".repeat(room_info.password.length()) if room_info.password else "None")

#func add_player_span(player_span : PlayerSpan) -> void :
	#player_list.add_child(player_span)

class RoomInfo extends Resource :
	var name : String = "Arcane Room"
	var ip : String = "127.0.0.1"
	var port : int = 8999
	var password : String = ""
	
	func _to_string() -> String:
		return "({name} at {ip}, {port}, #{psw})".format({
				"name" : name,
				"ip" : ip,
				"port" : port,
				"psw" : password
			})
