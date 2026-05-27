extends Control

signal brand_confirmed(brand_name: String)

@onready var background: TextureRect = $Background
@onready var card_panel: NinePatchRect = $CardPanel
@onready var illustration: TextureRect = $CardPanel/HBox/LeftMargin/Illustration
@onready var text_top: Label = $CardPanel/HBox/RightMargin/VBox/TextTop
@onready var input_row: HBoxContainer = $CardPanel/HBox/RightMargin/VBox/InputRow
@onready var brand_input: LineEdit = $CardPanel/HBox/RightMargin/VBox/InputRow/BrandInput
@onready var text_bottom: Label = $CardPanel/HBox/RightMargin/VBox/TextBottom
@onready var confirm_button: Button = $CardPanel/HBox/RightMargin/VBox/ConfirmButton
@onready var click_hint: Label = $ClickHint

enum Phase { INPUT, RESULT }

var current_phase: int = Phase.INPUT
var brand_name := ""

func _ready() -> void:
	_show_input_phase()
	confirm_button.pressed.connect(_on_confirm)

func _show_input_phase() -> void:
	current_phase = Phase.INPUT
	text_top.text = "你选择在美妆行业扎根\n\n品牌就叫做"
	text_bottom.visible = false
	input_row.visible = true
	confirm_button.visible = true
	click_hint.visible = false
	brand_input.placeholder_text = "输入品牌名称"
	brand_input.grab_focus()

func _show_result_phase() -> void:
	current_phase = Phase.RESULT
	text_top.text = "你选择在美妆行业扎根\n\n品牌就叫做「%s」" % brand_name
	text_bottom.text = "相信凭借你工作多年的经验\n一定会成功经营好「%s」的！" % brand_name
	text_bottom.add_theme_font_size_override("font_size", 24)
	text_bottom.visible = true
	input_row.visible = false
	confirm_button.visible = false
	click_hint.visible = true

func _on_confirm() -> void:
	brand_name = brand_input.text.strip_edges()
	if brand_name.is_empty():
		return
	brand_confirmed.emit(brand_name)
	_show_result_phase()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if current_phase == Phase.RESULT:
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
