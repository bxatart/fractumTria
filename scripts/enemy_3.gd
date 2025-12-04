extends CharacterBody2D

var enemy_death_effect = preload("res://scenes/enemies/enemy_3_death.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer = $Timer
@onready var muzzle : Marker2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer

@export var enemy_color: GameState.color = GameState.color.GREEN
@export var patrol_points: Node2D
@export var speed: float = 50.0
@export var wait_time: int = 3
@export var wave_amp: float = 16.0 #Alçada d'ona
@export var wave_speed: float = 4.0 #Velocitat d'ona
@export var health: int = 6

var feedback: bool = false

#Jugador
var player: Node2D = null
var detection_range: float = 500.0 #Distància per detectar el jugador

#Marcadors que limiten el moviment
var children: Array
var points_number: int
var point_positions: Array[Vector2] = []
var current_point: Vector2
var current_point_position: int
	
#Moviment
var direction: Vector2 = Vector2.LEFT
var canMove: bool
var spawn_position: Vector2
var wave_time: float = 0.0
var base_y: float = 0.0

#Disparar
#Variable onada
var wave = preload("res://scenes/enemies/wave.tscn")
var muzzle_position
var prev_state: State
var prev_canMove: bool

#Estat de l'enemic
enum State { idle, move, shoot }
var current_state: State

func _ready() -> void:
	add_to_group("enemies")
	#Busca el jugador a l'escena
	find_player()
	#Busca els marcadors
	find_points()
	get_animation()
	canMove = true
	anim.flip_h = direction.x < 0
	#Assigna la durada als temporitzadors
	timer.wait_time = wait_time
	shoot_timer.wait_time = 5.0
	shoot_timer.start()
	#Guardar posició inicial y
	base_y = global_position.y
	#Posició muzzle
	muzzle_position = muzzle.position
	#Estat inicial
	current_state =  State.idle

func _physics_process(delta: float) -> void:
	if current_state != State.shoot:
		#Estat idle
		enemy_idle(delta)
		#Estat de moviment
		enemy_move(delta)
	else:
		#Atura el moviment si està disparant
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.y = 0
	#Mou l'enemic
	move_and_slide()
	#Agafa l'animació segons l'estat i el color assignat
	get_animation()

func enemy_idle(delta: float) -> void:
	if !canMove:
		#Redueix la velocitat fins aturar el moviment
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.y = 0
		current_state = State.idle
		#print("ENEMY3 State: ", State.keys()[current_state])

func enemy_move(delta: float) -> void:
	#Si no es pot moure, surt de la funció
	if !canMove:
		return
	#Si l'enemic està lluny del marcador de destí
	if abs(position.x - current_point.x) > 16:
		velocity.x = direction.x * speed
		current_state = State.move
		#print("ENEMY3 State: ", State.keys()[current_state])
	#Si l'enemic està al marcador de destí
	else:
		current_point_position += 1
		#Bucle per anar canviant d'un marcador a l'altre
		if current_point_position >= points_number:
			current_point_position = 0
		#Canvia el marcador de destí
		current_point = point_positions[current_point_position]
		#Canvia la direcció
		if current_point.x > position.x:
			direction = Vector2.RIGHT
		
		else:
			direction = Vector2.LEFT
		#No es pot moure
		canMove = false
		#Reinicia el timer
		timer.start()
	#Moviment d'ona
	wave_time += delta
	var target_y := base_y + sin(wave_time * wave_speed) * wave_amp
	velocity.y = (target_y - global_position.y) / delta

func enemy_shoot() -> void:
	if player == null:
		return
	print("ENEMY3 dispara")
	var wave_instance : Area2D = wave.instantiate()
	#Afegeix l'onada a l'escena
	get_parent().add_child(wave_instance)
	#Posició d'inici de l'onada
	wave_instance.global_position = muzzle.global_position
	#Direcció cap al jugador
	var dir: Vector2 = player.global_position - muzzle.global_position
	wave_instance.setup(dir, enemy_color)

func get_animation() -> void:
	var color_name: String = GameState.get_color_name(enemy_color)
	var targetAnim = ""
	#Canvia l'animació i el color segons l'estat i el color seleccionat a l'inspector
	match current_state:
		State.idle:
			targetAnim = "idle_%s" % color_name
		State.move:
			targetAnim = "move_%s" % color_name
		State.shoot:
			targetAnim = "shoot_%s" % color_name
	#Canvia l'animació si és diferent a l'actual
	if anim.animation != targetAnim:
		anim.play(targetAnim)

func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("Enemy3: No s'ha trobat cap jugador a l'escena")
	else:
		print(player)

func find_points() -> void:
	#Troba la posició dels marcadors
	children = patrol_points.get_children()
	points_number = children.size()
	print("Fills de patrol_points: ", children)
	#Si no té marcadors
	if points_number == 0:
		print("No hi ha marcadors")
		return
	#Afegeix la posició dels marcadors a l'array
	for point in children:
		point_positions.append(point.global_position)
	current_point = point_positions[current_point_position]
	print("Punts de patrol: ", point_positions)

func _on_timer_timeout() -> void:
	canMove = true
	anim.flip_h = direction.x < 0

func _on_shoot_timer_timeout() -> void:
	#Si no hi ha jugador no dispara
	if player == null:
		return
	#Si ja està en estat de disparar
	if current_state == State.shoot:
		return
	#Si està lluny del jugador no dispara
	var distance := global_position.distance_to(player.global_position)
	if distance >= detection_range:
		return
	#Guardar estats anteriors a disparar
	prev_state = current_state
	print("ENEMY3 Prev State: ", State.keys()[prev_state])
	prev_canMove = canMove
	#Aturar el moviment
	canMove = false
	velocity = Vector2.ZERO
	current_state = State.shoot
	print("ENEMY3 State: ", State.keys()[current_state])
	get_animation()
	#Esperar a que acabi l'animació
	await anim.animation_finished
	#Dispara
	enemy_shoot()
	#Torna a l'estat anterior
	current_state = prev_state
	canMove = prev_canMove
	#Actualitza animació
	get_animation()

#Posa l'animació en gris si s'ha tocat l'enemic
func hit_feedback() -> void:
	if feedback:
		return
	feedback = true
	#Animació en gris
	anim.self_modulate = Color(0.5, 0.5, 0.5, 1.0)
	#Temporitzador
	await get_tree().create_timer(0.15).timeout
	#Torna al color normal si no s'ha eliminat l'enemic
	if not is_queued_for_deletion():
		anim.self_modulate = Color(1, 1, 1, 1)
	feedback = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hurtbox area entered")
	if area.get_parent().has_method("get_damage_amount") and area.get_parent().color != enemy_color:
		var node: Node = area.get_parent()
		health -= node.damage_amount
		print("Health: ", health)
		if health <= 0:
			var enemy_death_instance: Node2D = enemy_death_effect.instantiate()
			enemy_death_instance.global_position = anim.global_position
			get_parent().add_child(enemy_death_instance)
			if enemy_death_instance.has_method("setup"):
				enemy_death_instance.setup(direction.x, enemy_color)
			queue_free()
		else:
			hit_feedback()
