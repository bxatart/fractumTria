extends CharacterBody2D

@export var speed: float = 180.0 #velocitat
@export var jump: float = 400.0 #força de salt
@export var gravity: float = 1200.0 #gravetat
<<<<<<< Updated upstream
#variables per guardar els valors
=======
@export var max_health: int = 3 #vida
@export var knockback: float = 250.0 #força del knockback
@export var exit_limit: float = 2000.0 #Sortir del nivell
@export var game_over_scene: PackedScene = preload("res://scenes/levels/game_over.tscn")
@export var level_index: int = 0

#Dany al jugador
var is_hurt: bool = false
var health: int
signal health_changed(current: int, max: int)
var game_over: bool = false
const base_max_health: int = 3

#Guardar els valors de moviment
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
	#Posició muzzle
	muzzle_position = muzzle.position
	#Comença amb el color verd
=======
	health = max_health
	emit_signal("health_changed", health, max_health)
	#Control del jugador
	enable_control()
	#Posició muzzle
	muzzle_position = muzzle.position
	#Comença amb el color seleccionat segons el nivell
	var idx = colors.find(start_color)
	color_index = idx
	spawn_color_index = idx
>>>>>>> Stashed changes
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
		var new_color: GameState.color = colors[color_index]
		GameState.set_color(new_color)
		change_collision_layer()
		change_physics()
		print("Color actual: ", GameState.get_color_name(GameState.current_color))

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
	if game_over:
		return
	#Cau si el personatge està a l'aire
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = max(velocity.y, 0.0)
	#PROVA - Si el personatge ha caigut, el torna a la posició inicial
<<<<<<< Updated upstream
	if global_position.y > 800:
		respawn()
=======
	if global_position.y > 600 and not exit_level:
		Sound.playSfx("playerFalling")
		health -= 1
		delete_bonus_hearts()
		emit_signal("health_changed", health, max_health)
		if health <= 0:
			print("PLAYER DEATH")
			die()
			return
		else:
			respawn()
>>>>>>> Stashed changes

func player_idle(delta: float) -> void:
	if is_on_floor():
		current_state = State.idle
		print("Player State: ", State.keys()[current_state])

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
		print("Player State: ", State.keys()[current_state])
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

<<<<<<< Updated upstream
#PROVA - Torna a la posició inicial si el jugador cau
=======
func player_mask(color: GameState.color) -> int:
	match color: 
		GameState.color.GREEN:
			#Activar el bit 0 (capa 1)
			return 1 << 0 #Desplaçament de bits
		GameState.color.ORANGE:
			#Activar el bit 1 (capa 2)
			return 1 << 1
		GameState.color.PURPLE:
			#Activar el bit 2 (capa 3)
			return 1 << 2
	return 0
	
#Mirar si el jugador es solapa amb alguna plataforma
func player_overlap(color: GameState.color) -> bool:
	#Si no existeix la forma, retorna fals
	if query_shape == null:
		return false
	#Paràmetres de consulta
	var p = PhysicsShapeQueryParameters2D.new()
	#Mirar la forma del jugador
	p.shape = query_shape
	#Posició de la forma
	p.transform = global_transform
	#Capes
	p.collision_mask = player_mask(color)
	#Fer que el jugador no es detecti a si mateix
	p.exclude = [get_rid()]
	#No detectar Area2D
	p.collide_with_areas = false
	#Detectar TileMaps
	p.collide_with_bodies = true
	#Espai del món actual
	var space = get_world_2d().direct_space_state
	#Llista de col·lisions
	var results = space.intersect_shape(p, 8)
	if results.size() > 0:
		return true
	else:
		return false

#Treure el jugador del mig de la plataforma
func player_eject(color: GameState.color) -> bool:
	#Núm de píxels
	var num = 2.0
	#24 intents (pot pujar 1 tile i mitja)
	for i in 24:
		#Si el jugador no es solapa amb cap plataforma
		if not player_overlap(color):
			return true
		#Puja el jugador
		global_position.y -= num
	return false

#Torna a la posició inicial si el jugador cau
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
	#Control del jugador
	enable_control()

func set_spawn_position(new_pos: Vector2) -> void:
	spawn_position = new_pos

#Control del jugador
func enable_control():
	can_control = true
	exit_level = false

func disable_control():
	can_control = false
	velocity.x = 0

#Si s'ha tocat el jugador
func hit_feedback() -> void:
	if is_hurt:
		return
	is_hurt = true
	anim.play("damage")
	Sound.playSfx("playerHit")
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
	delete_bonus_hearts()
	emit_signal("health_changed", health, max_health)
	print("PLAYER Health: ", health)
	apply_knockback(from_node)
	if health <= 0:
		print("PLAYER DEATH")
		die()
		return
	hit_feedback()

func die() -> void:
	if game_over:
		return
	game_over = true
	#Treu el control
	disable_control()
	#Atura el jugador
	velocity = Vector2.ZERO
	#No pot rebre més dany
	if hurtbox:
		hurtbox.monitoring = false
		hurtbox.monitorable = false
	#Animació
	var color_name: StringName = GameState.get_color_name(GameState.current_color)
	var death_anim = "death_%s" % color_name
	await get_tree().create_timer(0.6).timeout
	show_game_over()

func show_game_over() -> void:
	game_over = true
	#Desactiva el control del jugador
	disable_control()
	#Elimina les bales
	get_tree().call_group("bullets", "queue_free")
	var go = game_over_scene.instantiate()
	#Guarda la ruta del nivell actual
	go.level_scene_path = get_tree().current_scene.scene_file_path
	var ui = get_tree().current_scene.get_node_or_null("gameUI")
	#Afegeix el game over a la UI
	if ui:
		ui.add_child(go)
	else:
		get_tree().current_scene.add_child(go)

func full_heal() -> void:
	health = max(health, base_max_health)
	emit_signal("health_changed", health, max_health)

func heal(amount: int) -> void:
	#Suma vides
	if health < max_health:
		health = clamp(health + amount, 0, max_health)
	else:
		max_health += amount
		health = max_health
	emit_signal("health_changed", health, max_health)
	print("PLAYER Vides: ", health)

func delete_bonus_hearts() -> void:
	if max_health > base_max_health and health < max_health:
		max_health = max(base_max_health, health)
		health = clamp(health, 0, max_health)

func start_exit() -> void:
	disable_control()
	exit_level = true
	#Fer que miri a la dreta
	last_dir = 1.0
	current_state = State.run
	exit_limit = global_position.x + 200.0
	#Animació de moviment
	get_anim(0.0)
	
func exit(delta: float) -> void:
	#Gravetat
	player_falling(delta)
	velocity.x = speed
	last_dir = 1.0
	move_and_slide()
	get_anim(delta)
	if global_position.x > exit_limit:
		#Marca el nivell com a completat
		GameState.complete_level(level_index)
		#Guarda el nivell jugat
		GameState.set_last_level_played(level_index)
		#Canvia el color
		GameState.restore_entry_color()
		#Guardar les vides
		health = max(health, base_max_health)
		max_health = max(max_health, health)
		emit_signal("health_changed", health, max_health)
		GameState.set_player_health(health, max_health)
		#Anar al menú de selecció de nivells
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#Si s'està sortint del nivell, no et poden tocar
	if exit_level:
		return
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies"):
		take_damage(1, enemy)
>>>>>>> Stashed changes
