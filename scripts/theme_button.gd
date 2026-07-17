extends CheckButton

var _dark_theme: Theme = load("res://themes/gray_theme.res")
var _light_theme: Theme = load("res://themes/light_theme.res")

func _pressed() -> void:
	if is_pressed():
		owner.theme = _light_theme
	else:
		owner.theme = _dark_theme
