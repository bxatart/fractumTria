extends Node2D

@onready var deathAnim: AnimatedSprite2D = $AnimatedSprite2D

var color: GameState.color = GameState.color.GREEN
var direction: float = 1.0

func setup(new_direction: float, new_color: GameState.color) -> void:
	direction = new_direction
	color = new_color
	change_color()

func change_color() -> void:
	if deathAnim == null:
		print("deathAnim és null")
		return
	#Dona la volta a l'animació si va cap a l'esquerra
	deathAnim.flip_h = direction < 0
	#Nom del color actual
	var color_name: String = GameState.get_color_name(color)
	#Canvia el color segons el color del jugador
	deathAnim.play("death_%s" % color_name)

func _on_timer_timeout() -> void:
	queue_free()
