class_name TimedMessage

extends Label

var now : float = 0.0
var till : float = 0.0

func message(text_to : String, time : float):
	text = text_to
	till = time
	now = 0.0
	visible = true

func _process(delta):
	if visible:
		if till != -1.0:
			now += delta
			if now >= till:
				visible = false
