class_name LineColumn

var line: int
var column: int

func _init(line: int, column: int) -> void:
	self.line = line
	self.column = column


## 等于
## Equal to
func equals(other: LineColumn) -> bool:
	return line == other.line and column == other.column


## 小于
## Less than
func less_than(other: LineColumn) -> bool:
	if line < other.line:
		return true
	elif line == other.line:
		if column < other.column:
			return true
	return false


## 大于
## Greater than
func greater_than(other: LineColumn) -> bool:
	if line > other.line:
		return true
	elif line == other.line:
		if column > other.column:
			return true
	return false


## 是否在 start 与 end 之间，左闭右开
## Is between start and end (left-closed, right-open)
func between(start: LineColumn, end: LineColumn) -> bool:
	return (greater_than(start) or equals(start)) and less_than(end)
