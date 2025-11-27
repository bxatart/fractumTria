extends Area2D

@onready var bulletAnim: AnimatedSprite2D = $AnimatedSprite2D
@onready var bulletCollision: CollisionShape2D = $CollisionShape2D

var speed: int = 100 #Velocitat
var direction: float = 1.0
var color: StringName = "green"

#Destrucció de la bala
var destroyed: bool = false

func _ready() -> void:
	add_to_group("bullets")
	#Connectar el senyal de col·lisió
	body_entered.connect(on_collision)

func setup(new_direction: float, new_color: StringName) -> void:
	direction = new_direction
	color = new_color
	print("BALA setup -> direction:", direction, " color:", color)
	change_color()

#Moure la bala
func _physics_process(delta) -> void:
	if destroyed:
		return
	position.x += direction * speed * delta

#Color i sentit de la bala
func change_color() -> void:
	#Dona la volta a l'animació si va cap a l'esquerra
	bulletAnim.flip_h = direction < 0
	#Canvia el color segons el color del jugador
	match color:
		"green":
			bulletAnim.play("shot_green")
		"orange":
			bulletAnim.play("shot_orange")
		"purple":
			bulletAnim.play("shot_purple")

#Destrucció de la bala
func destroy_bullet() -> void:
	if destroyed:
		return
	destroyed = true
	#Desactivar col·lisions
	bulletCollision.disabled = true
	match color:
		"green":
			bulletAnim.play("shot_destroy_green")
		"orange":
			bulletAnim.play("shot_destroy_orange")
		"purple":
			bulletAnim.play("shot_destroy_purple")
	await bulletAnim.animation_finished
	queue_free()

#Connecta el timer amb la bala
func _on_timer_timeout() -> void:
	if destroyed:
		return
	#Esborrar la bala
	queue_free()

#Quan detecta col·lisió
func on_collision(body: Node) -> void:
	if destroyed:
		return
	if body is TileMapLayer:
		destroy_bullet()
