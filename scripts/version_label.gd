extends Label

func _ready():
	var version: String = ProjectSettings.get_setting("application/config/version") as String
	text = text.replace("1.0.0", version)
