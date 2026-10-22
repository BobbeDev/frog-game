extends Node2D

@export_enum("Lobby", "Map") var map_type: int = 1
@export var bullets_do_damage: bool = true
@export var bounds:  Vector2i = Vector2i(3, 3) ##bounds in pixels

func _ready() -> void:
	if multiplayer.is_server():
		MultiplayerManager.round_won = !bullets_do_damage
