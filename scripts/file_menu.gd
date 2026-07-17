extends PopupMenu

@onready var _gote_edit: GoteEdit = $%GoteEdit

func _ready():
	id_pressed.connect(_id_pressed)
	set_menu_shortcuts()


func _id_pressed(id: int) -> void:
	match id:
		0: # 新建
			_gote_edit.new_file()
		1: # 打开
			_gote_edit.open_file()
		2: # 保存
			_gote_edit.save_file()
		3: # 保存为
			_gote_edit.save_file_as()


## 设置菜单快捷键
## Set menu shortcuts
func set_menu_shortcuts() -> void:
	set_item_shortcut(0, MenuHelper.get_shortcut(KEY_N)) # 新建
	set_item_shortcut(1, MenuHelper.get_shortcut(KEY_O)) # 打开
	set_item_shortcut(2, MenuHelper.get_shortcut(KEY_S)) # 保存
	set_item_shortcut(3, MenuHelper.get_shortcut(KEY_S, true)) # 保存为
