extends CanvasLayer

@onready var menu_layer: Control = $menuLayer
@onready var white_flash: ColorRect = $whiteFlash

func open_pause_menu(is_pause: bool, is_level_select: bool) -> void:
	#Si ja està obert el menú
	if menu_layer.has_node("Menu"):
		return
	var menu = preload("res://scenes/menu_screen.tscn").instantiate()
	menu.name = "Menu"
	menu.pause = is_pause
	menu.level_select = is_level_select
	menu.settings_requested.connect(func():
		open_settings(is_pause, is_level_select)
	)
	menu_layer.add_child(menu)

func open_settings(is_pause: bool, is_level_select: bool) -> void:
	if menu_layer.has_node("Settings"):
		return
	#Treure el menú
	var menu = menu_layer.get_node_or_null("Menu")
	if menu:
		menu.queue_free()
	#Crear la pantalla de configuració
	var settings = preload("res://scenes/settings_menu.tscn").instantiate()
	settings.name = "Settings"
	settings.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_layer.add_child(settings)
	settings.closed.connect(func():
		settings.queue_free()
		open_pause_menu(is_pause, is_level_select)
	)

func flash_white() -> void:
	white_flash.visible = true
	white_flash.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(white_flash, "modulate:a", 1.0, 0.35)
	await t.finished
	white_flash.modulate.a = 0.0
	white_flash.visible = false

func flash_white_out() -> void:
	white_flash.visible = true
	white_flash.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(white_flash, "modulate:a", 1.0, 0.35)
