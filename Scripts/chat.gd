extends CanvasLayer

const MESSAGE_TIME: float = 3

@rpc("any_peer", "call_local")
func _on_line_edit_text_submitted(new_text: String) -> void:
	$TextEdit/LineEdit.clear()
	new_text = WipeBrackets(new_text)
	rpc("send_text", new_text, MultiplayerManager.username)

func WipeBrackets(Text):
	#removes the text effects from the text length yes yes
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var RetText = regex.sub(Text, "", true)
	return RetText

@rpc("any_peer", "call_local")
func send_text(txt: String, username: String):
	$TextEdit/RichTextLabel.text += username + ": " + txt + "\n"
	$TextEdit.show()
	#for i in 3:
	$TextEdit/RichTextLabel.scroll_to_line($TextEdit/RichTextLabel.get_line_count())
		#await get_tree().process_frame
	
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
			$TextEdit/LineEdit.focus_mode = 0
			MultiplayerManager.chatting = false


func _on_timer_timeout() -> void:
	if !MultiplayerManager.chatting:
		$TextEdit.hide()
