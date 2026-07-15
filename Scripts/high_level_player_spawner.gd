extends MultiplayerSpawner

@export var network_player: PackedScene

func _ready() -> void:
	multiplayer.peer_disconnected.connect(del_player)
	multiplayer.connected_to_server.connect(server_connected)
	multiplayer.server_disconnected.connect(server_disconnect)
	
	#multiplayer.peer_connected.connect(spawn_player)
	#print(multiplayer.get_unique_id(), "         ", multiplayer.is_server(), "      ", multiplayer.multiplayer_peer)
	
	if !multiplayer.is_server():
		await get_tree().create_timer(0.5).timeout
		rpc_id(1, "spawn_player", multiplayer.get_unique_id())
	#multiplayer.connection_failed.connect(on_disconnect)

@rpc("any_peer", "call_local", "reliable")
func spawn_player(id: int):
	if !multiplayer.is_server(): return
	
	var player: Node = network_player.instantiate()
	player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child", player)


func _on_spawned(node: Node) -> void:
	if node.is_in_group("Player"):
		MultiplayerManager.add_player()

func del_player(id):
	if multiplayer.is_server():
		MultiplayerManager.remove_player(id)
	var player = get_node_or_null(str(id))
	if(player):
		player.queue_free()

func server_disconnect():
	get_tree().auto_accept_quit = true
	get_tree().reload_current_scene()
func server_connected():
	get_tree().auto_accept_quit = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if !multiplayer.has_multiplayer_peer():
			get_tree().quit()
		if not multiplayer.is_server():
			rpc_id(1, "do_disconnect", multiplayer.get_unique_id())
			#multiplayer.multiplayer_peer.disconnect_peer(1)
			await multiplayer.peer_disconnected
			get_tree().quit()
		else:
			get_tree().quit()

@rpc("any_peer", "reliable")
func do_disconnect(id):
	var node_path = "/root/Main/" + str(id)
	get_node(node_path).queue_free()
	
	multiplayer.multiplayer_peer.disconnect_peer(id)
	#multiplayer.disconnect_peer(id)
	#print(multiplayer.get_unique_id(), "   ", id)
