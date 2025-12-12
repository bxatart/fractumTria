extends Area2D

var bullet_impact_effect = preload("res://scenes/player/bullet_impact.tscn")

@onready var bulletAnim: AnimatedSprite2D = $AnimatedSprite2D
@onready var bulletCollision: CollisionShape2D = $CollisionShape2D

@export var timer: float = 4.0 #Temporitzador

var speed: int = 100 #Velocitat
var direction: float = 1.0
var color: GameState.color = GameState.color.GREEN

var damage_amount: int = 1

func _ready() -> void:
	add_to_group("bullets")
	get_tree().create_timer(timer).timeout.connect(queue_free)

func setup(new_direction: float, new_color: GameState.color) -> void:
	direction = new_direction
	color = new_color
	print("BALA setup -> direction:", direction, " color:", color)
	change_color()

#Moure la bala
func _physics_process(delta) -> void:
	position.x += direction * speed * delta

#Color i sentit de la bala
func change_color() -> void:
	#Dona la volta a l'animació si va cap a l'esquerra
	bulletAnim.flip_h = direction < 0
	#Nom del color actual
	var color_name: String = GameState.get_color_name(color)
	#Canvia el color segons el color del jugador
	bulletAnim.play("shot_%s" % color_name)

#Impacte de la bala
func _on_hitbox_area_entered(area: Area2D) -> void:
	print("Bullet area entered: ", area.name)
	bullet_impact()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Bullet body entered: ", body.name)
	bullet_impact()

func get_damage_amount() -> int:
	return damage_amount

func bullet_impact() -> void:
	#So
	Sound.playEnemySfx("enemyDamage", global_position)
	var bullet_impact_instance: Node2D = bullet_impact_effect.instantiate()
	bullet_impact_instance.global_position = global_position
	get_parent().add_child(bullet_impact_instance)
	if bullet_impact_instance.has_method("setup"):
		bullet_impact_instance.setup(direction, color)
	queue_free()
