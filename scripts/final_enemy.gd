extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer = $patrolTimer
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var capsule_shape: CapsuleShape2D = hurtbox_collision.shape
@onready var shield_area: Area2D = $Shield
@onready var shield_sprite: Sprite2D = $Shield/shieldSprite
@onready var shield_impact: Sprite2D = $Shield/shieldImpact

@export var enemy_color: GameState.color = GameState.color.GREEN
@export var patrol_points: Node2D
@export var speed: float = 1500.0
@export var wave_speed: float = 200.0
@export var wait_time: int = 3
@export var max_health: int
var health: int
signal max_health_set(max_hp: int)
signal health_changed(current_hp: int)
signal died

#Escut
var shield_active: bool = true
var shield_running: bool = false
var shield_flash_running: bool = false
const bullet_layer = 5

#Mort
@export var death_scene: PackedScene = preload("res://scenes/enemies/final_enemy_death.tscn")

#Enemics
@export var enemy1_scene: PackedScene
@export var enemy2_scene: PackedScene
@export var enemy3_scene: PackedScene

#Punts de spawn
@export var groundSpawnPoints: Node2D
@export var topSpawnPoints: Node2D
@export var greenSpawnPoints: Node2D
@export var orangeSpawnPoints: Node2D
@export var purpleSpawnPoints: Node2D
var spawn_wave_size: int = 1

#Llistes de spawn points
var ground_markers: Array[Node2D] = []
var top_markers: Array[Node2D] = []
var ground_occupied: Dictionary = {}
var top_occupied: Dictionary = {}

#Ordre d'atacs
var attack_step : int = 0

var feedback: bool = false
var player: Node2D = null

#Marcadors que limiten el moviment
var children: Array
var points_number: int
var point_positions: Array[Vector2] = []
var current_point: Vector2
var current_point_position: int

#Moviment
var direction: Vector2 = Vector2.LEFT
var canMove: bool = true
var spawn_position: Vector2
var last_dir: float = 1.0 #direcció

#Variable onada
var wave = preload("res://scenes/enemies/wave.tscn")
var muzzle_position
var prev_state: State
var prev_canMove: bool

#Variables per l'inclinació de l'animació
var tilt_angle: float = 10.0
var tilt_speed: float = 10.0

#Estat de l'enemic
enum State { idle, move, shoot, spawn, change_color, death }
var current_state: State

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("final_boss")
	#Escut
	enable_shield()
	#Inicialitza vida i senyals
	health = max_health
	emit_signal("max_health_set", max_health)
	emit_signal("health_changed", health)
	#Busca el jugador a l'escena
	find_player()
	#Busca els marcadors
	find_points()
	#Assigna la durada als temporitzadors
	timer.wait_time = wait_time
	shoot_timer.wait_time = 5.0
	shoot_timer.start()
	#Estat inicial
	current_state =  State.idle
	#Posició muzzle
	muzzle_position = muzzle.position
	#Guarda la posició inicial
	spawn_position = global_position
	#Inicialitza llistes
	init_spawn_markers()
	#Connectar amb UI
	connect_hud()

func _physics_process(delta: float) -> void:
	if current_state == State.idle or current_state == State.move:
		#Estat idle
		enemy_idle(delta)
		#Estat de moviment
		enemy_move(delta)
	else:
		#Atura el moviment si està atacant o canviant de color
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.y = 0
	#Mou l'enemic
	move_and_slide()
	#Agafa l'animació segons l'estat i el color assignat
	get_animation(delta)

func get_animation(delta) -> void:
	var color_name: String = GameState.get_color_name(enemy_color)
	#Canvia l'animació i el color segons l'estat i el color seleccionat a l'inspector
	if current_state == State.idle:
		anim.play("idle_%s" % color_name)
	elif current_state == State.move:
		anim.play("idle_%s" % color_name)
	elif current_state == State.shoot:
		anim.play("attack_%s" % color_name)
	elif current_state == State.spawn:
		anim.play("attack2_%s" % color_name)
	elif current_state == State.change_color:
		anim.play("color_change")
	#Dona la volta a l'sprite si el jugador va cap a l'esquerra
	anim.flip_h = last_dir < 0
	#Dona la volta al muzzle si el jugador va cap a l'esquerra
	if last_dir != 0:
		muzzle.position.x = abs(muzzle_position.x) * last_dir
	#Rota l'sprite
	var target_tilt = 0.0
	target_tilt = deg_to_rad(tilt_angle) * sign(velocity.x)
	#Rotació suau
	var t: float = clamp(delta * tilt_speed, 0.0, 1.0)
	anim.rotation = lerp_angle(anim.rotation, target_tilt, t)
	hurtbox_collision.rotation = anim.rotation
	if shield_active:
		anim.self_modulate = Color(0.7, 0.9, 1.0, 1.0)
	else:
		anim.self_modulate = Color(1, 1, 1, 1)

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

func enemy_shoot() -> void:
	if player == null:
		return
	#Si està lluny del jugador no dispara
	var distance = global_position.distance_to(player.global_position)
	#Guardar estats anteriors a disparar
	prev_state = current_state
	print("FINAL ENEMY Prev State: ", State.keys()[prev_state])
	prev_canMove = canMove
	#Aturar el moviment
	canMove = false
	velocity = Vector2.ZERO
	current_state = State.shoot
	print("FINAL ENEMY State: ", State.keys()[current_state])
	get_animation(0.0)
	#Esperar a que acabi l'animació
	await anim.animation_finished
	print("FINAL ENEMY dispara")
	var wave_instance : Area2D = wave.instantiate()
	#Afegeix l'onada a l'escena
	get_parent().add_child(wave_instance)
	#Posició d'inici de l'onada
	wave_instance.global_position = muzzle.global_position
	#Direcció cap al jugador
	var dir: Vector2 = player.global_position - muzzle.global_position
	wave_instance.setup(dir, enemy_color, wave_speed)
	#So
	Sound.playEnemySfx("wave", global_position)
	#Torna a l'estat anterior
	current_state = prev_state
	canMove = prev_canMove
	#Actualitza animació
	get_animation(0.0)

#Tria un color aleatori
func get_random_color() -> GameState.color:
	var colors = [
		GameState.color.GREEN,
		GameState.color.ORANGE,
		GameState.color.PURPLE,
	]
	colors.erase(enemy_color)  # Elimina el color actual
	return colors[randi() % colors.size()]

#Color aleatori pels enemics creats
func get_random_enemy_color() -> GameState.color:
	var colors = [
		GameState.color.GREEN,
		GameState.color.ORANGE,
		GameState.color.PURPLE,
	]
	return colors[randi() % colors.size()]

func enemy_change_color(new_color: GameState.color) -> void:
	if new_color == enemy_color:
		return
	if current_state == State.change_color:
		return
	print("FINAL ENEMY: Canvia de color a ", GameState.get_color_name(new_color))
	#Guardar estat anterior
	prev_state = current_state
	prev_canMove = canMove
	#Atura moviment
	canMove = false
	velocity = Vector2.ZERO
	#Canvia l'estat
	current_state = State.change_color
	get_animation(0.0)
	#So
	Sound.playEnemySfx("enemyChangeColor", global_position)
	#Esperar a que acabi l'animació
	await anim.animation_finished
	enemy_color = new_color
	#Tornar a l'estat anterior
	current_state = prev_state
	canMove = prev_canMove
	#Actualitzar animació
	get_animation(0.0)

func enemy_spawn_attack() -> void:
	#Surt de la funció si ja està fent aquest atac
	if current_state == State.spawn:
		return
	print("FINAL ENEMY: inici atac spawn")
	#Guardar estat anterior
	prev_state = current_state
	prev_canMove = canMove
	#Atura moviment
	canMove = false
	velocity = Vector2.ZERO
	#Canvia l'estat
	current_state = State.spawn
	get_animation(0.0)
	#Nom de l'animació segons el color
	var color_name: String = GameState.get_color_name(enemy_color)
	var anim_name = "attack2_%s" % color_name
	#So
	Sound.playEnemySfx("enemySpawn", global_position)
	#Esperar a que acabi l'animació
	await anim.animation_finished
	#Tornar a la rotació original
	anim.rotation_degrees = 0.0
	#Genera enemics
	spawn_wave()
	#Tornar a l'estat anterior
	current_state = prev_state
	canMove = prev_canMove
	#Actualitzar animació
	get_animation(0.0)

#Spawn Point aleatori
func get_random_spawn_point(root: Node2D) -> Vector2:
	var children = root.get_children()
	var marker: Node = children[randi() % children.size()]
	return marker.global_position

#Spawn Point segons el color de l'enemic
func get_spawn_point_color(color: GameState.color) -> Node2D:
	match color:
		GameState.color.GREEN:
			return greenSpawnPoints
		GameState.color.ORANGE:
			return orangeSpawnPoints
		GameState.color.PURPLE:
			return purpleSpawnPoints
		_:
			return greenSpawnPoints

#Spawn enemics tipus 1, sempre verds i a GroundSpawnPosition
func spawn_enemy1() -> void:
	#Surt si no hi ha escena assignada
	if enemy1_scene == null:
		return
	#Tria un spawn point lliure
	var marker = find_ground_marker()
	if marker == null:
		print("SPAWN ENEMY1: No hi ha cap spawn point lliure")
		return
	#Crear enemic
	var enemy = enemy1_scene.instantiate()
	#Afegir l'enemic
	get_parent().add_child(enemy)
	#Posició de l'enemic
	enemy.global_position = marker.global_position
	enemy.find_points()
	#Marcar spawn point com a ocupat
	ground_occupied[marker] = enemy
	#Color de l'enemic
	enemy.enemy_color = GameState.color.GREEN

#Spawn enemics tipus 2, de qualsevol color però als SpawnPoints del seu color
func spawn_enemy2() -> void:
	#Surt si no hi ha escena assignada
	if enemy2_scene == null:
		return
	#Color aleatori per l'enemic
	var color = get_random_enemy_color()
	#Triar Spawn Points segons el color
	var spawn_points = get_spawn_point_color(color)
	#Crear enemic
	var enemy = enemy2_scene.instantiate()
	#Afegir l'enemic
	get_parent().add_child(enemy)
	if spawn_points != null:
		enemy.global_position = get_random_spawn_point(spawn_points)
	else:
		print("SPAWN ENEMY2: No hi ha spawn points assignats")
	#color de l'enemic
	enemy.enemy_color = color

#Spawn enemics tipus 3, de qualsevol color però a TopSpawnPoints
func spawn_enemy3() -> void:
	#Surt si no hi ha escena assignada
	if enemy3_scene == null:
		return
	#Color aleatori per l'enemic
	var color = get_random_enemy_color()
	#Tria un spawn point lliure
	var marker = find_top_marker()
	if marker == null:
		print("SPAWN ENEMY3: No hi ha cap spawn point lliure")
		return
	#Crear enemic
	var enemy = enemy3_scene.instantiate()
	#Color de l'enemic
	enemy.enemy_color = color
	#Afegir l'enemic
	get_parent().add_child(enemy)
	#Posició de l'enemic
	enemy.global_position = marker.global_position
	enemy.base_y = marker.global_position.y
	enemy.wave_time = 0.0
	enemy.find_points()
	#Marcar spawn point com a ocupat
	top_occupied[marker] = enemy

#Spawn enemic aleatori
func spawn_random_enemy() -> void:
	var enemy_type = randi() % 3
	match enemy_type:
		0:
			spawn_enemy1()
		1:
			spawn_enemy2()
		2:
			spawn_enemy3()

#Onada d'enemics
func spawn_wave() -> void:
	for i in range(spawn_wave_size):
		spawn_random_enemy()
	print("FINAL ENEMY: Spawn wave amb ", spawn_wave_size, "enemics")
	#Afegir un altre enemic a la següent onada
	spawn_wave_size += 1

func init_spawn_markers() -> void:
	ground_markers.clear()
	top_markers.clear()
	ground_occupied.clear()
	top_occupied.clear()
	#Afegeix marcadors a les llistes
	if groundSpawnPoints != null:
		for child in groundSpawnPoints.get_children():
			var marker: Node2D = child
			if marker != null:
				ground_markers.append(marker)
				ground_occupied[marker] = null
	if topSpawnPoints != null:
		for child in topSpawnPoints.get_children():
			var marker: Node2D = child
			if marker != null:
				top_markers.append(marker)
				top_occupied[marker] = null

#Busca un spawn point lliure
func find_ground_marker() -> Node2D:
	#Array per guardar els spawn points lliures
	var free : Array[Node2D] = []
	#Mirar al diccionari quin està ocupat
	for marker in ground_markers:
		var occupied = ground_occupied.get(marker, null)
		#Si no hi ha cap enemic o l'enemic s'ha eliminat
		if occupied == null or not is_instance_valid(occupied):
			#Afegim l'spawn point a la llista dels que no estan ocupats
			free.append(marker)
	#Si no hi ha cap spawn point lliure
	if free.is_empty():
		return null
	#Si hi ha spawn points lliures, tria'n un aleatoriament
	var random = randi() % free.size()
	return free[random]

func find_top_marker() -> Node2D:
	#Array per guardar els spawn points lliures
	var free : Array[Node2D] = []
	#Mirar al diccionari quin està ocupat
	for marker in top_markers:
		var occupied = top_occupied.get(marker, null)
		#Si no hi ha cap enemic o l'enemic s'ha eliminat
		if occupied == null or not is_instance_valid(occupied):
			#Afegim l'spawn point a la llista dels que no estan ocupats
			free.append(marker)
	#Si no hi ha cap spawn point lliure
	if free.is_empty():
		return null
	#Si hi ha spawn points lliures, tria'n un aleatoriament
	var random = randi() % free.size()
	return free[random]

func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("FINAL ENEMY: No s'ha trobat cap jugador a l'escena")
	else:
		print(player)

func find_points() -> void:
	if patrol_points == null:
		print("FINAL ENEMY: patrol_points és null")
		return
	#Troba la posició dels marcadors
	children = patrol_points.get_children()
	points_number = children.size()
	print("FINAL ENEMY: Fills de patrol_points: ", children)
	#Si no té marcadors
	if points_number == 0:
		print("FINAL ENEMY: No hi ha marcadors")
		return
	point_positions.clear()
	#Afegeix la posició dels marcadors a l'array
	for point in children:
		point_positions.append(point.global_position)
	current_point = point_positions[current_point_position]
	print("FINAL ENEMY: Punts de patrol: ", point_positions)

func _on_patrol_timer_timeout() -> void:
	canMove = true

func _on_shoot_timer_timeout() -> void:
	#Si no hi ha jugador no dispara
	if player == null:
		return
	#Si ja està en estat de disparar, spawn o canviar de color
	if current_state == State.shoot or current_state == State.spawn or current_state == State.change_color:
		return
	#Ordre d'atacs
	attack_step += 1
	if attack_step == 1 or attack_step == 2:
		#Dispara
		await enemy_shoot()
	elif attack_step == 3:
		#Canvia de color
		await enemy_change_color(get_random_color())
	elif attack_step == 4:
		#Dispara
		await enemy_shoot()
	elif attack_step == 5:
		#Spawn enemics
		await enemy_spawn_attack()
		#Tornar a l'inici de l'ordre d'atacs
		attack_step = 0

#PROVA - Torna a la posició inicial si l'enemic cau
func respawn() -> void:
	global_position = spawn_position
	current_state = State.idle

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

func enable_shield() -> void:
	shield_active = true
	#Activa col·lisions amb la bala
	shield_area.collision_layer = 6
	shield_area.set_collision_mask_value(bullet_layer, true)
	shield_sprite.visible = true
	shield_impact.visible = false

func disable_shield(seconds: float) -> void:
	if shield_running:
		return
	shield_running = true
	shield_active = false
	#Desactiva les collision layers
	shield_area.collision_layer = 0
	shield_area.set_collision_mask_value(bullet_layer, false)
	shield_sprite.visible = false
	shield_impact.visible = false
	await get_tree().create_timer(seconds).timeout
	enable_shield()
	shield_running = false

func is_changing() -> bool:
	return current_state == State.change_color

func connect_hud() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	#Si no es troba el HUD
	if hud == null:
		print("FINAL ENEMY: No s'ha trobat el HUD")
		return
	#Connectar senyals
	max_health_set.connect(hud.setup_healthbar)
	health_changed.connect(hud.update_healthbar)
	died.connect(hud.hide_healthbar)

func die() -> void:
	#Guarda posició de l'enemic
	var p = global_position
	var parent = get_parent()
	#Guarda el color final de l'enemic
	var final_color = enemy_color
	#Canviar l'enemic per l'escena final de mort
	var death = death_scene.instantiate()
	#Coloca l'escena a la posició final de l'enemic
	death.global_position = p
	#Afegeix l'escena
	parent.add_child(death)
	#Animació
	death.play_death(final_color)
	#Elimina l'enemic
	queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("FINAL ENEMY: Hurtbox area entered")
	var node = area.get_parent()
	if node == null:
		return
	#No rep dany si l'escut està actiu
	if shield_active:
		return
	#No rep dany si està fent alguna animació
	if is_changing():
		return
	if node.has_method("get_damage_amount") and node.color == enemy_color:
		health -= node.damage_amount
		health = max(health, 0)
		emit_signal("health_changed", health)
		print("Health: ", health)
		if health <= 0:
			#Mort de l'enemic
			emit_signal("died")
			#So
			Sound.playEnemySfx("finalEnemyDeath", global_position)
			#Marca el nivell com a completat
			GameState.complete_level(3)
			#Guarda el nivell jugat
			GameState.set_last_level_played(3)
			#Canvia el color
			GameState.restore_entry_color()
			GameState.save_progress()
			die()
			return
		else:
			hit_feedback()

func _on_shield_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node == null:
		return
	#Detecta només les bales
	if not node.is_in_group("bullets"):
		return
	#Evita flash si entren moltes bales de cop
	if shield_flash_running:
		node.queue_free()
		return
	shield_flash_running = true
	#Flash
	shield_sprite.visible = false
	shield_impact.visible = true
	#Elimina la bala
	node.queue_free()
	#Espera 1 segon
	await get_tree().create_timer(0.5).timeout
	if shield_active:
		shield_impact.visible = false
		shield_sprite.visible = true
	shield_flash_running = false
