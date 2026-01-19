extends Control

@onready var main_game_scene = $"../"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause()->void:
	var is_paused = get_tree().paused
	if is_paused:
		get_tree().paused=false
		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		get_tree().paused=true
		visible=true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_resume_pressed() -> void:
	toggle_pause()


func _on_button_main_menu_pressed() -> void:
	get_tree().paused=false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://menu/main_menu.tscn")


func _on_button_quit_game_pressed() -> void:
	get_tree().quit()
