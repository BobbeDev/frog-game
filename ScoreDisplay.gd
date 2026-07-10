extends BoxContainer

@onready var score_box: PackedScene = preload("res://score_box.tscn")

var boxes: Array[Control]
var winner_index: int

func load_data(names: Array[String], scores: Array[int], ids: Array[String], winner_id: String, color: Color):
	for box in boxes: box.queue_free()
	boxes.clear()
	
	for p in names.size():
		var sb = score_box.instantiate()
		sb.get_child(0).get_child(0).text = str(scores[p])
		sb.get_child(0).get_child(1).text = names[p]
		if winner_id == ids[p]:
			sb.modulate = color
			sb.get_child(0).get_child(0).text = str(int(sb.get_child(0).get_child(0).text) - 1)
			winner_index = p
		if p > 3:
			$Row1.add_child(sb)
		else:
			$Row2.add_child(sb)
		boxes.append(sb)
	show()
	await get_tree().create_timer(1).timeout
	boxes[winner_index].get_child(0).get_child(0).text = str(int(boxes[winner_index].get_child(0).get_child(0).text) + 1)
	await get_tree().create_timer(2).timeout
	hide()
