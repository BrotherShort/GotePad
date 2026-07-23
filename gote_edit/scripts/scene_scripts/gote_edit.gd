class_name GoteEdit
extends TextEdit

## 文本改变时发出，传递编辑前后位置
## Emitted when the text changes; passes the positions before and after editing
signal lines_column_edited_from(_from_line: int, _from_column: int, _to_line: int, _to_column: int)

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
var _unsaved_dialog: Window:
	get: return %UnsavedDialog
var _find_replace_bar: FindReplaceBar:
	get: return %FindReplaceBar


func _ready() -> void:
	default_font_size = font_size


## 编辑前的文本行
## The text lines before editing
var _lines_before: PackedStringArray = []
## 编辑前的光标位置
## The line and column the caret is at before editing
var _caret_line_column_before: LineColumn

func _on_text_changed():
	# 处理是否已编辑
	# Handle whether the text is edited
	_is_edited = true

	# 处理编辑前后位置
	# Handle before-and-after edit positions
	var lines_after: PackedStringArray = []
	for i in range(get_line_count()):
		lines_after.append(get_line(i))
	var caret_line_column_after: LineColumn = LineColumn.new(get_caret_line(), get_caret_column())
	var diff_range: Vector4i = find_diff_range(_lines_before, lines_after, _caret_line_column_before, caret_line_column_after)
	lines_column_edited_from.emit(diff_range.x, diff_range.y, diff_range.z, diff_range.w)
	_lines_before = lines_after


func _on_lines_edited_from(_from_line: int, _to_line: int) -> void:
	_caret_line_column_before = LineColumn.new(get_caret_line(), get_caret_column())


func _on_open_file_dialog_file_selected(path: String) -> void:
	var callback: Callable = func():
		var file = FileAccess.open(path, FileAccess.READ)
		text = file.get_as_text()
		file_path = path
		_is_edited = false
	unsaved_check(callback)


## 保存为窗口的回调函数
## Callback function for the SaveFileDialog
var _save_file_dialog_callback: Callable

func _on_save_file_dialog_file_selected(path: String) -> void:
	_save_to_file(path)
	file_path = path
	_is_edited = false

	if _save_file_dialog_callback.is_valid():
		_save_file_dialog_callback.call()


## 未保存提示框的回调函数
## Callback function for the UnsavedDialog
var _unsaved_dialog_callback: Callable

func _on_unsaved_dialog_button_save_pressed() -> void:
	_unsaved_dialog.hide()
	_save_with_callback(_unsaved_dialog_callback)


func _on_unsaved_dialog_button_do_not_save_pressed() -> void:
	_unsaved_dialog.hide()
	if _unsaved_dialog_callback.is_valid():
		_unsaved_dialog_callback.call()


#region 文件 File

## 文件路径
## File path
var file_path: String = ""

## 是否已编辑
## Whether the text is edited
var _is_edited: bool = true

## 是否未保存
## Whether the text is unsaved
var is_unsaved: bool:
	get:
		if file_path != "":
			return _is_edited
		else:
			return text != ""


## 是否使用原生文件对话框
## Whether to use native file dialog
var use_native_dialog: bool:
	get:
		return _open_file_dialog.use_native_dialog
	set(value):
		_open_file_dialog.use_native_dialog = value
		_save_file_dialog.use_native_dialog = value


## 可用的文件类型筛选器
## The available file type filters
var file_filters: PackedStringArray:
	get:
		return _open_file_dialog.filters
	set(value):
		_open_file_dialog.filters = value
		_save_file_dialog.filters = value


## 新建
## New
func new_file() -> void:
	var callback: Callable = func():
		text = ""
		file_path = ""
		_is_edited = false

	unsaved_check(callback)


## 打开
## Open
func open_file() -> void:
	_open_file_dialog.popup_centered()


## 保存
## Save
func save_file() -> void:
	_save_with_callback(Callable())


## 保存为
## Save as
func save_file_as() -> void:
	_save_file_dialog_callback = Callable()
	_save_file_dialog.popup_centered()


## 保存后回调
## Save and callback
func _save_with_callback(callback: Callable):
	if file_path == "":
		_save_file_dialog_callback = callback
		_save_file_dialog.popup_centered()
		return
	
	_save_to_file(file_path)
	_is_edited = false

	if callback.is_valid():
		callback.call()


## 将文本保存到文件中
## Save the text to a file
func _save_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)


## 未保存检查
## Unsaved check
func unsaved_check(callback: Callable):
	if not is_unsaved:
		if callback.is_valid():
			callback.call()
		return
	
	_unsaved_dialog_callback = callback
	_unsaved_dialog.popup_centered()


## 格式化标题
## Formatted title
func formatted_title(app_name: String) -> String:
	var file_name: String
	if file_path != "":
		file_name = file_path.get_file()
	else:
		file_name = "未命名"
	var title: String
	if is_unsaved:
		title = file_name + "* - " + app_name
	else:
		title = file_name + " - " + app_name
	return title


#endregion

#region 查看 View

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
	

## 显示行号
## Whether to draw line numbers
var draw_line_numbers: bool:
	get:
		return $%LineNumbers.visible
	set(value):
		$%LineNumbers.visible = value


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
## Visual line and column position to text line and column position
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


## 查找文本编辑位置
## Find the start and end positions of edited text
static func find_diff_range(lines_before: PackedStringArray, lines_after: PackedStringArray, \
	from_line_column: LineColumn, to_line_column: LineColumn) -> Vector4i:
	if from_line_column.less_than(to_line_column):
		# 后移一定是插入
		# Moving backward must be from an insertion
		return Vector4i(from_line_column.line, from_line_column.column, to_line_column.line, to_line_column.column)
	elif from_line_column.greater_than(to_line_column):
		# 前移一定是删除
		# Moving forward must be from a deletion
		return Vector4i(from_line_column.line, from_line_column.column, to_line_column.line, to_line_column.column)
	else:
		# 不移代表删除了光标后的文本
		# No movement indicates that text after the cursor was deleted
		if lines_before.size() == lines_after.size():
			# 行数不变代表行内编辑
			# No change in line count indicates in-line editing
			var delta: int = lines_before[from_line_column.line].length() - lines_after[to_line_column.line].length()
			return Vector4i(from_line_column.line, from_line_column.column + delta, to_line_column.line, to_line_column.column)
		else:
			# 行数改变代表跨行编辑
			# A change in line count indicates cross-line editing
			var delta_line_count = lines_before.size() - lines_after.size()
			var from_line = to_line_column.line + delta_line_count
			# 光标后的字符数，这些字符是从其他行前移而来
			# Number of characters after the cursor; these characters were moved forward from other lines
			var line_tail_count = lines_after[to_line_column.line].length() - to_line_column.column
			var from_column = lines_before[from_line_column.line].length() - line_tail_count
			return Vector4i(from_line, from_column, to_line_column.line, to_line_column.column)
		

#endregion

#region 边栏 Gutter

## 根据名称获取边栏
## Get the gutter by name
func get_gutter_by_name(gutter_name: String) -> int:
	for i in range(get_gutter_count()):
		if get_gutter_name(i) == gutter_name:
			return i
	return -1


## 根据名称移除边栏
## Remove the gutter by name
func remove_gutter_by_name(gutter_name: String) -> void:
	for i in range(get_gutter_count()):
		if get_gutter_name(i) == gutter_name:
			remove_gutter(i)


## 获取边栏边界矩形
## Get the gutter bounding rectangle
func get_gutter_ract(gutter: int) -> Rect2:
	if gutter < 0 || gutter >= get_gutter_count():
		return Rect2()

	var offset: Vector2 = get_theme_stylebox("normal").get_offset()

	var left_gutter_width: int = 0
	for i in range(gutter):
		left_gutter_width += get_gutter_width(i)

	var width: int = get_gutter_width(gutter)

	var bottom_margin: float = get_theme_stylebox("normal").get_margin(SIDE_BOTTOM)
	var height: float = size.y - offset.y - bottom_margin
	
	return Rect2(Vector2(offset.x + left_gutter_width, offset.y), Vector2(width, height))


## 根据名称获取边栏边界矩形
## Get the gutter bounding rectangle by name
func get_gutter_ract_by_name(gutter_name: String) -> Rect2:
	var gutter: int = get_gutter_by_name(gutter_name)
	return get_gutter_ract(gutter)


## 获取边栏中位置对应的显示行
## Get the visual line corresponding to the position in the gutter
func get_visual_line_in_gutter(gutter: int, pos: Vector2) -> int:
	var ract: Rect2 = get_gutter_ract(gutter)
	if not ract.has_point(pos):
		return -1
	
	var visual_pos: float = (pos - ract.position).y / get_line_height() + get_v_scroll_bar().value
	var visual_line: int = floori(visual_pos)
	return visual_line


## 获取边栏中位置对应的文本行
## Get the text line corresponding to the position in the gutter
func get_line_in_gutter(gutter: int, pos: Vector2) -> int:
	var visual_line: int = get_visual_line_in_gutter(gutter, pos)
	var line: int = visual_line_to_line(visual_line).line
	return line

#endregion
