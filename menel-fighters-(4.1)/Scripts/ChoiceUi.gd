extends CanvasLayer

signal chosen(id: String)

var _ids = []

@onready var option1 = $Panel/MarginContainer/VBoxContainer/Option1
@onready var option2 = $Panel/MarginContainer/VBoxContainer/Option2
@onready var option3 = $Panel/MarginContainer/VBoxContainer/Option3



# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	option1.pressed.connect(func(): _on_option_pressed(0))
	option2.pressed.connect(func(): _on_option_pressed(1))
	option3.pressed.connect(func(): _on_option_pressed(2))

func show_options(ids: Array, items: Dictionary):
	_ids = ids.duplicate()
	visible = true
	
	option1.text = _get_label(0, items)
	option2.text = _get_label(1, items)
	option3.text = _get_label(2, items)
	
func _get_label(index: int, items: Dictionary):
	if index >= _ids.size():
		return "-"
	var id = _ids[index]
	var def = items.get(id, {})
	return def.get("name", id)
	
func _on_option_pressed(index: int):
	if index < _ids.size():
		var chosen_id = _ids[index]
		emit_signal("chosen", chosen_id)
	visible = false
	_ids.clear()
func _process(delta):
	pass
