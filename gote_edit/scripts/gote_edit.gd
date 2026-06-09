class_name GoteEdit
extends Control

## 文件路径
## File path
var file_path: String = ""

## 默认字体大小
## Default font size
var default_font_size: int = 16

## 字体大小
## Font size
var font_size: int:
	get:
		return text_edit.get_theme_font_size("font_size", "TextEdit")
	set(value):
		text_edit.add_theme_font_size_override("font_size", value)


## 是否使用原生文件对话框
## Whether to use native file dialog
var use_native_dialog: bool:
	get:
		return _open_file_dialog.use_native_dialog
	set(value):
		_open_file_dialog.use_native_dialog = value
		_save_file_dialog.use_native_dialog = value


## 是否已保存
## Whether the text is saved
var is_saved: bool = true

# 不使用 @onready，因为外部调用方可能会在对象 ready 阶段之前调用

## 主文本编辑控件
## Main text edit control
var text_edit: TextEdit:
	get: return %MainTextEdit

var _open_file_dialog: FileDialog:
	get: return %OpenFileDialog
var _save_file_dialog: FileDialog:
	get: return %SaveFileDialog
var _find_replace_bar: FindReplaceBar:
	get: return %FindReplaceBar

func _ready() -> void:
	default_font_size = font_size


func _on_main_text_edit_text_changed():
	is_saved = false


func _on_open_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	text_edit.text = file.get_as_text()
	file_path = path


func _on_save_file_dialog_file_selected(path: String) -> void:
	_save_file(path)
	file_path = path


## 新建
## New
func new_file() -> void:
	text_edit.text = ""
	file_path = ""


## 打开
## Open
func open_file() -> void:
	_open_file_dialog.popup_centered()


## 保存
## Save
func save_file() -> void:
	if (file_path == ""):
		save_file_as()
	else:
		_save_file(file_path)
		is_saved = true


## 保存为
## Save as
func save_file_as() -> void:
	_save_file_dialog.popup_centered()
	is_saved = true


## 打开查找
## Show the search bar
func show_search() -> void:
	var search_text = text_edit.get_selected_text()
	_find_replace_bar.show_search(search_text)


## 打开替换
## Show the replace bar
func show_replace() -> void:
	var search_text = text_edit.get_selected_text()
	_find_replace_bar.show_replace(search_text, "")


## 放大
## Zoom in
func zoom_in() -> void:
	var new_size = font_size
	new_size += 2
	font_size = new_size


## 缩小
## Zoom out
func zoom_out() -> void:
	var new_size = font_size
	new_size -= 2
	if new_size > 0:
		font_size = new_size


## 重置缩放
## Reset zoom
func zoom_reset() -> void:
	font_size = default_font_size


## 将文本保存到文件中
## Save the text to a file
func _save_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text_edit.text)
