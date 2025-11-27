extends CanvasLayer
@onready var panel = $Panel
@onready var Npc_text = $Panel/Npc_text
@onready var Npc_name = $Panel/Npc_name

func _ready() -> void:
	visible = false
	
func show_dialog(npc_name: String, text:String):
	Npc_name.text = npc_name
	Npc_text.text = text
	visible = true
func hide_dialog():
	visible = false
