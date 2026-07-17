class_name LineWrapIndex

var line: int
var wrap_index: int

func _init(line: int, wrap_index: int) -> void:
	self.line = line
	self.wrap_index = wrap_index


## 等于
## Equal to
func equals(other: LineWrapIndex) -> bool:
	return line == other.line and wrap_index == other.wrap_index
