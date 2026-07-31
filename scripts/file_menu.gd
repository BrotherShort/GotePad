extends PopupMenu

const MAX_RECENT_FILE_COUNT: int = 10
const RECENT_FILES_CONFIG_PATH: String = "user://recent_files.cfg"
const RECENT_FILES_CONFIG_SECTION: String = "RecentFiles"
const RECENT_FILES_CONFIG_KEY: String = "paths"
const NO_RECENT_FILES_TEXT: Dictionary = {"zh_CN": "无最近文件", "en": "No Recent Files"}

@onready var _gote_edit: GoteEdit = $%GoteEdit
@onready var _recent_files_menu: PopupMenu = $RecentFilesMenu

var _recent_files: Array = []

func _get_no_recent_files_text() -> String:
	var locale: String = OS.get_locale().to_lower()
	if locale.begins_with("zh"):
		return NO_RECENT_FILES_TEXT["zh_CN"]
	return NO_RECENT_FILES_TEXT["en"]

func _ready():
	id_pressed.connect(_id_pressed)
	_recent_files_menu.id_pressed.connect(_id_pressed_recent_file)
	_gote_edit.file_path_opened.connect(_add_recent_file)
	_gote_edit.file_path_saved.connect(_add_recent_file)
	set_menu_shortcuts()
	_load_recent_files()
	_update_recent_files_menu()


func _id_pressed(id: int) -> void:
	match id:
		0: # 新建
			_gote_edit.new_file()
		1: # 打开
			_gote_edit.open_file()
		2: # 最近的文件
			# Submenu handled by RecentFilesMenu, nothing to do here.
			pass
		3: # 保存
			_gote_edit.save_file()
		4: # 保存为
			_gote_edit.save_file_as()


func _id_pressed_recent_file(id: int) -> void:
	if id < 0 || id >= _recent_files.size():
		return
	_open_recent_file(_recent_files[id])


func _open_recent_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		_remove_recent_file(path)
		return
	
	var callback: Callable = func():
		var file = FileAccess.open(path, FileAccess.READ)
		if file is FileAccess:
			_gote_edit.text = file.get_as_text()
			_gote_edit.file_path = path
			_gote_edit._is_edited = false
			_add_recent_file(path)
	
	_gote_edit.unsaved_check(callback)


func _add_recent_file(path: String) -> void:
	if path == "":
		return
	path = path.replace("\\", "/")
	if _recent_files.has(path):
		_recent_files.erase(path)
	_recent_files.insert(0, path)
	while _recent_files.size() > MAX_RECENT_FILE_COUNT:
		_recent_files.pop_back()
	_save_recent_files()
	_update_recent_files_menu()


func _remove_recent_file(path: String) -> void:
	path = path.replace("\\", "/")
	if _recent_files.has(path):
		_recent_files.erase(path)
		_save_recent_files()
		_update_recent_files_menu()


func _load_recent_files() -> void:
	var config = ConfigFile.new()
	if config.load(RECENT_FILES_CONFIG_PATH) == OK:
		_recent_files = config.get_value(RECENT_FILES_CONFIG_SECTION, RECENT_FILES_CONFIG_KEY, [])
	else:
		_recent_files = []


func _save_recent_files() -> void:
	var config = ConfigFile.new()
	config.set_value(RECENT_FILES_CONFIG_SECTION, RECENT_FILES_CONFIG_KEY, _recent_files)
	config.save(RECENT_FILES_CONFIG_PATH)


func _update_recent_files_menu() -> void:
	_recent_files_menu.clear()
	#if _recent_files.size() == 0:
		#_recent_files_menu.add_disabled_item(_get_no_recent_files_text())
		#return
	for index in range(_recent_files.size()):
		var path = _recent_files[index]
		var item_text = path.get_file()
		_recent_files_menu.add_item(item_text, index)


## 设置菜单快捷键
## Set menu shortcuts
func set_menu_shortcuts() -> void:
	set_item_shortcut(0, MenuHelper.get_shortcut(KEY_N)) # 新建
	set_item_shortcut(1, MenuHelper.get_shortcut(KEY_O)) # 打开
	set_item_shortcut(3, MenuHelper.get_shortcut(KEY_S)) # 保存
	set_item_shortcut(4, MenuHelper.get_shortcut(KEY_S, true)) # 保存为
