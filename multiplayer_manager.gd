extends Node

var player_amount = 0
var kills = 0

@export var colors: Array[Color]
var username: String
var chatting: bool
var player_data: Dictionary

@onready var score_popup: PackedScene = load("res://score_popup.tscn")

func add_player():
	player_amount += 1

@rpc("any_peer", "reliable")
func remove_player(id: int):
	#player_data.erase(str(id))
	player_amount -= 1
	print("REMOVING PLAYER   ", multiplayer.get_unique_id(), id)

func get_color() -> Color:
	return colors[player_amount]

@rpc("authority", "reliable")
func add_data(p_id: String, p_name: String):
	player_amount += 1
	player_data[p_id] = {
		"name": p_name,
		"score": 0
	}
	print(player_data, "         server: ", multiplayer.is_server())

@rpc("authority", "reliable")
func add_score(bullet_id: String, hitplayer_id: String):
	kills += 1
	if bullet_id != hitplayer_id:
		player_data[bullet_id].score += 1
		print("POINTS TO ", player_data.get(bullet_id).name)
		rpc("spawn_popup", player_data.get(bullet_id).name, player_data[bullet_id].score)
	if kills >= player_amount - 1:
		await get_tree().create_timer(2).timeout
		kills = 0
		var players = get_tree().get_nodes_in_group("Player")
		for p in players:
			p.rpc("respawn")
			#p.rpc_id(1, "respawn")
			#if multiplayer.is_server():
		
	#print(bullet_id, "   ", hitplayer_id)
	#player_data[p_id].score += 1
	#print("POINTS TO ", player_data.get(str(p_id)), "          ", p_id)

@rpc("authority", "reliable")
func spawn_popup(win_name, win_score):
	var spawn = score_popup.instantiate()
	spawn.text = win_name
	spawn.get_child(0).text = str(win_score)
	get_node("/root/Main/Ui").add_child(spawn)
	spawn.position = Vector2(153.5, 100)
