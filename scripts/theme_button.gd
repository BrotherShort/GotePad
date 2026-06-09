extends CheckButton

var _root: Control:
	get: return $"/root/Control"

var _dark_theme: Theme = load("res://themes/gray_theme.res")
var _light_theme: Theme = load("res://themes/light_theme.res")

func _pressed() -> void:
	if is_pressed():
		_root.theme = _light_theme
	else:
		_root.theme = _dark_theme
