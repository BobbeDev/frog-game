extends CharacterBody2D

@export var speed: float = 10
@export var bullet_scene: PackedScene
@export var player_color: Color

var dead = false
var gun_reloaded: bool = true

var using_controller: bool

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		$AudioListener2D.current = true
		$Camera2D.enabled = true
		#MultiplayerManager.count_players.rpc()
		player_color = MultiplayerManager.get_color()
		$Skin.modulate = player_color
		if MultiplayerManager.username == "": MultiplayerManager.username = MultiplayerManager.get_default_name()
		$Username.text = MultiplayerManager.username
		$Yelp.pitch_scale = randf_range(0.8, 1.2)
		#rpc_id(1, "MultiplayerManager.add_data", str(multiplayer.get_unique_id()), MultiplayerManager.username)
		#rpc("spawn_bullet", [name])
		rpc_id(1, "send_data", str(multiplayer.get_unique_id()), MultiplayerManager.username)
		respawn()

@rpc("any_peer", "reliable")
func send_data(p_id: String, p_name: String):
	MultiplayerManager.add_data(p_id, p_name, MultiplayerManager.get_color())

@rpc("authority","call_local", "reliable")
func spawn_bullet(pos: Vector2, vel: Vector2, id: String, col: Color):
	if gun_reloaded && !dead:
		rpc("shot_success", id)
		var bullet_obj = bullet_scene.instantiate()
		get_node("/root/Main").add_child(bullet_obj, true)
		bullet_obj.linear_velocity = vel
		bullet_obj.global_position = pos
		bullet_obj.spawner = id
		bullet_obj.get_child(0).modulate = col
		gun_reloaded = false
		$BulletTimer.start()

func _process(delta):
	if !is_multiplayer_authority(): return
	if MultiplayerManager.chatting: return

	var input: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var aim_input: Vector2 = Input.get_vector("AimLeft", "AimRight", "AimUp", "AimDown")
	if input == Vector2.ZERO:
		$Frog.play("Idle")
		$Skin.play("Idle")
	else:
		$Frog.play("Walk")
		$Skin.play("Walk")
	
	if Input.is_action_just_pressed("Bup"):
		rpc("ribbit")
	if $Yelp.playing:
		$Frog.play("Glup")
		$Skin.play("Glup")
	velocity = input * speed * 100 * delta
	move_and_slide()
	
	if using_controller:
		if aim_input != Vector2.ZERO:
			$GunHand.look_at(global_position + aim_input)
	else:
		$GunHand.look_at(get_global_mouse_position())
	if Input.is_action_pressed("Shoot"):
		#spawn_bullet(name)
		rpc_id(1, "spawn_bullet", $GunHand/Gun.global_position, $GunHand/Gun.global_transform.basis_xform(Vector2.RIGHT) * 3000, name, $Skin.modulate)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		using_controller = false
	if aim_input != Vector2.ZERO:
		using_controller = true

@rpc("any_peer", "call_local", "reliable")
func ribbit():
	#print("oughh the chef is here   ", name)
	$Yelp.play()

@rpc("any_peer", "call_local", "reliable")
func die():
	#put em in the loser box
	global_position = Vector2(2525, 96)#get_node("/root/Main/SpawnPositions").get_child(randi_range(0, 8)).global_position
	rpc("die_sound", name)

@rpc("any_peer", "call_local", "reliable")
func die_sound(id: String):
	if name == id:
		$Death.play()

@rpc("any_peer", "call_local", "reliable")
func shot_success(id: String):
	if name == id:
		$GunHand/Gun.play("Shoot")

@rpc("any_peer", "call_local", "reliable")
func respawn():
	dead = false
	#print("RESPAWNING ", multiplayer.get_unique_id(), "     ", name)
	global_position = get_node("/root/Main/SpawnPositions").get_child(randi_range(0, 8)).global_position + Vector2(randi_range(-50, 50), randi_range(-50, 50))

func _on_bullet_timer_timeout() -> void:
	gun_reloaded = true
