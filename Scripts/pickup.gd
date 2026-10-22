extends Area2D

func _ready():
	if multiplayer.is_server():
		hide()
		set_random_position()

func set_random_position():
	var main = get_node("/root/Main")
	global_position = Vector2(randi_range(-main.bounds.x, main.bounds.x), randi_range(-main.bounds.y, main.bounds.y))
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	if get_overlapping_bodies().size() != 0: 
		set_random_position()
	else:
		show()

func _on_body_entered(body):
	if multiplayer.is_server():
		if body.is_in_group("Player"):
			if body.remaining_bullets < body.max_bullets:
				body.remaining_bullets += 1
				body.rpc_id(int(body.name), "add_bullet", 1)
				queue_free()
