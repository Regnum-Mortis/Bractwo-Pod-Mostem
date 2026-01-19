extends Control

@onready var main_game_scene = $"../"
@export var inventory_ui: Control

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if inventory_ui and inventory_ui.visible:
			close_inventory_properly()
			return
			
		toggle_pause()

func close_inventory_properly() -> void:
	if inventory_ui.has_method("close"):
		inventory_ui.close()
	else:
		inventory_ui.visible = false

	if not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_pause() -> void:
	var is_paused = get_tree().paused
	if is_paused:
		get_tree().paused = false
		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		get_tree().paused = true
		visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_resume_pressed() -> void:
	toggle_pause()

func _on_button_main_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://menu/main_menu.tscn")

func _on_button_quit_game_pressed() -> void:
	get_tree().quit()
