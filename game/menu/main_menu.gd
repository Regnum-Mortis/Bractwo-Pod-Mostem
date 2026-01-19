extends Control
@onready var start_button = $MainManuButtons/StartButton
@onready var options_button = $MainManuButtons/OptionsButton
@onready var quit_button = $MainManuButtons/QuitButton

# This now refers to the Scene Instance
@onready var options_menu = $OptionsMenu 

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Ensure options are hidden at start
	options_menu.visible = false
	
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect to the custom signal we made in Step 2
	options_menu.close_options.connect(_on_options_closed)

func _on_start_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_options_pressed():
	$MainManuButtons.visible = false
	options_menu.visible = true

func _on_quit_pressed():
	get_tree().quit()

# This runs when the Options Menu emits "close_options"
func _on_options_closed():
	# Options menu hides itself in its own script, 
	# so we just need to show the main buttons again.
	$MainManuButtons.visible = true
