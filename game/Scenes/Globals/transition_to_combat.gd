extends CanvasLayer


@onready var overlay: ColorRect = $Overlay
var material: ShaderMaterial

func _ready() -> void:

	overlay.visible = false
	material = overlay.material as ShaderMaterial

	# Dopasowanie aspect do rozdzielczości
	var vp = get_viewport().get_visible_rect().size
	material.set_shader_parameter("aspect", Vector2(vp.x / vp.y, 1.0))



func start_combat(enemy, player) -> void:
	overlay.visible = true
	material.set_shader_parameter("radius", 1.5)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(
		func(r: float): material.set_shader_parameter("radius", r),
		1.5, 0.0,  
		1.6   
	)

	await tween.finished

	
	#var fighting_scene = load("res://Scenes/fighting_scene/FightingScene.tscn").instantiate()
	get_tree().change_scene_to_file("res://Scenes/fighting_scene/FightingScene.tscn")
	#fighting_scene.setup(enemy, player)


	#fighting_scene.combat_finished.connect(_on_combat_finished)

	#get_tree().root.add_child(fighting_scene)


	await _shader_open()



func _on_combat_finished() -> void:
	await _shader_open()


func _shader_open() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(r: float): material.set_shader_parameter("radius", r),
		0.0, 1.5,
		1.6
	)

	await tween.finished
	overlay.visible = false
