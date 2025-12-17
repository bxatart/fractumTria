extends Node2D

@onready var game_ui: CanvasLayer = $gameUI
@onready var hud: Control = $gameUI/HUD
@onready var rocks_container: Node2D = $rocks
@onready var marker: Node2D = $playerMarker
@onready var background: Node2D = $background

var rocks: Array[LevelRock] = []
var current_index: int = 0

#Guardar fins a quin nivell s'ha arribat
var max_unlocked_index: int = 0

var tween: Tween

func _ready() -> void:
	Sound.playMusic("levelSelect")
	#Vides
	hud.setup_hearts(GameState.player_max_health)
	hud.update_hearts(GameState.player_health)
	#Afegir les roques a l'array
	for i in rocks_container.get_children():
		if i is LevelRock:
			rocks.append(i)
	#Ordenar-les per nivell
	rocks.sort_custom(func(a: LevelRock, b: LevelRock) -> bool:
		return a.level_index < b.level_index
	)
	#Mira quin és el nivell màx disponible
	max_unlocked_index = GameState.max_unlocked_index()
	#Actualitzar l'estat de les roques segons el progrés
	update_rocks_state()
	#Posa el jugador a la roca actual
	var target_index = GameState.last_level_played
	if target_index < 0:
		target_index = GameState.max_unlocked_index()
	current_index = clamp(target_index, 0, max_unlocked_index)
	marker.global_position = rocks[current_index].get_anchor()
	if GameState.last_level_played >= 0:
		GameState.restore_entry_color()
	print("Marker:", marker.global_position)
	#Fons
	update_background()

func update_rocks_state() -> void:
	for r in rocks:
		#Si el nivell està completat
		if GameState.is_level_completed(r.level_index):
			r.set_state(LevelRock.State.completed)
		#Si el nivell no està completat però és el següent
		elif r.level_index == GameState.max_unlocked_index():
			r.set_state(LevelRock.State.avaliable)
		#Si el nivell no es pot jugar encara
		else:
			r.set_state(LevelRock.State.blocked)

func try_move(new_index: int) -> void:
	if new_index < 0 or new_index >= rocks.size():
		Sound.playSfx("menuBack")
		return
	#No pot passar si el nivell està bloquejat
	if new_index > max_unlocked_index:
		Sound.playSfx("menuBack")
		return
	var dir = new_index - current_index
	current_index = new_index
	marker.move_direction(dir)
	move_marker(rocks[current_index].get_anchor())

func move_marker(target_pos: Vector2) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(marker, "global_position", target_pos, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		game_ui.open_pause_menu(false, true)
		return
	if event.is_action_pressed("ui_right"):
		try_move(current_index + 1)
	elif event.is_action_pressed("ui_left"):
		try_move(current_index - 1)
	elif event.is_action_pressed("ui_accept"):
		enter_selected_level()

func enter_selected_level() -> void:
	if rocks.is_empty():
		return
	var selected: LevelRock = rocks[current_index]
	#Només pots entrar si està desbloquejat o completat
	if selected.is_blocked():
		return
	if selected.level_scene == null:
		print("LEVEL SELECT: Aquesta roca no té cap nivell assignat")
		return
	#Fer que el jugador només pugui entrar si és del color del nivell, menys al nivell final
	var final_index = GameState.total_levels - 1
	var is_final = current_index == final_index
	if not is_final:
		var required = GameState.get_level_color(current_index)
		if GameState.current_color != required:
			Sound.playSfx("menuBack")
			return
	#Guarda el nivell i el color
	GameState.set_last_level_played(current_index)
	GameState.save_entry_color(GameState.current_color)
	get_tree().change_scene_to_packed(selected.level_scene)

func update_background() -> void:
	for c in background.get_children():
		if c is BackgroundLayer:
			#Canvia el fons si el nivell està completat
			var unlocked = GameState.is_level_completed(c.level_index)
			c.set_unlocked(unlocked)
