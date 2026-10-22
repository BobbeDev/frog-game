extends CanvasLayer

func _ready() -> void:
	$version.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	@warning_ignore("integer_division")
	get_window().size = Vector2(1156/2, 648/2)

func _on_server_pressed() -> void:
	HighLevelNetworkHandler.start_server($kids/IP.text, int($kids/Port.text))
	$kids.hide()
	$Server.show()
	AudioServer.set_bus_mute(0, true)
	get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")

func _on_client_pressed() -> void:
	HighLevelNetworkHandler.start_client($kids/IP.text, int($kids/Port.text))
	$kids.hide()
	MultiplayerManager.username = $kids/Username.text
	get_tree().change_scene_to_file("res://Scenes/Lobby.tscn")

func _process(_delta: float) -> void:
	if multiplayer.is_server():
		#print(MultiplayerManager.player_data.size())
		$Server/player_count.text = "player count: " + str(MultiplayerManager.player_amount)
