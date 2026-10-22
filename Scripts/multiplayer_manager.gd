extends Node

var game_active: bool = false
var player_amount = 0
var kills = 0
var round_won: bool = false
var game_mode: int = 0
var game_map: int = 0
var game_rounds: int = 5

@export var colors: Array[Color]
@export var placeholder_names: Array[String]
@export var map_scenes: Array[String]
@onready var bullet_pickup: PackedScene = preload("res://SceneObjects/bullet_pickup.tscn")
var username: String
var chatting: bool
var player_data: Dictionary

func add_player():
	player_amount += 1

@rpc("any_peer", "reliable")
func remove_player(id: int):
	#player_data.erase(str(id))
	player_amount -= 1
	rpc("update_player_count", player_amount)
	get_node("/root/Main/Ui").rpc("send_text", player_data.get(str(id)).name + " Disconnected", "[SERVER]")

@rpc("authority", "reliable")
func update_player_count(pam: int):
	if !multiplayer.is_server():
		player_amount = pam

func get_color() -> Color:
	return colors[player_amount]
func get_default_name() -> String:
	return placeholder_names[player_amount]

@rpc("authority", "reliable")
func add_data(p_id: String, p_name: String, p_color: Color):
	player_amount += 1
	player_data[p_id] = {
		"name": p_name,
		"score": 0,
		"color": p_color.to_html(false),
		"ready": false
	}
	get_node("/root/Main/Ui").rpc("send_text", "[color=#" + p_color.to_html(false) + "]" + p_name + "[/color] Joined", "[SERVER]")

@rpc("authority", "reliable")
func add_score(bullet_id: String, hitplayer_id: String):
	var winner_id: String = ""
	kills += 1
	if bullet_id != hitplayer_id:
		get_node("/root/Main/Ui/Notifications").rpc("send_text","[color=#" + str(player_data.get(bullet_id).color) + "]" + player_data.get(bullet_id).name + "[/color] Blasted " + "[color=#" + str(player_data.get(hitplayer_id).color) + "]" + player_data.get(hitplayer_id).name + "[/color]")
	else:
		get_node("/root/Main/Ui/Notifications").rpc("send_text","[color=#" + str(player_data.get(bullet_id).color) + "]" + player_data.get(bullet_id).name + "[/color] Became their own victim")
	if kills >= player_amount - 1:
		round_won = true
		
		var players = get_tree().get_nodes_in_group("Player")
		for p in players:
			if !p.dead:
				player_data[p.name].score += 1
				if player_data[p.name].score >= game_rounds:
					winner_id = p.name
				get_node("/root/Main/Ui/Notifications").rpc("send_text","[color=#" + str(player_data.get(p.name).color) + "]" + player_data.get(p.name).name + "[/color] Won the round")
				
				var ids: Array[String]
				for pl in players: ids.append(pl.name)
				var names: Array[String]
				for pl in players: names.append(player_data.get(pl.name).name)
				var scores: Array[int]
				for pl in players: scores.append(player_data.get(pl.name).score)
				rpc("spawn_popup", names, scores, ids, p.name, player_data.get(p.name).color)
		
		await get_tree().create_timer(3).timeout
		if winner_id != "":
			for id in multiplayer.get_peers():
				player_data[str(id)].score = 0
			game_active = false
			rpc("change_scene", "res://Scenes/Lobby.tscn")
			return
		kills = 0
		round_won = false
		
		var bullets = get_tree().get_nodes_in_group("Bullet")
		for b in bullets:
			b.queue_free()
		for p in players:
			p.rpc("respawn")
		

@rpc("authority", "reliable")
func spawn_popup(names, scores, ids, winner, color):
	get_node("/root/Main/Ui/Scores").load_data(names, scores, ids, winner, color)

@rpc("authority", "call_local", "reliable")
func change_scene(scene):
	kills = 0
	player_amount = 0
	if multiplayer.is_server():
		var players = get_tree().get_nodes_in_group("Player")
		for p in players:
			#print(p.name)
			#pass
			#p.get_node("MultiplayerSynchronizer").public_visibility = false
			p.queue_free()
		print("------")
	else:
		await get_tree().create_timer(1).timeout
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(scene)

@rpc("any_peer", "reliable")
func ready_up(is_ready: bool, id: String):
	player_data[id].ready = is_ready
	
	var all_ready = true
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() < 2: return
	for p in players:
		print(player_data.get(p.name).name, "  ", player_data.get(p.name).ready)
		if player_data.get(p.name).ready == false:
			all_ready = false
	print("---------------------------------------")
	
	if all_ready == true:
		game_active = true
		#await get_tree().create_timer(1).timeout
		rpc("change_scene", map_scenes[game_map])

func bullet_fired():
	if !game_active: return
	match game_mode:
		3: #limited bullets mode
			var pickup = bullet_pickup.instantiate()
			get_node("/root/Main").add_child(pickup, true)

func _process(_delta: float) -> void:
	if multiplayer.is_server():
		var textgen: String = ""
		for id in multiplayer.get_peers():
			if player_data.has(str(id)):
				textgen += str(player_data.get(str(id)).name) + "   " + str(player_data.get(str(id)).score) + "   " + str(player_data.get(str(id)).color) + "   " + str(player_data.get(str(id)).ready) + "\n"
		$Server/Label2.text = textgen

func change_mode(new_mode: int):
	game_mode = new_mode

func change_map(new_map: int):
	game_map = new_map

func change_rounds(new_round_count: float):
	game_rounds = int(new_round_count)
