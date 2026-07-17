class_name MenuHelper

## 将参数转换为快捷键
## Convert the parameters to a shortcut
static func get_shortcut(key: Key, need_shift: bool = false, need_ctrl: bool = true) -> Shortcut:
	var input_event_key = InputEventKey.new()
	input_event_key.keycode = key
	input_event_key.ctrl_pressed = need_ctrl
	input_event_key.shift_pressed = need_shift

	var shortcut = Shortcut.new()
	shortcut.events = [input_event_key]

	return shortcut
