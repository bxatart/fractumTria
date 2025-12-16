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
	menu_layer.add_child(menu)
