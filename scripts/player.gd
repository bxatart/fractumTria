extends CharacterBody2D

@export var speed: float = 180.0 #velocitat
@export var jump: float = 400.0 #força de salt
@export var gravity: float = 1200.0 #gravetat
#variables per guardar els valors
var last_dir: float = 1.0 #direcció
var base_speed: float
var base_jump: float
var base_gravity: float

#Colors
var colors: Array[StringName] = ["green", "orange", "purple"]
var color_index: int = 0

#Variables per l'inclinació de l'animació
var tilt_angle: float = 10.0
var tilt_speed: float = 10.0

#Disparar
#Variable bala
var bullet = preload("res://scenes/bullet.tscn")
var muzzle_position
var shoot_timer: float = 0.0

#PROVA - Posició inicial
var spawn_position: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D
@onready var green_platforms:= $"../TileMapLayerGreen"
@onready var orange_platforms:= $"../TileMapLayerOrange"
@onready var purple_platforms:= $"../TileMapLayerPurple"
@onready var muzzle : Marker2D = $Muzzle

#Estat del jugador
enum State { idle, run, shoot }
var current_state: State

func _ready() -> void:
	current_state = State.idle
	#Guardar els valors de la física inicials
	base_speed = speed
	base_jump = jump
	base_gravity = gravity
	#Posició muzzle
	muzzle_position = muzzle.position
	#Comença amb el color verd
	GameState.set_color(colors[color_index])
	#Canvia la física segons el color
	change_physics()
	#Canvia la collision mask segons el color
	change_collision_layer()
	#PROVA - Guarda la posició inicial
	spawn_position = global_position

#Moviment jugador
func _physics_process(delta: float) -> void:
	#Controla el canvi de color
	change_color()
	#Mira si el jugador està a l'aire
	player_falling(delta)
	#Actualitza el temporitzador de disparar
	update_shoot_timer(delta)
	#Comprovar estat del jugador
	if shoot_timer == 0.0:
		player_idle(delta)
		player_run(delta)
	player_shoot(delta)
	#Mou
	move_and_slide()
	#Canvia animació segons l'estat
	get_anim(delta)

#Gestiona el canvi de color
func change_color() -> void:
	if Input.is_action_just_pressed("swap_color"):
		#Cicle infinit dels colors
		color_index = (color_index + 1) % colors.size()
		var new_color: StringName = colors[color_index]
		GameState.set_color(new_color)
		change_collision_layer()
		change_physics()
		print("Color actual: ", new_color)

#Canvia la física segons el color del jugador
func change_physics() -> void:
	match GameState.current_color:
		"green":
			#Normal
			speed = base_speed
			jump = base_jump #2 tiles
			gravity = base_gravity
		"orange":
			#Més pesat
			speed = base_speed - 20
			jump = base_jump - 60 #1 tile
			gravity = base_gravity + 400
		"purple":
			#Més lleuger
			speed = base_speed + 20
			jump = base_jump + 60 #4 tiles
			gravity = base_gravity - 400

func player_falling(delta: float) -> void:
	#Cau si el personatge està a l'aire
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = max(velocity.y, 0.0)
	#PROVA - Si el personatge ha caigut, el torna a la posició inicial
	if global_position.y > 800:
		respawn()

func player_idle(delta: float) -> void:
	if is_on_floor():
		current_state = State.idle
		print("State: ", State.keys()[current_state])

func player_run(delta: float) -> void:
	#Moviment lateral
	var dir := Input.get_axis("move_left", "move_right")
	if dir:
		velocity.x = dir * speed
		last_dir = dir
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if dir != 0:
		current_state = State.run
		print("State: ", State.keys()[current_state])
	#Salt
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump

func player_shoot(delta: float) -> void:
	if last_dir  != 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance: AnimatedSprite2D = bullet.instantiate()
		#Posició d'inici de la bala
		bullet_instance.global_position = muzzle.global_position
		#Direcció i color de la bala
		bullet_instance.setup(last_dir, GameState.current_color)
		#Afegeix la bala a l'escena
		get_parent().add_child(bullet_instance)
		current_state = State.shoot
		#Temporitzador
		shoot_timer = 0.15
		print("State: ", State.keys()[current_state])

func update_shoot_timer(delta: float) -> void:
	if shoot_timer > 0.0:
		#Compte enrere
		shoot_timer -= delta
		#Mira si ha acabat el temporitzador
		if shoot_timer <= 0.0:
			shoot_timer = 0.0
			#Mura si es mou o no el jugador i canvia a l'estat que toqui
			if abs(velocity.x) > 0.1:
				current_state = State.run
			else:
				current_state = State.idle

func get_anim(delta: float) -> void:
	#Color actual
	var color: StringName = GameState.current_color
	match current_state:
		State.idle:
			#Atura l'animació si el jugador no es mou
			anim.play("idle_%s" % color)
		State.run:
			#Animació de moviment
			anim.play("run_%s" % color)
		State.shoot:
			#Animació de disparar
			anim.play("shoot_%s" % color)
	#Dona la volta a l'sprite si el jugador va cap a l'esquerra
	anim.flip_h = last_dir < 0
	#Dona la volta al muzzle si el jugador va cap a l'esquerra
	if last_dir != 0:
		muzzle.position.x = abs(muzzle_position.x) * last_dir
	#Rota l'sprite
	var target_tilt := 0.0
	target_tilt = deg_to_rad(tilt_angle) * sign(velocity.x)
	#Rotació suau
	var t: float = clamp(delta * tilt_speed, 0.0, 1.0)
	anim.rotation = lerp_angle(anim.rotation, target_tilt, t)

#Canvia la Collision Mask segons el color del jugador
func change_collision_layer() -> void:
	#Verd
	set_collision_mask_value(1, GameState.current_color == "green")
	#Taronja
	set_collision_mask_value(2, GameState.current_color == "orange")
	#Lila
	set_collision_mask_value(3, GameState.current_color == "purple")

#PROVA - Torna a la posició inicial si el jugador cau
func respawn() -> void:
	#Esborra les bales
	get_tree().call_group("bullets", "queue_free")
	#Torna el jugador a l'inici
	global_position = spawn_position
	velocity = Vector2.ZERO
	color_index = 0
	GameState.set_color(colors[0])
	last_dir = 1.0
	change_physics()
	change_collision_layer()
