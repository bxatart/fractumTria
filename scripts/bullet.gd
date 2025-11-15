extends AnimatedSprite2D

var speed: int = 100 #Velocitat
var direction: float = 1.0
var color: StringName = "green"

func _ready() -> void:
	add_to_group("bullets")

func setup(new_direction: float, new_color: StringName) -> void:
	direction = new_direction
	color = new_color
	print("BALA setup -> direction:", direction, " color:", color)
	change_color()

#Moure la bala
func _physics_process(delta) -> void:
	move_local_x(direction * speed * delta)

#Color i sentit de la bala
func change_color() -> void:
	#Dona la volta a l'animació si va cap a l'esquerra
	flip_h = direction < 0
	#Canvia el color segons el color del jugador
	match color:
		"green":
			play("shot_green")
		"orange":
			play("shot_orange")
		"purple":
			play("shot_purple")

#Connecta el timer amb la bala
func _on_timer_timeout() -> void:
	#Esborrar la bala
	queue_free()
