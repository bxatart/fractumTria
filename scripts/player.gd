extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D
@onready var green_platforms:= $"../TileMapLayerGreen"
@onready var orange_platforms:= $"../TileMapLayerOrange"
@onready var purple_platforms:= $"../TileMapLayerPurple"
@onready var muzzle : Marker2D = $Muzzle
@onready var hurtbox: Area2D = $Hurtbox

@export var speed: float = 180.0 #velocitat
@export var jump: float = 400.0 #força de salt
@export var gravity: float = 1200.0 #gravetat
@export var health: int = 100 #vida
@export var knockback: float = 250.0 #força del knockback

#Dany al jugador
var is_hurt : bool = false

#variables per guardar els valors
var last_dir: float = 1.0 #direcció
var base_speed: float
var base_jump: float
var base_gravity: float

#Colors
var colors: Array[GameState.color] = [
	GameState.color.GREEN, 
	GameState.color.ORANGE, 
	GameState.color.PURPLE]
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
	if is_hurt:
		player_falling(delta)
		move_and_slide()
		return
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
		var new_color: GameState.color = colors[color_index]
		GameState.set_color(new_color)
		change_collision_layer()
		change_physics()
		print("Color actual: ", GameState.get_color_name(GameState.current_color))

#Canvi de color per col·lisió amb onada enemiga
func wave_change_color(new_color: GameState.color) -> bool:
	#Si el jugador és del mateix color que l'onada
	if GameState.current_color == new_color:
		return false
	#Actualitza l'estat del color
	GameState.set_color(new_color)
	#Actualitza l'index
	var i = colors.find(new_color)
	if i != -1:
		color_index = i
	else:
		color_index = 0
	#Actualitza física i col·lisions
	change_physics()
	change_collision_layer()
	print("WAVE: Color canviat a: ", GameState.get_color_name(GameState.current_color))
	return true

#Canvia la física segons el color del jugador
func change_physics() -> void:
	match GameState.current_color:
		GameState.color.GREEN:
			#Normal
			speed = base_speed
			jump = base_jump #2 tiles
			gravity = base_gravity
		GameState.color.ORANGE:
			#Més pesat
			speed = base_speed - 20
			jump = base_jump - 60 #1 tile
			gravity = base_gravity + 400
		GameState.color.PURPLE:
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
	if global_position.y > 600:
		respawn()

func player_idle(delta: float) -> void:
	if is_on_floor():
		current_state = State.idle
		#print("Player State: ", State.keys()[current_state])

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
		#print("Player State: ", State.keys()[current_state])
	#Salt
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump

func player_shoot(delta: float) -> void:
	if last_dir  != 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance: Area2D = bullet.instantiate()
		#Posició d'inici de la bala
		bullet_instance.global_position = muzzle.global_position
		#Afegeix la bala a l'escena
		get_parent().add_child(bullet_instance)
		#Direcció i color de la bala
		bullet_instance.setup(last_dir, GameState.current_color)
		current_state = State.shoot
		#Temporitzador
		shoot_timer = 0.15
		print("Player State: ", State.keys()[current_state])

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
	if is_hurt:
		return
	#Color actual
	var color_name: StringName = GameState.get_color_name(GameState.current_color)
	match current_state:
		State.idle:
			#Atura l'animació si el jugador no es mou
			anim.play("idle_%s" % color_name)
		State.run:
			#Animació de moviment
			anim.play("run_%s" % color_name)
		State.shoot:
			#Animació de disparar
			anim.play("shoot_%s" % color_name)
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
	set_collision_mask_value(1, GameState.get_color_name(GameState.current_color) == "green")
	#Taronja
	set_collision_mask_value(2, GameState.get_color_name(GameState.current_color) == "orange")
	#Lila
	set_collision_mask_value(3, GameState.get_color_name(GameState.current_color) == "purple")

#PROVA - Torna a la posició inicial si el jugador cau
func respawn() -> void:
	#Esborra les bales
	get_tree().call_group("bullets", "queue_free")
	#Torna el jugador a l'inici
	global_position = spawn_position
	velocity = Vector2.ZERO
	color_index = 0
	GameState.set_color(colors[color_index])
	last_dir = 1.0
	change_physics()
	change_collision_layer()

#Si s'ha tocat el jugador
func hit_feedback() -> void:
	if is_hurt:
		return
	is_hurt = true
	anim.play("damage")
	await anim.animation_finished
	is_hurt = false
	#Torna a l'animació anterior
	get_anim(0.0)

func apply_knockback(from_node: Node) -> void:
	#Direcció contraria a la de l'enemic
	var dir = sign(global_position.x - from_node.global_position.x)
	#Si el jugador i l'enemic estan a la mateixa posició
	if dir == 0:
		dir = -sign(last_dir)
	#Moviment enrera
	velocity.x = dir * knockback
	#Salt enrera
	velocity.y = -jump * 0.4

#Dany al jugador
func take_damage(amount: int, from_node: Node) -> void:
	health -= amount
	print("Player Health: ", health)
	apply_knockback(from_node)
	hit_feedback()
	if health <= 0:
		die()

func die() -> void:
	print("Player DEATH")
	#PROVA - Utilitzo el respawn i restableixo la vida inicial
	respawn()
	health = 100

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies"):
		take_damage(10, enemy)
