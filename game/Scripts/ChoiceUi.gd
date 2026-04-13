extends CanvasLayer

signal chosen(id: String)

var _ids = []
var _item_resources: Dictionary = {}  # id -> InventoryItem resource

@onready var option1 = $Panel/MarginContainer/VBoxContainer/Option1
@onready var option2 = $Panel/MarginContainer/VBoxContainer/Option2
@onready var option3 = $Panel/MarginContainer/VBoxContainer/Option3

@export var item: InventoryItem

func _ready():
	visible = false
	
	option1.pressed.connect(func(): _on_option_pressed(0))
	option2.pressed.connect(func(): _on_option_pressed(1))
	option3.pressed.connect(func(): _on_option_pressed(2))


# Przyjmuje tylko tablicę ID – same wczytuje .tres żeby dostać nazwy.
# Nie potrzebuje już słownika z items.json.
func show_options(ids: Array):
	_ids = ids.duplicate()

	# Załaduj zasoby InventoryItem żeby mieć nazwy do wyświetlenia
	_item_resources.clear()
	for id in _ids:
		var path = "res://inventory/items/%s.tres" % id
		if ResourceLoader.exists(path):
			_item_resources[id] = ResourceLoader.load(path)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true

	option1.text = _get_label(0)
	option2.text = _get_label(1)
	option3.text = _get_label(2)


func _get_label(index: int) -> String:
	if index >= _ids.size():
		return "-"
	var id = _ids[index]
	var item_res = _item_resources.get(id)
	if item_res:
		return item_res.name
	return id  # fallback: pokaż samo ID jeśli brak .tres


func _on_option_pressed(index: int):
	if index < _ids.size():
		var chosen_id = _ids[index]
		emit_signal("chosen", chosen_id)
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_ids.clear()
	_item_resources.clear()

func _process(_delta):
	pass

func hide_options():
	visible = false
