extends Control

## 软件名称
## Application name
var _name: String = ""

## 上一个窗口标题
## Last window title
var _last_title: String = ""

@onready var _gote_edit: GoteEdit = $%GoteEdit

func _ready():
	_name = ProjectSettings.get_setting("application/config/name") as String
	_gote_edit.use_native_dialog = true
	get_tree().set_auto_accept_quit(false)


func _process(_delta: float):
	var title: String = _gote_edit.formatted_title(_name)
	if title != _last_title:
		DisplayServer.window_set_title(title)
		_last_title = title


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_gote_edit.close_check()
