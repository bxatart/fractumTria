extends CanvasLayer

@onready var menu_layer: Control = $menuLayer

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
