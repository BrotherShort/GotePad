extends PopupMenu

var _about_window: Window :
	get: return %AboutWindow

func _ready():
	id_pressed.connect(_id_pressed)


func _id_pressed(id: int) -> void:
	match id:
		0: # 关于
			_about_window.show()
