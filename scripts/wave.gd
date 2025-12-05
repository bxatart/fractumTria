extends Area2D

@onready var waveAnim: AnimatedSprite2D = $AnimatedSprite2D
@onready var wave_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var capsule_shape: CapsuleShape2D = wave_collision.shape

#Moviment
@export var speed: float = 100.0 #Velocitat
var velocity: Vector2 = Vector2.ZERO

#Color
var color: GameState.color = GameState.color.GREEN

#Col·lisió
var collision_sizes = [
	{ "radius": 3.0, "height": 6.0 }, #frame 0
	{ "radius": 3.0, "height": 10.0 }, #frame 1
	{ "radius": 3.0, "height": 14.0 }, #frame 2
	{ "radius": 3.0, "height": 18.0 }, #frame 3
	{ "radius": 3.0, "height": 30.0 }, #frame 4
	{ "radius": 3.0, "height": 40.0 }, #frame 5
]

func _ready() -> void:
	add_to_group("waves")
	#Ajustar la forma de col·lisió quan canvia de frame
	waveAnim.frame_changed.connect(frame_changed)
	#Animació inicial
	change_color()

func setup(new_direction: Vector2, new_color: GameState.color, new_speed: float = -1.0) -> void:
	color = new_color
	if new_speed > 0.0:
		velocity = new_direction.normalized() * new_speed
	else:
		velocity = new_direction.normalized() * speed
	print("WAVE setup: direction:", velocity, " color:", color, " speed:", new_speed)
	change_color()
	#Orientació de l'onada segons la direcció
	rotation = velocity.angle()

#Moure l'onada
func _physics_process(delta) -> void:
	position += velocity * delta

#Color de l'onada
func change_color() -> void:
	#Nom del color actual
	var color_name: String = GameState.get_color_name(color)
	#Canvia el color segons el color del jugador
	waveAnim.play("wave_%s" % color_name)

func frame_changed() -> void:
	var frame = waveAnim.frame
	#Modifica la mida de la collision shape cada cop que s'avanci un frame de l'animació
	if frame >= 0 and frame < collision_sizes.size():
		var data = collision_sizes[frame]
		capsule_shape.radius = data["radius"]
		capsule_shape.height = data["height"]

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#Esborra l'onada quan hagi sortit de la pantalla
	queue_free()

func wave_impact(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("wave_change_color"):
		var color_changed: bool = body.wave_change_color(color)
		if color_changed:
			#Destruir l'onada després de l'impacte
			queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Wave body entered: ", body.name)
	wave_impact(body)
