extends CharacterBody2D

var enemy_death_effect = preload("res://scenes/enemies/enemy_2_death.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_check_left: RayCast2D = $FloorCheckLeft
@onready var floor_check_right: RayCast2D = $FloorCheckRight
@onready var wall_check_left: RayCast2D = $WallCheckLeft
@onready var wall_check_right: RayCast2D = $WallCheckRight
@onready var body_col: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_col: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var stun_timer: Timer = $stunTimer

@export var enemy_color: GameState.color = GameState.color.GREEN
@export var speed: float = 50.0
@export var jump: float = 400.0 #Força del salt
@export var health: int = 5

var feedback: bool = false
var stunned: bool = false

#Jugador
var player: Node2D = null

#Moviment
var gravity: float = 1000.0
var detection_range: float = 400.0 #Distància per detectar el jugador
var canMove: bool
var spawn_position: Vector2
var base_jump
var base_speed
var base_gravity
var facing_dir: float = 1.0 #Direcció

#Estat de l'enemic
enum State { idle, move }
var current_state: State

#Estat inicial
var base_pos: Vector2
var base_health: int
var dead: bool = false
var base_color: GameState.color
var body_layer: int
var body_mask: int
var hurtbox_layer: int
var hurtbox_mask: int

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("respawnable_enemies")
	#Guardar l'estat inicial
	base_pos = global_position
	base_health = health
	base_color = enemy_color
	body_layer = collision_layer
	body_mask = collision_mask
	hurtbox_layer = hurtbox.collision_layer
	hurtbox_mask = hurtbox.collision_mask
	#Busca el jugador a l'escena
	find_player()
	#Animació inicial de l'enemic
	get_animation()
	#Guarda la posició inicial
	spawn_position = global_position
	#Guarda valors inicials
	base_speed = speed
	base_jump = jump
	base_gravity = gravity
	#Canvia els valors segons el color de l'enemic
	change_physics()

func _physics_process(delta: float) -> void:
	#Gestiona la caiguda
	enemy_gravity(delta)
	if stunned:
		move_and_slide()
		get_animation()
		return
	#Estat de l'enemic
	update_state()
	match current_state:
		#Estat idle
		State.idle:
			enemy_idle(delta)
		#Estat de moviment
		State.move:
			enemy_move(delta)
	#Mou l'enemic
	move_and_slide()
	#Agafa l'animació segons l'estat i el color assignat
	get_animation()

func get_animation() -> void:
	var color_name: String = GameState.get_color_name(enemy_color)
	#Canvia l'animació i el color segons l'estat i el color seleccionat a l'inspector
	if current_state == State.idle && !canMove:
		anim.play("idle_%s" % color_name)
	elif current_state == State.move && canMove:
		anim.play("move_%s" % color_name)

func enemy_gravity(delta: float) -> void:
	#Cau si el personatge està a l'aire
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = max(velocity.y, 0.0)
	#Torna l'enemic a la posició inicial
	if global_position.y > 800:
		respawn()

func update_state() -> void:
	#Si no hi ha jugador a l'escena
	if player == null:
		canMove = false
		current_state = State.idle
		return
	#Distància entre el jugador i l'enemic
	var distance = global_position.distance_to(player.global_position)
	if distance <= detection_range:
		canMove = true
		current_state = State.move
	else:
		canMove = false
		current_state = State.idle

func enemy_idle(delta: float) -> void:
	if !canMove:
		#Redueix la velocitat fins aturar el moviment
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.idle

func enemy_move(delta: float) -> void:
	#Si no es pot moure o no hi ha jugador, surt de la funció
	if !canMove or player == null:
		return
	#Direcció segons la posició del jugador
	var dir: float = sign(player.global_position.x - global_position.x)
	
	if dir == 0.0:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta)
		return
	#Mirar si té plataformes a sota o a davant
	var floor_ahead = check_floor(dir)
	var wall_ahead = check_wall(dir)
	if is_on_floor():
		#Salta si hi ha paret o no hi ha plataforma
		if wall_ahead or not floor_ahead:
			velocity.y = -jump
	velocity.x = dir * speed	
	facing_dir = dir
	anim.flip_h = dir < 0

func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ENEMY2: No s'ha trobat cap jugador a l'escena")
	else:
		print(player)

#Canvia la física segons el color de l'enemic
func change_physics() -> void:
	#PROVA - Mateixos valors que al jugador
	match GameState.current_color:
		GameState.color.GREEN:
			#Normal
			speed = base_speed
			jump = base_jump #2 tiles
			gravity = base_gravity
		GameState.color.ORANGE:
			#Més pesat
			speed = base_speed - 20
			jump = base_jump - 40 #1 tile
			gravity = base_gravity + 200
		GameState.color.PURPLE:
			#Més lleuger
			speed = base_speed + 20
			jump = base_jump + 20 #4 tiles
			gravity = base_gravity - 100
		
#Mira si hi ha plataformes a sota de l'enemic
func check_floor(dir: float) -> bool:
	if dir < 0.0:
		return floor_check_left.is_colliding()
	else:
		return floor_check_right.is_colliding()

#Mira si hi ha plataformes davant de l'enemic
func check_wall(dir: float) -> bool:
	if dir < 0.0:
		return wall_check_left.is_colliding()
	else:
		return wall_check_right.is_colliding()

#Torna a la posició inicial
func respawn() -> void:
	global_position = spawn_position
	current_state = State.idle

#Torna a posar l'enemic si el jugador cau o és eleminat
func revive() -> void:
	if not is_in_group("respawnable_enemies"):
		add_to_group("respawnable_enemies")
	if not dead:
		return
	dead = false
	#Estat original
	global_position = base_pos
	health = base_health
	enemy_color = base_color
	visible = true
	set_physics_process(true)
	set_process(true)
	velocity = Vector2.ZERO
	add_to_group("enemies")
	#Fer que el jugador el pugui detectar
	body_col.disabled = false
	hurtbox.monitoring = true
	hurtbox.monitorable = true
	hurtbox_col.disabled = false
	collision_layer = body_layer
	collision_mask = body_mask
	hurtbox.collision_layer = hurtbox_layer
	hurtbox.collision_mask = hurtbox_mask
	#Reinicia estat
	current_state = State.idle
	update_state()

func kill_enemy() -> void:
	#Amaga l'enemic
	dead = true
	visible = false
	set_physics_process(false)
	set_process(false)
	velocity = Vector2.ZERO
	remove_from_group("enemies")
	#Fer que el jugador no el pugui detectar
	body_col.disabled = true
	hurtbox.monitoring = false
	hurtbox.monitorable = false
	hurtbox_col.disabled = true
	collision_layer = 0
	collision_mask = 0
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 0

#Posa l'animació en gris si s'ha tocat l'enemic
func hit_feedback() -> void:
	if feedback:
		return
	feedback = true
	#Animació en gris
	anim.self_modulate = Color(0.5, 0.5, 0.5, 1.0)
	#So
	Sound.playEnemySfx("enemyDamage", global_position)
	#Temporitzador
	await get_tree().create_timer(0.15).timeout
	#Torna al color normal si no s'ha eliminat l'enemic
	if not is_queued_for_deletion():
		anim.self_modulate = Color(1, 1, 1, 1)
	feedback = false

func start_stun() -> void:
	if stunned or dead:
		return
	stunned = true
	canMove = false
	velocity.x = 0.0
	velocity.y = 0.0
	stun_timer.start()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("ENEMY2: Hurtbox area entered")
	if area.get_parent().has_method("get_damage_amount") and area.get_parent().color == enemy_color:
		var node: Node = area.get_parent()
		health -= node.damage_amount
		print("ENEMY2 Health: ", health)
		if health <= 0:
			#So
			Sound.playEnemySfx("enemyDeath", global_position)
			var enemy_death_instance: Node2D = enemy_death_effect.instantiate()
			enemy_death_instance.global_position = anim.global_position
			get_parent().add_child(enemy_death_instance)
			if enemy_death_instance.has_method("setup"):
				enemy_death_instance.setup(facing_dir, enemy_color)
			kill_enemy()
		else:
			hit_feedback()

func _on_stun_timer_timeout() -> void:
	stunned = false
	update_state()
