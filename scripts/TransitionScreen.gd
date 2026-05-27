extends Control

const DIALOGUE_DATA := [
	{"speaker": "主理人", "text": "               三十五岁的这一年，作为企鹅跳动的一名市场营销部经理，你收到了被优化的通知"},
	{"speaker": "主理人", "text": "               正所谓“三五不努力，老大徒伤悲”，不甘于现状的你，决定开始创立自己的品牌"},
]

@onready var background: TextureRect = $Background
@onready var mascot: TextureRect = $Mascot
@onready var supervisor: TextureRect = $Supervisor
@onready var manager: TextureRect = $Manager
@onready var name_label: Label = $DialogueBox/NameLabel
@onready var text_label: Label = $DialogueBox/TextLabel
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var click_hint: Label = $DialogueBox/ClickHint

enum Phase { FADE_OUT, MASCOT_APPEAR, DIALOGUE, MANAGER_ENTER, MANAGER_EXIT, DONE }

var current_phase: int = Phase.FADE_OUT
var current_index := -1
var fade_timer := 0.0
var manager_target_x := 400.0
var manager_exit_x := 1600.0
var move_speed := 400.0
var manager_moving := false
var manager_exiting := false
var mascot_target_pos: Vector2
var end_fade_timer := 1.5

func _ready() -> void:
	mascot.visible = false
	dialogue_box.visible = false
	mascot_target_pos = mascot.position
	# Start fade out of supervisor and manager
	_start_fade_out()

func _start_fade_out() -> void:
	current_phase = Phase.FADE_OUT
	fade_timer = 1.0

func _process(delta: float) -> void:
	match current_phase:
		Phase.FADE_OUT:
			fade_timer -= delta
			var alpha = max(fade_timer, 0.0)
			supervisor.modulate.a = alpha
			manager.modulate.a = alpha
			if fade_timer <= 0.0:
				supervisor.visible = false
				manager.visible = false
				_show_mascot()
		Phase.MASCOT_APPEAR:
			fade_timer -= delta
			mascot.modulate.a = 1.0 - max(fade_timer / 0.8, 0.0)
			if fade_timer <= 0.0:
				mascot.modulate.a = 1.0
				_start_dialogue()
		Phase.MANAGER_ENTER:
			if manager_moving:
				manager.position.x = move_toward(manager.position.x, manager_target_x, move_speed * delta)
				if abs(manager.position.x - manager_target_x) < 1.0:
					manager.position.x = manager_target_x
					manager_moving = false
		Phase.MANAGER_EXIT:
			end_fade_timer -= delta

			var alpha = end_fade_timer / 1.5
			alpha = clamp(alpha, 0.0, 1.0)

			mascot.modulate.a = alpha
			manager.modulate.a = alpha

			if end_fade_timer <= 0.0:
				get_tree().change_scene_to_file("res://scenes/BrandSetupScreen.tscn")

func _show_mascot() -> void:
	current_phase = Phase.MASCOT_APPEAR
	mascot.position = mascot_target_pos
	mascot.visible = true
	mascot.modulate.a = 0.0
	fade_timer = 0.8

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match current_phase:
			Phase.MASCOT_APPEAR:
				# Skip fade-in
				mascot.modulate.a = 1.0
				_start_dialogue()
			Phase.DIALOGUE:
				_advance_dialogue()
			Phase.MANAGER_ENTER:
				if not manager_moving:
					_advance_dialogue()

func _start_dialogue() -> void:
	current_phase = Phase.DIALOGUE
	_advance_dialogue()

func _advance_dialogue() -> void:
	current_index += 1
	if current_index >= DIALOGUE_DATA.size():
		_start_manager_exit()
		return

	var entry: Dictionary = DIALOGUE_DATA[current_index]
	dialogue_box.visible = true
	name_label.text = entry["speaker"]
	text_label.text = entry["text"]

	if current_index == 0:
		_start_manager_enter()

func _start_manager_enter() -> void:
	current_phase = Phase.MANAGER_ENTER
	manager.visible = true
	manager.modulate.a = 1.0
	manager.position.x = -manager.size.x
	manager_moving = true

func _start_manager_exit() -> void:
	current_phase = Phase.MANAGER_EXIT
	dialogue_box.visible = false
	end_fade_timer = 1.5
