extends Node

var player_amount = 0
var kills = 0
var round_won: bool = false

@export var colors: Array[Color]
@export var placeholder_names: Array[String]
var username: String
var chatting: bool
var player_data: Dictionary

func add_player():
	player_amount += 1

@rpc("any_peer", "reliable")
func remove_player(id: int):
	#player_data.erase(str(id))
	player_amount -= 1
	get_node("/root/Main/Ui").rpc("send_text", player_data.get(str(id)).name + " Disconnected", "[SERVER]")
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
		"color": p_color.to_html(false)
	}
	get_node("/root/Main/Ui").rpc("send_text", "[color=#" + p_color.to_html(false) + "]" + p_name + "[/color] Joined", "[SERVER]")

@rpc("authority", "reliable")
func add_score(bullet_id: String, hitplayer_id: String):
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
				get_node("/root/Main/Ui/Notifications").rpc("send_text","[color=#" + str(player_data.get(p.name).color) + "]" + player_data.get(p.name).name + "[/color] Won the round")
				
				var ids: Array[String]
				for pl in players: ids.append(pl.name)
				var names: Array[String]
				for pl in players: names.append(player_data.get(pl.name).name)
				var scores: Array[int]
				for pl in players: scores.append(player_data.get(pl.name).score)
				rpc("spawn_popup", names, scores, ids, p.name, player_data.get(p.name).color)
		
		await get_tree().create_timer(3).timeout
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
