extends RigidBody2D

var spawner: String

func _ready() -> void:
	$hit.play()
	if multiplayer.is_server():
		$Timer.start()
		freeze = false

func kill():
	$MultiplayerSynchronizer.public_visibility = false
	queue_free()

func _on_body_entered(body: Node) -> void:
	if multiplayer.is_server():
		if body.is_in_group("Player") && !MultiplayerManager.round_won:
			var target = MultiplayerManager.player_data.get(body.name).name
			if target != null:
				var node_path = "/root/Main/" + body.name
				
				#if MultiplayerManager.player_amount > 2:
				body.dead = true
				rpc_id(1, "send_score", spawner, body.name)
				get_node(node_path).rpc_id(int(body.name), "die")
				queue_free()
		else:
			$hit.pitch_scale = 2
			$hit.play()

@rpc("any_peer", "call_local", "reliable")
func send_score(bullet_id: String, hitplayer_id: String):
	MultiplayerManager.add_score(bullet_id, hitplayer_id)
