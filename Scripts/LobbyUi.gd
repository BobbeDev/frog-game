extends Control

func _ready() -> void:
	if multiplayer.is_server():
		hide()

func _process(_delta: float) -> void:
	$PlayerCount.text = str(MultiplayerManager.player_amount) + " / 8 Players"

func ready_up_toggled(toggled_on: bool) -> void:
	MultiplayerManager.rpc_id(1, "ready_up", toggled_on, str(multiplayer.get_unique_id()))
	if toggled_on:
		$Button.modulate = Color.GREEN
	else:
		$Button.modulate = Color.RED
