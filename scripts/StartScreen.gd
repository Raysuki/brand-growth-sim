extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/DialogueScreen.tscn")

func _on_load_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()

func _ready() -> void:
	var buttons = [
		$ButtonContainer/StartButton,
		$ButtonContainer/LoadButton,
		$ButtonContainer/ExitButton
	]
	
	for button in buttons:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1.0, 0.7, 0.6)
		# 这里使用了 Godot 4 正确的方法名
		button.add_theme_stylebox_override("normal", style)
	
	$ButtonContainer/StartButton.pressed.connect(_on_start_pressed)
	$ButtonContainer/LoadButton.pressed.connect(_on_load_pressed)
	$ButtonContainer/ExitButton.pressed.connect(_on_exit_pressed)
