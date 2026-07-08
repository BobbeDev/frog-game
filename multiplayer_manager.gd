extends Node

var player_amount = 0
var kills = 0
var round_won: bool = false

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
	get_node("/root/Main/Ui").rpc("send_text", player_data.get(str(id)).name + " Disconnected", "[SERVER]")
func get_color() -> Color:
	return colors[player_amount]

@rpc("authority", "reliable")
func add_data(p_id: String, p_name: String, p_color: Color):
	player_amount += 1
	player_data[p_id] = {
		"name": p_name,
		"score": 0,
		"color": p_color.to_html(false)
	}
	get_node("/root/Main/Ui").rpc("send_text", "[color=#" + p_color.to_html(false) + "]" + p_name + "[/color] Joined", "[SERVER]")

@rpc("authority", "reliable")
func add_score(bullet_id: String, hitplayer_id: String):
	kills += 1
	if bullet_id != hitplayer_id:
		print("POINTS TO ", player_data.get(bullet_id).name)
		get_node("/root/Main/Ui").rpc("send_text","[color=#" + str(player_data.get(bullet_id).color) + "]" + player_data.get(bullet_id).name + "[/color] Blasted " + "[color=#" + str(player_data.get(hitplayer_id).color) + "]" + player_data.get(hitplayer_id).name + "[/color]", "[SERVER]")
	if kills >= player_amount - 1:
		round_won = true
		
		var players = get_tree().get_nodes_in_group("Player")
		for p in players:
			if !p.dead:
				player_data[p.name].score += 1
				get_node("/root/Main/Ui").rpc("send_text","[color=#" + str(player_data.get(p.name).color) + "]" + player_data.get(p.name).name + "[/color] Won the round", "[SERVER]")
				rpc("spawn_popup", player_data.get(p.name).name + " WINS", str(player_data[p.name].score) + " Points", p.player_color)
		
		await get_tree().create_timer(2).timeout
		kills = 0
		round_won = false
		
		var bullets = get_tree().get_nodes_in_group("Bullet")
		for b in bullets:
			b.queue_free()
		for p in players:
			p.rpc("respawn")

@rpc("authority", "reliable")
func spawn_popup(win_name, win_score, win_color):
	var spawn = score_popup.instantiate()
	spawn.modulate = win_color
	spawn.text = win_name
	spawn.get_child(0).text = str(win_score)
	get_node("/root/Main/Ui").add_child(spawn)
	spawn.position = Vector2(153.5, 100)
