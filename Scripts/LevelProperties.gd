extends Node2D

@export var bullets_do_damage: bool = true

func _ready() -> void:
	if multiplayer.is_server():
		MultiplayerManager.round_won = !bullets_do_damage
