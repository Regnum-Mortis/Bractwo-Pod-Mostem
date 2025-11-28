extends Control

# -- REFERENCES --
# These must be connected in the inspector or match the node names exactly
@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var options_menu = $OptionsMenu # A Panel or Control node acting as the options overlay

# Path to your actual game scene
const GAME_SCENE_PATH = "res://Scenes/main.tscn"

func _ready():
	# Ensure the options menu is hidden when the game starts
	if options_menu:
		options_menu.visible = false
	
	# Connect signals via code (alternative to using the Editor's Node tab)
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	# Change the scene to the actual game
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_options_pressed():
	# Hide main buttons and show options
	# You might want to animate this later
	$VBoxContainer.visible = false
	options_menu.visible = true

func _on_quit_pressed():
	# Quit the game
	get_tree().quit()

# -- SETTINGS MENU FUNCTIONS --
# Connect the "Back" button inside your OptionsMenu to this
func _on_options_back_pressed():
	options_menu.visible = false
	$VBoxContainer.visible = true