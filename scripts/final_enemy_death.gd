extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var gravity: float = 100.0
@export var speed: float = 200.0

var falling: bool = false

func _physics_process(delta: float) -> void:
	if not falling:
		return
	#Moviment per caure
	velocity.y = min(velocity.y + gravity * delta, speed)
	velocity.x = 0.0
	move_and_slide()
	#Parar de caure quan toqui al terra
	if is_on_floor():
		falling = false
		velocity = Vector2.ZERO

func play_death(color: int) -> void:
	var color_name: String = GameState.get_color_name(color)
	anim.play("death_%s" % color_name)
	falling = true

func _on_finish_trigger_body_entered(body: Node2D) -> void:
	print("ENEMY DEATH: body_entered: ", body.name)
	if not body.is_in_group("player"):
		return
	if body.is_in_group("player"):
		get_tree().call_group("baseLevel", "trigger_game_ending")
