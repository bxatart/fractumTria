extends Control

@onready var hearts_box: HBoxContainer = $topLeft/hearts
@onready var healthbar: TextureProgressBar = $healthbar
@onready var icon_green: TextureRect = $topLeft/icons/iconGreen
@onready var icon_orange: TextureRect = $topLeft/icons/iconOrange
@onready var icon_purple: TextureRect = $topLeft/icons/iconPurple

@export var heart_scene: PackedScene
@export var heart_full: Texture2D
@export var heart_empty: Texture2D

var max_hearts = 0

func _ready() -> void:
	#No mostrar la healthbar
	healthbar.visible = false
	healthbar.value = 0
	#Posar la icona del color actual
	await get_tree().process_frame
	set_icon_pivots()
	set_icon_color(GameState.current_color)
	#Mira quan es canvia el color
	GameState.color_changed.connect(set_icon_color)

#Canviar de color la icona segons el color del jugador
func set_icon_color(new_color: GameState.color) -> void:
	icon_green.scale = Vector2(1, 1)
	icon_orange.scale = Vector2(1, 1)
	icon_purple.scale = Vector2(1, 1)
	match new_color:
		GameState.color.GREEN:
			icon_green.modulate = Color(1, 1, 1, 1)
			icon_green.scale = Vector2(1.2, 1.2)
			icon_orange.modulate = Color(0.5, 0.5, 0.5)
			icon_purple.modulate = Color(0.5, 0.5, 0.5)
		GameState.color.ORANGE:
			icon_orange.modulate = Color(1, 1, 1, 1)
			icon_orange.scale = Vector2(1.2, 1.2)
			icon_green.modulate = Color(0.5, 0.5, 0.5)
			icon_purple.modulate = Color(0.5, 0.5, 0.5)
		GameState.color.PURPLE:
			icon_purple.modulate = Color(1, 1, 1, 1)
			icon_purple.scale = Vector2(1.2, 1.2)
			icon_green.modulate = Color(0.5, 0.5, 0.5)
			icon_orange.modulate = Color(0.5, 0.5, 0.5)

func set_icon_pivots() -> void:
	for icon in [icon_green, icon_orange, icon_purple]:
		icon.pivot_offset = icon.size * 0.5

func setup_hearts(max_hp: int) -> void:
	max_hearts = max_hp
	#Esborra els cors si n'hi ha
	for c in hearts_box.get_children():
		c.queue_free()
	#Crea els cors segons la vida
	for i in range(max_hearts):
		var heart: TextureRect = heart_scene.instantiate()
		heart.texture = heart_full
		hearts_box.add_child(heart)
		print("Hearts number:", hearts_box.get_child_count())

func update_hearts(current_hp: int) -> void:
	for i in range(max_hearts):
		var heart: TextureRect = hearts_box.get_child(i)
		if i < current_hp:
			heart.texture = heart_full
		else:
			heart.texture = heart_empty

func setup_healthbar(max_hp: int) -> void:
	healthbar.max_value = max_hp
	healthbar.value = max_hp
	healthbar.visible = true

func update_healthbar(current_hp: int) -> void:
	healthbar.value = clamp(current_hp, 0, int(healthbar.max_value))
	if healthbar.value <= 0:
		healthbar.visible = false

func hide_healthbar() -> void:
	healthbar.visible = false
