extends Control

const KnowledgeDataClass := preload("res://scripts/KnowledgeData.gd")

var categories: Array = []
var knowledge: Dictionary = {}
var current_category: String = ""

@onready var panel: PanelContainer = $Panel
@onready var close_btn: Button = $Panel/Margin/VBox/TitleBar/CloseButton
@onready var title_label: Label = $Panel/Margin/VBox/TitleBar/Title
@onready var category_list: VBoxContainer = $Panel/Margin/VBox/Content/CategoryScroll/CategoryList
@onready var card_scroll: ScrollContainer = $Panel/Margin/VBox/Content/CardScroll
@onready var card_grid: GridContainer = $Panel/Margin/VBox/Content/CardScroll/CardGrid
@onready var detail_panel: PanelContainer = $Panel/Margin/VBox/Content/DetailPanel
@onready var detail_title: Label = $Panel/Margin/VBox/Content/DetailPanel/DetailMargin/DetailBox/DetailTitle
@onready var detail_body: Label = $Panel/Margin/VBox/Content/DetailPanel/DetailMargin/DetailBox/DetailBody
@onready var detail_close: Button = $Panel/Margin/VBox/Content/DetailPanel/DetailMargin/DetailBox/DetailClose

func _ready() -> void:
	categories = KnowledgeDataClass.get_categories()
	knowledge = KnowledgeDataClass.get_knowledge()

	close_btn.pressed.connect(_on_close)
	detail_close.pressed.connect(_on_detail_close)

	panel.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.4)

	# ⭐如果你觉得卡片太宽或太窄，除了改下面的 Vector2，也可以在这里调整列数
	card_grid.columns = 3

	if not categories.is_empty():
		current_category = categories[0].get("id", "")

	_rebuild_categories()
	_rebuild_cards()

	detail_panel.visible = false


func _on_close() -> void:
	visible = false


func _on_detail_close() -> void:
	detail_panel.visible = false
	card_scroll.visible = true


func _on_category_pressed(cat_id: String) -> void:
	current_category = cat_id

	_rebuild_categories()
	_rebuild_cards()

	detail_panel.visible = false
	card_scroll.visible = true


func _on_card_pressed(item: Dictionary) -> void:
	detail_title.text = item.get("name", "")
	detail_body.text = item.get("detail", "")

	card_scroll.visible = false
	detail_panel.visible = true

	detail_panel.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(detail_panel, "modulate:a", 1.0, 0.25)


func _rebuild_categories() -> void:
	for child in category_list.get_children():
		child.queue_free()

	for cat in categories:
		var btn := Button.new()

		btn.text = cat.get("name", "")
		btn.custom_minimum_size = Vector2(170, 48)
		btn.add_theme_font_size_override("font_size", 18)

		var cat_id: String = cat.get("id", "")
		var is_active := cat_id == current_category

		var style := StyleBoxFlat.new()
		style.bg_color = Color("#fff4f7") if is_active else Color(1, 1, 1, 0.72)
		style.border_color = Color("#ffb6c8") if is_active else Color("#eadccf")
		style.set_border_width_all(2)
		style.set_corner_radius_all(22)
		style.shadow_color = Color(0, 0, 0, 0.08)
		style.shadow_size = 10
		style.shadow_offset = Vector2(0, 3)

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_color_override("font_color", Color("#4d372d"))

		btn.pressed.connect(_on_category_pressed.bind(cat_id))

		category_list.add_child(btn)


func _rebuild_cards() -> void:
	for child in card_grid.get_children():
		child.queue_free()

	var items: Array = knowledge.get(current_category, [])

	for item in items:
		var card := _create_card(item)
		card_grid.add_child(card)


func _create_card(item: Dictionary) -> PanelContainer:

	var card := PanelContainer.new()

	# ⭐关键修改：调节知识卡片的宽和高。在这里修改 Vector2 的数值即可！
	card.custom_minimum_size = Vector2(265, 120)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.78)
	style.border_color = Color("#eadccf")
	style.set_border_width_all(2)
	style.set_corner_radius_all(28)
	style.shadow_color = Color(0, 0, 0, 0.1)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 6)

	card.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# 标题
	var title := Label.new()
	title.text = "📘 " + item.get("name", "")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#3d2a22"))
	vbox.add_child(title)

	# 简介
	var summary := Label.new()
	summary.text = item.get("summary", "")
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 15)
	summary.add_theme_color_override("font_color", Color("#6a5448"))
	vbox.add_child(summary)

	# 点击按钮（透明覆盖）
	var click_btn := Button.new()
	click_btn.flat = true
	click_btn.anchor_right = 1.0
	click_btn.anchor_bottom = 1.0

	click_btn.mouse_entered.connect(func():
		card.scale = Vector2(1.03, 1.03)
	)

	click_btn.mouse_exited.connect(func():
		card.scale = Vector2(1.0, 1.0)
	)

	click_btn.pressed.connect(_on_card_pressed.bind(item))
	card.add_child(click_btn)

	return card
