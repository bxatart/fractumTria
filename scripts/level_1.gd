extends BaseLevel

func _ready() -> void:
	super._ready()
	Sound.playMusic("level1")

func translation_text() -> void:
	tr("MOVE: ← → / A D")
	tr("JUMP: ↑ / W")
	tr("SWITCH COLOR: Z / K")
	tr("SWITCH COLOR: Z / K")
	tr("SHOOT: X / J")
	tr("DOUBLE SWITCH: Z Z / K K")
