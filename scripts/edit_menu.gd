extends PopupMenu

@onready var _gote_edit: GoteEdit = $%GoteEdit

func _ready():
	id_pressed.connect(_id_pressed)
	set_menu_shortcuts()


func _id_pressed(id: int) -> void:
	match id:
		0: # 撤销 Undo
			_gote_edit.menu_option(TextEdit.MenuItems.MENU_UNDO)
		1: # 重做 Redo
			_gote_edit.menu_option(TextEdit.MenuItems.MENU_REDO)
		3: # 剪切 Cut
			_gote_edit.menu_option(TextEdit.MenuItems.MENU_CUT)
		4: # 复制 Copy
			_gote_edit.menu_option(TextEdit.MenuItems.MENU_COPY)
		5: # 粘贴 Paste
			_gote_edit.menu_option(TextEdit.MenuItems.MENU_PASTE)
		7: # 全选 Select All
			_gote_edit.menu_option(TextEdit.MenuItems.MENU_SELECT_ALL)
		9: # 查找 Find
			_gote_edit.show_search()
		10: # 替换 Replace
			_gote_edit.show_replace()


## 设置菜单快捷键
## Set menu shortcuts
func set_menu_shortcuts() -> void:
	set_item_shortcut(0, MenuHelper.get_shortcut(KEY_Z)) # 撤销 Undo
	set_item_shortcut(1, MenuHelper.get_shortcut(KEY_Y)) # 重做 Redo
	set_item_shortcut(3, MenuHelper.get_shortcut(KEY_X)) # 剪切 Cut
	set_item_shortcut(4, MenuHelper.get_shortcut(KEY_C)) # 复制 Copy
	set_item_shortcut(5, MenuHelper.get_shortcut(KEY_V)) # 粘贴 Paste
	set_item_shortcut(7, MenuHelper.get_shortcut(KEY_A)) # 全选 Select All
	set_item_shortcut(9, MenuHelper.get_shortcut(KEY_F)) # 查找 Find
	set_item_shortcut(10, MenuHelper.get_shortcut(KEY_H)) # 替换 Replace
