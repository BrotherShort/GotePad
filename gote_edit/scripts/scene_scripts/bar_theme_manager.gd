extends Control

## 控件样式来源
## Control stylebox source
enum StyleBoxSource {
	## 来源于 theme
	## From the theme
	THEME, 
	## 来源于 theme override
	## From the theme override
	OVERRIDE,
}

## 用于记录文本编辑控件 stylebox 信息的内部类
## Internal class used to store the stylebox information for the text edit node
class EditStyleBox:
	## 来源
	## Source
	var source: StyleBoxSource
	## StyleBox
	## StyleBox
	var stylebox: StyleBox


## 常规状态下（无搜索栏）gote edit 使用的 stylebox
## The stylebox used by the gote edit node under normal conditions (without the Find Replace bar)
var edit_stylebox: EditStyleBox

## 显示搜索栏时使用的 stylebox
## The stylebox used when the Find Replace bar is visible
var bar_stylebox: StyleBox

var _gote_edit: GoteEdit:
	get: return owner
var _bar: FindReplaceBar:
	get: return %FindReplaceBar

func _process(_delta: float) -> void:
	get_edit_theme()
	set_edit_theme()
	

## 获取 gote edit 的主题
## Get the gote edit's theme
func get_edit_theme():
	var current_edit_stylebox: EditStyleBox = EditStyleBox.new()
	var has_override: bool = _gote_edit.has_theme_stylebox_override("normal")
	if has_override:
		var override_styebox: StyleBox = _gote_edit.get_theme_stylebox("normal")
		if override_styebox == bar_stylebox:
			# 需要从override之下获取来自theme的stylebox
			# 而本节点是_gote_edit的子节点，theme与_gote_edit一致，
			# 所以可以从中获取_gote_edit的theme的stylebox
			current_edit_stylebox.stylebox = get_theme_stylebox("normal", "TextEdit")
			current_edit_stylebox.source = StyleBoxSource.THEME
		else:
			current_edit_stylebox.stylebox = override_styebox
			current_edit_stylebox.source = StyleBoxSource.OVERRIDE
	else:
		current_edit_stylebox.stylebox = _gote_edit.get_theme_stylebox("normal")
		current_edit_stylebox.source = StyleBoxSource.THEME

	if edit_stylebox == null or \
		current_edit_stylebox.stylebox != edit_stylebox.stylebox or \
		current_edit_stylebox.source != edit_stylebox.source:
		edit_stylebox = current_edit_stylebox

		bar_stylebox = edit_stylebox.stylebox.duplicate()
		var height: int = $%BgContainer1.size.y
		bar_stylebox.set_content_margin(SIDE_BOTTOM, height)


## 设置 gote edit 的主题
## Set the gote edit's theme
func set_edit_theme():
	if _bar.visible:
		var current_edit_stylebox: StyleBox = _gote_edit.get_theme_stylebox("normal")
		if current_edit_stylebox != bar_stylebox:
			_gote_edit.add_theme_stylebox_override("normal", bar_stylebox)
	else:
		if edit_stylebox.source == StyleBoxSource.THEME:
			var has_override: bool = _gote_edit.has_theme_stylebox_override("normal")
			if has_override:
				_gote_edit.remove_theme_stylebox_override("normal")
		else: # StyleBoxSource.OVERRIDE
			var current_edit_stylebox: StyleBox = _gote_edit.get_theme_stylebox("normal")
			if current_edit_stylebox != edit_stylebox.stylebox:
				_gote_edit.add_theme_stylebox_override("normal", edit_stylebox.stylebox)
