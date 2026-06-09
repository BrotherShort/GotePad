class_name FindReplaceBar
extends HBoxContainer

# 不使用 @onready，因为外部调用方可能会在对象 ready 阶段之前调用
# No @onready, because external callers may call before the object is ready
var _main_text_edit: TextEdit:
	get: return %MainTextEdit
var _search_text_edit: LineEdit:
	get: return %SearchText
var _replace_text_edit: LineEdit:
	get: return %ReplaceText
var _case_sensitive: CheckBox:
	get: return %CaseSensitive


func _on_search_text_edit_text_changed(search_text: String) -> void:
	set_highlight_search_text(search_text)


func _on_find_prev_pressed() -> void:
	search(true)


func _on_find_next_pressed() -> void:
	search()


func _on_replace_pressed() -> void:
	search()
	replace_current()


func _on_replace_all_pressed() -> void:
	set_caret_col_line(Vector2i(0, 0))
	var is_found: bool = search()
	if not is_found:
		return
	var first_match_pos: Vector2i = get_caret_col_line() - Vector2i(get_search_text().length(), 0)
	replace_current()

	while (search()):
		var match_pos: Vector2i = get_caret_col_line() - Vector2i(get_search_text().length(), 0)
		if match_pos.y < first_match_pos.y or \
			match_pos.y == first_match_pos.y and match_pos.x <= first_match_pos.x:
			break
		replace_current()
		

func _on_hide_button_pressed() -> void:
	hide()


## 打开查找栏
## Show the search bar
func show_search(search_text: String) -> void:
	show()
	_search_text_edit.text = search_text
	_search_text_edit.grab_focus()
	_search_text_edit.caret_column = search_text.length()
	set_highlight_search_text(search_text)


## 打开替换栏
## Show the replace bar
func show_replace(search_text: String, replace_text: String) -> void:
	show()
	_search_text_edit.text = search_text
	_replace_text_edit.text = replace_text
	_replace_text_edit.grab_focus()
	_replace_text_edit.caret_column = replace_text.length()
	set_highlight_search_text(search_text)


## 获取搜索文本
## Get the search text
func get_search_text() -> String:
	return _search_text_edit.text


## 获取替换文本
## Get the replace text
func get_replace_text() -> String:
	return _replace_text_edit.text


## 查找
## Search
func search(is_prev: bool = false) -> bool:
	var flags: int = get_search_flags(is_prev)
	var caret_col_line: Vector2i = get_caret_col_line()
	var pos: Vector2i = _main_text_edit.search(get_search_text(), flags, caret_col_line.y, caret_col_line.x)
	if (pos.x >= 0):
		set_caret_col_line(pos)
		_main_text_edit.select(pos.y, pos.x, pos.y, pos.x + get_search_text().length())
		return true
	else:
		return false


## 将文本中的被搜索文本高亮显示
## Highlight the search text in the text
func set_highlight_search_text(search_text: String) -> void:
	var flags: int = get_search_flags()
	_main_text_edit.set_search_flags(flags)
	_main_text_edit.set_search_text(search_text)
	_main_text_edit.queue_redraw()


## 替换当前选中的文本
## Replace the currently selected text
func replace_current() -> void:
	_main_text_edit.delete_selection()
	var caret_col_line: Vector2i = get_caret_col_line()
	_main_text_edit.insert_text(get_replace_text(), caret_col_line.y, caret_col_line.x)


## 获取搜索标志
## Get the search flags
func get_search_flags(is_prev: bool = false) -> int:
	var flag: int = 0
	if _case_sensitive.button_pressed:
		flag |= TextEdit.SearchFlags.SEARCH_MATCH_CASE
	if is_prev:
		flag |= TextEdit.SearchFlags.SEARCH_BACKWARDS
	return flag


## 获取光标所在位置
## Get the caret column and line
func get_caret_col_line() -> Vector2i:
	return Vector2i(_main_text_edit.get_caret_column(), _main_text_edit.get_caret_line())


## 设置光标所在位置
## Set the caret column and line
func set_caret_col_line(col_line: Vector2i) -> void:
	_main_text_edit.set_caret_line(col_line.y)
	_main_text_edit.set_caret_column(col_line.x)
