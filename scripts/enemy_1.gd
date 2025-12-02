extends CharacterBody2D

var enemy_death_effect = preload("res://scenes/enemy_1_death.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer = $Timer

@export var enemy_color: GameState.color = GameState.color.GREEN
@export var patrol_points: Node2D
@export var speed: float = 1500.0
@export var wait_time: int = 3
@export var health: int = 3

#Marcadors que limiten el moviment
var children: Array
var points_number: int
var point_positions: Array[Vector2] = []
var current_point: Vector2
var current_point_position: int
	
#Moviment
const gravity: float = 1000.0
var direction: Vector2 = Vector2.LEFT
var canMove: bool
var spawn_position: Vector2
	
#Estat de l'enemic
enum State { idle, move }
var current_state: State

func _ready() -> void:
	find_points()
	get_animation()
	#Assigna la durada al temporitzador
	timer.wait_time = wait_time
	#Estat inicial
	current_state =  State.idle
	#Guarda la posició inicial
	spawn_position = global_position

func _physics_process(delta: float) -> void:
	#Gestiona la caiguda
	enemy_gravity(delta)
	#Estat idle
	enemy_idle(delta)
	#Estat de moviment
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
	#PROVA - Torna l'enemic a la posició inicial
	if global_position.y > 800:
		respawn()

func enemy_idle(delta: float) -> void:
	if !canMove:
		#Redueix la velocitat fins aturar el moviment
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.idle

func enemy_move(delta: float) -> void:
	#Si no es pot moure, surt de la funció
	if !canMove:
		return
	#Si l'enemic està lluny del marcador de destí
	if abs(position.x - current_point.x) > 16:
		velocity.x = direction.x * speed * delta
		current_state = State.move
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
		anim.flip_h = direction.x > 0
		#No es pot moure
		canMove = false
		#Reinicia el timer
		timer.start()

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

#PROVA - Torna a la posició inicial si l'enemic cau
func respawn() -> void:
	global_position = spawn_position
	current_state = State.idle

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hurtbox area entered")
	if area.get_parent().has_method("get_damage_amount") and area.get_parent().color == enemy_color:
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
