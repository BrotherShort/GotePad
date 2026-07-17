extends Control

## 行号栏名称
## Line number gutter name
const LINE_NUMBER_GUTTER_NAME: String = "gote_line_number"

var _gote_edit: GoteEdit:
	get: return owner

## 行号数字 label 场景资源
## Line number label scene resource
var _number_label: Resource

func _ready() -> void:
	_number_label = load(owner.addon_path + "/scenes/line_number_label.tscn")


func _process(_delta: float) -> void:
	if visible:
		var font = _gote_edit.get_theme_font("font")
		var font_size: int = _gote_edit.get_theme_font_size("font_size")
		var color: Color = get_theme_color("line_number_color", "CodeEdit")
		var focus_color: Color = color
		focus_color.a = 1
		
		var first_line: int = _gote_edit.get_first_visible_line()
		var last_line: int = _gote_edit.get_last_full_visible_line() + 1

		var offset: Vector2 = _gote_edit.get_theme_stylebox("normal").get_offset()
		var gutter_pos: int = get_gutter_pos()
		var max_num_width: float = _get_number_width(font, font_size, _gote_edit.get_line_count())
		var margin: float = font_size / 2.0
		var gutter_width: int = ceili(max_num_width + margin * 2)

		var gutter_index: int = get_gutter()
		_gote_edit.set_gutter_width(gutter_index, gutter_width)

		_reset_group()
		for i in range(_gote_edit.get_line_count()):
			if i < first_line || i > last_line:
				continue

			var visual_line: int = _gote_edit.line_to_visual_line(i, 0)
			
			var num_text: String = str(i + 1);
			
			var num_label: Label = _get_next_label()
			num_label.add_theme_font_override("font", font)
			num_label.add_theme_font_size_override("font_size", font_size)
			if _gote_edit.get_caret_line() == i:
				num_label.add_theme_color_override("font_color", focus_color)
			else:
				num_label.add_theme_color_override("font_color", color)
			num_label.text = num_text
			
			var num_size = font.get_string_size(num_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
			num_label.size.x = max_num_width
			num_label.size.y = num_size.y
			num_label.position.x = offset.x + gutter_pos + margin
			num_label.position.y = \
				offset.y + \
				(visual_line - _gote_edit.scroll_vertical) * _gote_edit.get_line_height() + \
				(_gote_edit.get_line_height() - num_size.y) / 2


func _on_hidden() -> void:
	remove_gutter()


## 获取行号栏
## Get line number gutter
func get_gutter() -> int:
	for i in range(_gote_edit.get_gutter_count()):
		if _gote_edit.get_gutter_name(i) == LINE_NUMBER_GUTTER_NAME:
			return i

	_gote_edit.add_gutter(-1);
	var gutter_index: int = _gote_edit.get_gutter_count() - 1
	_gote_edit.set_gutter_name(gutter_index, LINE_NUMBER_GUTTER_NAME);
	return gutter_index


## 获取行号栏横向位置
## Get line number gutter position x
func get_gutter_pos() -> int:
	var gutter_index: int = get_gutter()
	var total_width: int = 0
	for i in range(gutter_index):
		total_width += _gote_edit.get_gutter_width(i)
	return total_width


## 移除行号栏
## Remove line number gutter
func remove_gutter() -> void:
	for i in range(_gote_edit.get_gutter_count()):
		if _gote_edit.get_gutter_name(i) == LINE_NUMBER_GUTTER_NAME:
			_gote_edit.remove_gutter(i)


## 重置行号 label
## Reset line number labels
func _reset_group() -> void:
	for child in get_children():
		child.visible = false


## 获取下一个行号 label，不够自动创建
## Get the next line number label; if there aren't enough, create them automatically
func _get_next_label() -> Label:
	for child in get_children():
		if not child.visible:
			child.visible = true
			return child

	var new_num: Label = _number_label.instantiate()
	new_num.visible = true
	add_child(new_num)
	return new_num


## 获取数字宽度
## Get the number width
func _get_number_width(font: Font, font_size: int, n: int) -> float:
	var max_width: float = 0
	for i in range(n):
		var num_str = str(i + 1);
		var num_size = font.get_string_size(num_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		max_width = max(max_width, num_size.x)
	return max_width
