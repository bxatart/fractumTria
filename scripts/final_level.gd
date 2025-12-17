extends BaseLevel

@onready var final_enemy: CharacterBody2D = $Enemies/finalEnemy

func _ready() -> void:
	super._ready()
	Sound.playMusic("finalLevel")
	hud.setup_healthbar(final_enemy.max_health)
	final_enemy.health_changed.connect(hud.update_healthbar)
	final_enemy.died.connect(hud.hide_healthbar)
