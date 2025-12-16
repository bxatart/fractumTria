extends Control

@onready var icon: TextureRect = $topLeft/icon
@onready var hearts_box: HBoxContainer = $topLeft/hearts
@onready var healthbar: TextureProgressBar = $healthbar

@export var icon_green: Texture2D
@export var icon_orange: Texture2D
@export var icon_purple: Texture2D
@export var heart_scene: PackedScene
@export var heart_full: Texture2D
@export var heart_empty: Texture2D

var max_hearts = 0

func _ready() -> void:
	#Posar la icona del color actual
	set_icon_color(GameState.current_color)
	#Mira quan es canvia el color
	GameState.color_changed.connect(set_icon_color)
	#No mostrar la healthbar
	healthbar.visible = false
	healthbar.value = 0

#Canviar de color la icona segons el color del jugador
func set_icon_color(new_color: GameState.color) -> void:
	match new_color:
		GameState.color.GREEN:
			icon.texture = icon_green
		GameState.color.ORANGE:
			icon.texture = icon_orange
		GameState.color.PURPLE:
			icon.texture = icon_purple

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
