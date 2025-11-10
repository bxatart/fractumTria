extends CharacterBody2D

@export var speed: float = 200.0 #velocitat
@export var jump: float = 300.0 #força de salt
@export var gravity: float = 400.0 #gravetat

#Variables per l'inclinació de l'animació
var tilt_angle: float = 10.0
var tilt_speed: float = 10.0

#PROVA - Posició inicial
var spawn_position: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D

#Estat del jugador
enum State { idle, run }
var current_state

func _ready():
	current_state = State.idle
	#PROVA - Guarda la posició inicial
	spawn_position = global_position

#Moviment jugador
func _physics_process(delta):
	#Mira si el jugador està a l'aire
	player_falling(delta)
	#Comprovar estat del jugador
	player_idle(delta)
	player_run(delta)
	#Mou
	move_and_slide()
	#Canvia animació segons l'estat
	get_anim(delta)

func player_falling(delta):
	#Cau si el personatge està a l'aire
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = max(velocity.y, 0.0)
	#PROVA - Si el personatge ha caigut, el torna a la posició inicial
	if global_position.y > 800:
		respawn()

func player_idle(delta):
	if is_on_floor():
		current_state = State.idle
		print("State: ", State.keys()[current_state])

func player_run(delta):
	#Moviment lateral
	var dir := Input.get_axis("ui_left", "ui_right")
	if dir:
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if dir != 0:
		current_state = State.run
		print("State: ", State.keys()[current_state])
	#Salt
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump

func get_anim(delta):
	if current_state == State.idle:
		#Atura l'animació si el jugador no es mou
		anim.play("idle_green")
	elif current_state == State.run:
		#Animació de moviment
		anim.play("idle_green")
		#Dona la volta a l'sprite si el jugador va cap a l'esquerra
		anim.flip_h = velocity.x < 0
	#Rota l'sprite
	var target_tilt := 0.0
	target_tilt = deg_to_rad(tilt_angle) * sign(velocity.x)
	#Rotació suau
	var t: float = clamp(delta * tilt_speed, 0.0, 1.0)
	anim.rotation = lerp_angle(anim.rotation, target_tilt, t)

#PROVA - Torna a la posició inicial si el jugador cau
func respawn():
	global_position = spawn_position
	velocity = Vector2.ZERO
