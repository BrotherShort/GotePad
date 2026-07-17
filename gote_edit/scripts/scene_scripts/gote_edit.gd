class_name GoteEdit
extends TextEdit

## 插件的根目录
## The root path of the addon
var addon_path: String:
	get: return scene_file_path.get_base_dir()


# 不使用 @onready，因为外部调用方可能会在对象 ready 阶段之前调用
# No @onready, because external callers may call before the object is ready
var _open_file_dialog: FileDialog:
	get: return %OpenFileDialog
var _save_file_dialog: FileDialog:
	get: return %SaveFileDialog
var _close_prompt_dialog: Window:
	get: return %ClosePromptDialog
var _find_replace_bar: FindReplaceBar:
	get: return %FindReplaceBar


func _ready() -> void:
	default_font_size = font_size


func _on_text_changed():
	_is_edited = true


func _on_open_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	text = file.get_as_text()
	file_path = path
	_is_edited = false


func _on_save_file_dialog_file_selected(path: String) -> void:
	_save_to_file(path)
	file_path = path
	_is_edited = false
	if _close_prompt_dialog.visible:
		get_tree().quit()


func _on_button_save_close_pressed() -> void:
	if file_path == "":
		save_file_as()
	else:
		save_file()
		get_tree().quit()


func _on_button_do_not_save_close_pressed() -> void:
	get_tree().quit()


#region 文件 File

## 文件路径
## File path
var file_path: String = ""

## 是否已编辑
## Whether the text is edited
var _is_edited: bool = true

## 是否已保存
## Whether the text is saved
var is_saved: bool:
	get:
		if file_path != "":
			return not _is_edited
		else:
			return text == ""


## 是否使用原生文件对话框
## Whether to use native file dialog
var use_native_dialog: bool:
	get:
		return _open_file_dialog.use_native_dialog
	set(value):
		_open_file_dialog.use_native_dialog = value
		_save_file_dialog.use_native_dialog = value


## 新建
## New
func new_file() -> void:
	text = ""
	file_path = ""
	_is_edited = false


## 打开
## Open
func open_file() -> void:
	_open_file_dialog.popup_centered()


## 保存
## Save
func save_file() -> void:
	if file_path == "":
		save_file_as()
		return
	
	_save_to_file(file_path)
	_is_edited = false


## 保存为
## Save as
func save_file_as() -> void:
	_save_file_dialog.popup_centered()


## 将文本保存到文件中
## Save the text to a file
func _save_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)


## 关闭检查
## Close check
func close_check() -> void:
	if is_saved:
		get_tree().quit()
	
	_close_prompt_dialog.popup_centered()


## 格式化标题
## Formatted title
func formatted_title(app_name: String) -> String:
	var file_name: String
	if file_path != "":
		file_name = file_path.get_file()
	else:
		file_name = "未命名"
	var title: String
	if is_saved:
		title = file_name + " - " + app_name
	else:
		title = file_name + "* - " + app_name
	return title

#endregion

#region 搜索栏 Find Replace bar

## 打开查找
## Show the search bar
func show_search() -> void:
	var search_text = get_selected_text()
	_find_replace_bar.show_search(search_text)


## 打开替换
## Show the replace bar
func show_replace() -> void:
	var search_text = get_selected_text()
	_find_replace_bar.show_replace(search_text, "")
	
#endregion

#region 视图 View

## 默认字体大小
## Default font size
var default_font_size: int = 16

## 字体大小
## Font size
var font_size: int:
	get:
		return get_theme_font_size("font_size", "TextEdit")
	set(value):
		add_theme_font_size_override("font_size", value)


## 显示行号
## Whether to draw line numbers
var draw_line_numbers: bool:
	get:
		return $%LineNumbers.visible
	set(value):
		$%LineNumbers.visible = value


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

#endregion

#region 行 Line

## 获取文本行长度
## Get text line length
func get_line_length(line: int) -> int:
	if line < 0 || line >= get_line_count():
		return -1

	return get_line(line).length()


## 获取文本行位于换行索引的文本的长度
## Get the text length at the wrap index of a text line
func get_line_wrap_index_length(line: int, wrap_index: int) -> int:
	if line < 0 || line >= get_line_count():
		return -1

	if wrap_index < 0 || wrap_index > get_line_wrap_count(line):
		return -1

	var line_length: int = get_line(line).length()
  
	var start_col: int = 0
	for col in range(0, line_length):
		var col_wrap_index: int = get_line_wrap_index_at_column(line, col)
		if col_wrap_index == wrap_index:
			start_col = col
			break

	var end_col: int = line_length
	for col in range(start_col + 1, line_length):
		var col_wrap_index: int = get_line_wrap_index_at_column(line, col)
		if col_wrap_index == wrap_index + 1:
			end_col = col
			break

	return end_col - start_col


## 文本行号转显示行号
## Line number to visual line number
func line_to_visual_line(line: int, wrap_index: int) -> int:
	if line < 0 || line >= get_line_count():
		return -1

	if wrap_index < 0 || wrap_index > get_line_wrap_count(line):
		return -1

	var visual_line: int
	if line > 0:
		visual_line = get_visible_line_count_in_range(0, line - 1)
	else:
		visual_line = 0

	visual_line += wrap_index

	return visual_line


## 显示行号转文本行号
## Visual line number to text line number
func visual_line_to_line(visual_line: int) -> LineWrapIndex:
	if visual_line < 0 || visual_line >= get_total_visible_line_count():
		return LineWrapIndex.new(-1, -1)

	var line: int = -1
	var wrap_index: int = -1
	for i in range(get_line_count()):
		var visual_line_count: int = get_visible_line_count_in_range(0, i)
		if visual_line_count > visual_line:
			line = i
			if i > 0:
				wrap_index = visual_line - get_visible_line_count_in_range(0, i - 1)
			else:
				wrap_index = visual_line
			break

	return LineWrapIndex.new(line, wrap_index)


## 获取显示行长度
## Get visual line length
func get_visual_line_length(visual_line: int) -> int:
	if visual_line < 0 || visual_line >= get_total_visible_line_count():
		return -1

	var line_wrap_index: LineWrapIndex = visual_line_to_line(visual_line)
	if line_wrap_index.line == -1:
		return -1

	return get_line_wrap_index_length(line_wrap_index.line, line_wrap_index.wrap_index)


## 文本行行列位置转显示行行列位置
## Text line and column position to visual line and column position
func line_column_to_visual_line_column(line_column: LineColumn) -> LineColumn:
	if line_column.line < 0 || line_column.line >= get_line_count():
		return LineColumn.new(-1, -1)
	
	var line_length: int = get_line(line_column.line).length()
	if line_column.column < 0 || line_column.column > line_length:
		return LineColumn.new(-1, -1)

	var visual_line: int
	if line_column.line > 0:
		visual_line = get_visible_line_count_in_range(0, line_column.line - 1)
	else:
		visual_line = 0
	visual_line += get_line_wrap_index_at_column(line_column.line, line_column.column)

	var line_wrap_index: LineWrapIndex = visual_line_to_line(visual_line)
	var up_visual_line_length: int = 0
	for i in range(0, line_wrap_index.wrap_index):
		up_visual_line_length += get_line_wrap_index_length(line_wrap_index.line, i)
	var visual_col: int = line_column.column - up_visual_line_length

	return LineColumn.new(visual_line, visual_col)


## 显示行行列位置转文本行行列位
## Visble line and column position to text line and column position
func visual_line_column_to_line_column(visual_line_column: LineColumn) -> LineColumn:
	if visual_line_column.line < 0 || visual_line_column.line >= get_total_visible_line_count():
		return LineColumn.new(-1, -1)
	
	var visual_line_length: int = get_visual_line_length(visual_line_column.line)
	if visual_line_column.column < 0 || visual_line_column.column > visual_line_length:
		return LineColumn.new(-1, -1)

	var line_wrap_index: LineWrapIndex = visual_line_to_line(visual_line_column.line)

	var char_count: int = 0
	for i in range(line_wrap_index.wrap_index):
		char_count += get_line_wrap_index_length(line_wrap_index.line, i)
	char_count += visual_line_column.column

	return LineColumn.new(line_wrap_index.line, char_count)

#endregion
