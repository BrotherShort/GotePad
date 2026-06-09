extends Control

## 软件名称
var _name: String = ""

## 上一个窗口标题
var _last_title: String = ""

@onready var _gote_edit: GoteEdit = $"%GoteEdit"

func _ready():
	_name = ProjectSettings.get_setting("application/config/name") as String
	_gote_edit.use_native_dialog = true


func _process(_delta: float):
	var title: String = ""
	var file_path = _gote_edit.file_path
	if file_path != "":
		if _gote_edit.is_saved:
			title = file_path + " - " + _name
		else:
			title = file_path + " * - " + _name
	else:
		file_path = "未命名"
		if _gote_edit.text_edit.text == "":
			title = file_path + " - " + _name
		else:
			title = file_path + " * - " + _name
	
	if title != _last_title:
		DisplayServer.window_set_title(title)
		_last_title = title
