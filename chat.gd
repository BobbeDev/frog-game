extends CanvasLayer

const MESSAGE_TIME: float = 3

@rpc("any_peer", "call_local")
func _on_line_edit_text_submitted(new_text: String) -> void:
	$TextEdit/LineEdit.clear()
	rpc("send_text", new_text, MultiplayerManager.username)

@rpc("any_peer", "call_local")
func send_text(txt: String, username: String):
	$TextEdit.text += username + ": " + txt + "\n"
	$TextEdit.scroll_vertical = INF
	$TextEdit.show()
	
	$TextEdit/Timer.wait_time = MESSAGE_TIME
	$TextEdit/Timer.stop()
	$TextEdit/Timer.start()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Chat") && MultiplayerManager.player_amount != 0:
		if MultiplayerManager.chatting:
			$TextEdit/LineEdit.focus_mode = 0
			MultiplayerManager.chatting = false
		else:
			$TextEdit.show()
			$TextEdit/LineEdit.focus_mode = 2
			$TextEdit/LineEdit.grab_focus()
			MultiplayerManager.chatting = true
	if Input.is_action_just_pressed("Esc"):
		if MultiplayerManager.chatting:
			$TextEdit.hide()
			$TextEdit/LineEdit.clear()


func _on_timer_timeout() -> void:
	if !MultiplayerManager.chatting:
		$TextEdit.hide()
