extends Control

## 软件名称
## Application name
var _name: String = ""

## 上一个窗口标题
## Last window title
var _last_title: String = ""

var _current_language: String = "zh_CN"

@onready var _gote_edit: GoteEdit = $%GoteEdit
@onready var _file_menu: PopupMenu = $VBoxContainer/HBoxContainer/MenuBar/FileMenu
@onready var _edit_menu: PopupMenu = $VBoxContainer/HBoxContainer/MenuBar/EditMenu
@onready var _view_menu: PopupMenu = $VBoxContainer/HBoxContainer/MenuBar/ViewMenu
@onready var _help_menu: PopupMenu = $VBoxContainer/HBoxContainer/MenuBar/HelpMenu
@onready var _language_menu: PopupMenu = $VBoxContainer/HBoxContainer/MenuBar/LanguageMenu
@onready var _about_window: Window = $AboutWindow
@onready var _about_label: Label = $AboutWindow/Label2
@onready var _about_credits: Label = $AboutWindow/Label3
#@onready var _search_text_edit: LineEdit = $VBoxContainer/TabContainer/GoteEdit/FindReplaceBar/BgContainer1/BgContainer2/HBoxContainer/SearchText
#@onready var _replace_text_edit: LineEdit = $VBoxContainer/TabContainer/GoteEdit/FindReplaceBar/BgContainer1/BgContainer2/HBoxContainer/ReplaceText
@onready var _case_sensitive: CheckBox = $VBoxContainer/TabContainer/GoteEdit/FindReplaceBar/BgContainer1/BgContainer2/HBoxContainer/ButtonContainer/SearchButtonContainer/CaseSensitive
@onready var _replace_button: Button = $VBoxContainer/TabContainer/GoteEdit/FindReplaceBar/BgContainer1/BgContainer2/HBoxContainer/ButtonContainer/ReplaceButtonContainer/Replace
@onready var _replace_all_button: Button = $VBoxContainer/TabContainer/GoteEdit/FindReplaceBar/BgContainer1/BgContainer2/HBoxContainer/ButtonContainer/ReplaceButtonContainer/ReplaceAll
@onready var _open_file_dialog: FileDialog = $VBoxContainer/TabContainer/GoteEdit/Dialogs/OpenFileDialog
@onready var _save_file_dialog: FileDialog = $VBoxContainer/TabContainer/GoteEdit/Dialogs/SaveFileDialog
@onready var _unsaved_dialog: Window = $VBoxContainer/TabContainer/GoteEdit/Dialogs/UnsavedDialog
@onready var _unsaved_label: Label = $VBoxContainer/TabContainer/GoteEdit/Dialogs/UnsavedDialog/Label
@onready var _unsaved_button_save: Button = $VBoxContainer/TabContainer/GoteEdit/Dialogs/UnsavedDialog/UnsavedDialogButtonSave
@onready var _unsaved_button_do_not_save: Button = $VBoxContainer/TabContainer/GoteEdit/Dialogs/UnsavedDialog/UnsavedDialogButtonDoNotSave
@onready var _unsaved_button_cancel: Button = $VBoxContainer/TabContainer/GoteEdit/Dialogs/UnsavedDialog/UnsavedDialogButtonCancel

const TRANSLATIONS: Dictionary = {
	"zh_CN": {
		"menu_file": "文件",
		"menu_edit": "编辑",
		"menu_view": "查看",
		"menu_help": "帮助",
		"menu_language": "语言",
		"file_new": "新建",
		"file_open": "打开",
		"file_save": "保存",
		"file_save_as": "保存为",
		"file_recent": "最近的文件",
		"edit_undo": "撤销",
		"edit_redo": "重做",
		"edit_cut": "剪切",
		"edit_copy": "复制",
		"edit_paste": "粘贴",
		"edit_select_all": "全选",
		"edit_find": "查找",
		"edit_replace": "替换",
		"view_zoom_in": "放大",
		"view_zoom_out": "缩小",
		"view_zoom_reset": "默认缩放",
		"view_word_wrap": "自动换行",
		"view_show_line_numbers": "显示行号",
		"menu_about": "关于",
		"language_zh": "中文",
		"language_en": "English",
		"open_file_dialog_title": "打开文件",
		"open_file_dialog_ok": "打开",
		"save_file_dialog_title": "保存文件",
		"save_file_dialog_ok": "保存",
		"unsaved_warning_title": "未保存提示",
		"unsaved_warning_label": "文档存在未保存的修改，\n是否要保存对文档的修改？",
		"unsaved_save": "保存",
		"unsaved_discard": "不保存",
		"unsaved_cancel": "取消",
		"placeholder_search": "查找",
		"placeholder_replace": "替换",
		"case_sensitive": "区分大小写",
		"replace": "替换",
		"replace_all": "替换全部",
		"untitled": "未命名",
		"about_text_line": "by 摄思工作室\nmade with Godot",
		"about_credits": "第三方资源："
	},
	"en": {
		"menu_file": "File",
		"menu_edit": "Edit",
		"menu_view": "View",
		"menu_help": "Help",
		"menu_language": "Language",
		"file_new": "New",
		"file_open": "Open",
		"file_save": "Save",
		"file_save_as": "Save As",
		"file_recent": "Recent Files",
		"edit_undo": "Undo",
		"edit_redo": "Redo",
		"edit_cut": "Cut",
		"edit_copy": "Copy",
		"edit_paste": "Paste",
		"edit_select_all": "Select All",
		"edit_find": "Find",
		"edit_replace": "Replace",
		"view_zoom_in": "Zoom In",
		"view_zoom_out": "Zoom Out",
		"view_zoom_reset": "Reset Zoom",
		"view_word_wrap": "Word Wrap",
		"view_show_line_numbers": "Show Line Numbers",
		"menu_about": "About",
		"language_zh": "中文",
		"language_en": "English",
		"open_file_dialog_title": "Open a File",
		"open_file_dialog_ok": "Open",
		"save_file_dialog_title": "Save a File",
		"save_file_dialog_ok": "Save",
		"unsaved_warning_title": "Unsaved Changes",
		"unsaved_warning_label": "The document has unsaved changes.\nDo you want to save them?",
		"unsaved_save": "Save",
		"unsaved_discard": "Don't Save",
		"unsaved_cancel": "Cancel",
		"placeholder_search": "Search",
		"placeholder_replace": "Replace",
		"case_sensitive": "Match case",
		"replace": "Replace",
		"replace_all": "Replace All",
		"untitled": "Untitled",
		"about_text_line": "by Gote Studio\nmade with Godot",
		"about_credits": "Third-party resources:"
	}
}

func _ready():
	_name = ProjectSettings.get_setting("application/config/name") as String
	_gote_edit.use_native_dialog = true
	_gote_edit.file_filters = ["*.txt"]
	get_tree().set_auto_accept_quit(false)
	_language_menu.id_pressed.connect(_on_language_menu_id_pressed)
	set_language(_detect_default_language())


func _process(_delta: float):
	var title: String = _get_window_title()
	if title != _last_title:
		DisplayServer.window_set_title(title)
		_last_title = title


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_gote_edit.unsaved_check(func(): get_tree().quit())


func _detect_default_language() -> String:
	var locale: String = OS.get_locale().to_lower()
	if locale.begins_with("zh"):
		return "zh_CN"
	return "en"


func set_language(language: String) -> void:
	if not TRANSLATIONS.has(language):
		language = "en"
	_current_language = language
	_update_language_menu_states()
	_apply_language()


func _translate(key: String) -> String:
	return TRANSLATIONS.get(_current_language, {}).get(key, key)


func _apply_language() -> void:
	_file_menu.title = _translate("menu_file")
	_file_menu.set_item_text(0, _translate("file_new"))
	_file_menu.set_item_text(1, _translate("file_open"))
	_file_menu.set_item_text(2, _translate("file_recent"))
	_file_menu.set_item_text(3, _translate("file_save"))
	_file_menu.set_item_text(4, _translate("file_save_as"))

	_edit_menu.title = _translate("menu_edit")
	_edit_menu.set_item_text(0, _translate("edit_undo"))
	_edit_menu.set_item_text(1, _translate("edit_redo"))
	_edit_menu.set_item_text(3, _translate("edit_cut"))
	_edit_menu.set_item_text(4, _translate("edit_copy"))
	_edit_menu.set_item_text(5, _translate("edit_paste"))
	_edit_menu.set_item_text(7, _translate("edit_select_all"))
	_edit_menu.set_item_text(9, _translate("edit_find"))
	_edit_menu.set_item_text(10, _translate("edit_replace"))

	_view_menu.title = _translate("menu_view")
	_view_menu.set_item_text(0, _translate("view_zoom_in"))
	_view_menu.set_item_text(1, _translate("view_zoom_out"))
	_view_menu.set_item_text(2, _translate("view_zoom_reset"))
	_view_menu.set_item_text(4, _translate("view_word_wrap"))
	_view_menu.set_item_text(5, _translate("view_show_line_numbers"))

	_help_menu.title = _translate("menu_help")
	_help_menu.set_item_text(0, _translate("menu_about"))

	_language_menu.title = _translate("menu_language")
	_language_menu.set_item_text(0, _translate("language_zh"))
	_language_menu.set_item_text(1, _translate("language_en"))

	_about_window.title = _translate("menu_about")
	_about_label.text = _translate("about_text_line")
	_about_credits.text = _translate("about_credits")

	_open_file_dialog.title = _translate("open_file_dialog_title")
	_open_file_dialog.ok_button_text = _translate("open_file_dialog_ok")
	_save_file_dialog.title = _translate("save_file_dialog_title")
	_save_file_dialog.ok_button_text = _translate("save_file_dialog_ok")

	_unsaved_dialog.title = _translate("unsaved_warning_title")
	_unsaved_label.text = _translate("unsaved_warning_label")
	_unsaved_button_save.text = _translate("unsaved_save")
	_unsaved_button_do_not_save.text = _translate("unsaved_discard")
	_unsaved_button_cancel.text = _translate("unsaved_cancel")

	# _search_text_edit.placeholder_text = _translate("placeholder_search")
	# _replace_text_edit.placeholder_text = _translate("placeholder_replace")
	_case_sensitive.text = _translate("case_sensitive")
	_replace_button.text = _translate("replace")
	_replace_all_button.text = _translate("replace_all")


func _get_window_title() -> String:
	var file_name: String
	if _gote_edit.file_path != "":
		file_name = _gote_edit.file_path.get_file()
	else:
		file_name = _translate("untitled")
	var title: String = file_name
	if _gote_edit.is_unsaved:
		title += "*"
	title += " - " + _name
	return title


func _on_language_menu_id_pressed(id: int) -> void:
	match id:
		0:
			set_language("zh_CN")
		1:
			set_language("en")


func _update_language_menu_states() -> void:
	_language_menu.set_item_checked(0, _current_language == "zh_CN")
	_language_menu.set_item_checked(1, _current_language == "en")
