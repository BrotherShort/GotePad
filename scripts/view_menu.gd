extends PopupMenu

@onready var _gote_edit: GoteEdit = $"%GoteEdit"

func _ready():
	id_pressed.connect(_id_pressed)
	set_menu_shortcuts()


func _id_pressed(id: int) -> void:
	match id:
		0: # 放大 Zoom in
			_gote_edit.zoom_in()
		1: # 缩小 Zoom out
			_gote_edit.zoom_out()
		2: # 默认 Reset
			_gote_edit.zoom_reset()
		4: # 自动换行 Toggle line wrap
			var is_checked: bool = is_item_checked(id)
			is_checked = not is_checked
			set_item_checked(id, is_checked)
			if is_checked:
				_gote_edit.text_edit.wrap_mode = TextEdit.LineWrappingMode.LINE_WRAPPING_BOUNDARY
			else:
				_gote_edit.text_edit.wrap_mode = TextEdit.LineWrappingMode.LINE_WRAPPING_NONE


func set_menu_shortcuts() -> void:
	set_item_shortcut(0, MenuHelper.get_shortcut(KEY_EQUAL)) # 放大 Zoom in
	set_item_shortcut(1, MenuHelper.get_shortcut(KEY_MINUS)) # 缩小 Zoom out
	set_item_shortcut(2, MenuHelper.get_shortcut(KEY_0)) # 默认 Reset
