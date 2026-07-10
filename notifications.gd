extends VBoxContainer

@onready var message: PackedScene = preload("res://message.tscn")

@rpc("any_peer", "call_local")
func send_text(txt: String):
	var msg = message.instantiate()
	msg.get_child(0).text = txt
	add_child(msg)
