@tool
extends Control

const DataLoaderClass := preload("res://scripts/DataLoader.gd")
const GameStateClass := preload("res://scripts/GameState.gd")
const ActionSystemClass := preload("res://scripts/ActionSystem.gd")
const TurnManagerClass := preload("res://scripts/TurnManager.gd")
const EventSystemClass := preload("res://scripts/EventSystem.gd")
const EndingSystemClass := preload("res://scripts/EndingSystem.gd")

const ICON_PATHS := {
	"brand_awareness": "res://assets/icons/icon_awareness.png",
	"brand_cognition": "res://assets/icons/icon_cognition.png",
	"brand_association": "res://assets/icons/icon_association.png",
	"brand_loyalty": "res://assets/icons/icon_loyalty.png",
	"channel_control": "res://assets/icons/icon_channel.png",
	"funds": "res://assets/icons/icon_funds.png",
	"action_points": "res://assets/icons/icon_action_point.png",
	"public_risk": "res://assets/icons/icon_public_risk.png",
	"trend": "res://assets/icons/icon_trend.png",
	"sale": "res://assets/icons/icon_sale.png"
}

const BACKGROUND_PATHS := {
	"startup": "res://assets/backgrounds/初创期共享办公室.png",
	"growth": "res://assets/backgrounds/成长期创意园区.png",
	"mature": "res://assets/backgrounds/成熟期独立办公室.png"
}

const MASCOT_PATH := "res://assets/npcs/看板娘.png"
const RESTART_ICON := "res://assets/ui/icon_restart.png"
const LOGO_PATH := "res://assets/icons/游戏名logo.png"
const END_TURN_IMAGE_PATH := "res://assets/icons/结束回合.png"
const STAGE_PANEL_PATH := "res://assets/ui/阶段条底图.png"
const RESOURCE_PANEL_PATH := "res://assets/ui/资源面板底图.png"
const ATTRIBUTE_PANEL_PATH := "res://assets/ui/品牌属性面板底图.png"
const RIGHT_PANEL_PATH := "res://assets/ui/右侧行动大面板底图.png"
const ACTION_CARD_PATH := "res://assets/ui/行动卡片底图(未选中).png"
const ACTION_CARD_ACTIVE_PATH := "res://assets/ui/行动卡片底图（选中）.png"
const PLAN_HINT_PATH := "res://assets/ui/计划提示条底图.png"

const CATEGORY_ICON_PATHS := {
	"market_research": "res://assets/icons/市场调研.png",
	"product_rnd": "res://assets/icons/产品研发.png",
	"visual_design": "res://assets/icons/视觉设计.png",
	"marketing": "res://assets/icons/营销推广.png",
	"channel": "res://assets/icons/渠道建设.png",
	"user_ops": "res://assets/icons/用户运营.png",
	"crisis_pr": "res://assets/icons/危机公关.png"
}

const CATEGORY_ORDER := [
	"market_research",
	"product_rnd",
	"visual_design",
	"marketing",
	"channel",
	"user_ops",
	"crisis_pr"
]

var loader := DataLoaderClass.new()
var all_data := {}
var state := GameStateClass.new()
var action_system := ActionSystemClass.new()
var turn_manager := TurnManagerClass.new()
var event_system := EventSystemClass.new()
var ending_system := EndingSystemClass.new()

var selected_category := "market_research"
var planned_actions: Array = []
var pending_event := {}
var attr_rows := {}

func _optional_label(path: String) -> Label:
	var node := get_node_or_null(path)
	if node is Label:
		return node
	return Label.new()

@onready var background_rect: TextureRect = %Background
@onready var mascot_rect: TextureRect = %Mascot
@onready var logo_rect: TextureRect = %Logo
@onready var status_label: Label = %StatusLabel
@onready var restart_button: Button = %RestartButton
@onready var stage_panel: PanelContainer = get_node_or_null("StagePanel") as PanelContainer
@onready var resource_panel: PanelContainer = get_node_or_null("ResourcePanel") as PanelContainer
@onready var attribute_panel: PanelContainer = $AttributePanel
@onready var right_panel: PanelContainer = $RightPanel
@onready var stage_name_label: Label = %StageNameLabel
@onready var stage_turn_label: Label = %StageTurnLabel
@onready var trend_label: Label = _optional_label("%TrendLabel")
@onready var funds_label: Label = %FundsValue
@onready var ap_label: Label = %APValue
@onready var risk_label: Label = %RiskValue
@onready var sale_label: Label = %SaleValue
@onready var attribute_list: VBoxContainer = %AttributeList
@onready var log_label: RichTextLabel = %LogLabel
@onready var category_list: HBoxContainer = %CategoryList
@onready var action_list: VBoxContainer = %ActionList
@onready var plan_label: Label = %PlanLabel
@onready var plan_panel: PanelContainer = %PlanPanel
@onready var finish_button: Button = %FinishTurnButton
@onready var clear_button: Button = %ClearPlanButton
@onready var event_panel: Control = %EventPanel
@onready var event_title: Label = %EventTitle
@onready var event_body: Label = %EventBody
@onready var event_options: VBoxContainer = %EventOptions
@onready var ending_panel: Control = %EndingPanel
@onready var ending_title: Label = %EndingTitle
@onready var ending_body: Label = %EndingBody
@onready var close_ending_button: Button = %CloseEndingButton

func _ready() -> void:
	all_data = loader.load_all()
	state.reset(all_data)
	_bind_static_nodes()
	_build_attribute_rows()
	_refresh_ui("编辑器预览：现在可以在 Main.tscn 里直接拖动布局。" if Engine.is_editor_hint() else "选择行动加入本回合计划，点击结束回合后统一执行。")

func _bind_static_nodes() -> void:
	background_rect.texture = _tex(str(BACKGROUND_PATHS.get("startup", "")))
	mascot_rect.texture = _tex(MASCOT_PATH)
	logo_rect.texture = _tex(LOGO_PATH)
	restart_button.icon = _tex(RESTART_ICON)
	restart_button.expand_icon = true
	finish_button.text = ""
	finish_button.icon = _tex(END_TURN_IMAGE_PATH)
	finish_button.expand_icon = true
	_apply_asset_panels()
	_apply_layering()
	_setup_resource_tiles()
	_apply_readable_text_colors()
	if not restart_button.pressed.is_connected(_on_restart):
		restart_button.pressed.connect(_on_restart)
	if not finish_button.pressed.is_connected(_on_finish_turn):
		finish_button.pressed.connect(_on_finish_turn)
	if not clear_button.pressed.is_connected(_on_clear_plan):
		clear_button.pressed.connect(_on_clear_plan)
	if not close_ending_button.pressed.is_connected(_on_close_ending):
		close_ending_button.pressed.connect(_on_close_ending)
	event_panel.visible = false
	ending_panel.visible = false

func _apply_asset_panels() -> void:
	if stage_panel != null:
		stage_panel.add_theme_stylebox_override("panel", _texture_style(STAGE_PANEL_PATH, 42, 20))
	if resource_panel != null:
		resource_panel.add_theme_stylebox_override("panel", _texture_style(RESOURCE_PANEL_PATH, 36, 28))
	if attribute_panel != null:
		attribute_panel.add_theme_stylebox_override("panel", _texture_style(ATTRIBUTE_PANEL_PATH, 38, 28))
	if right_panel != null:
		right_panel.add_theme_stylebox_override("panel", _texture_style(RIGHT_PANEL_PATH, 42, 42))
	if plan_panel != null:
		plan_panel.add_theme_stylebox_override("panel", _texture_style(PLAN_HINT_PATH, 22, 14))

func _apply_layering() -> void:
	mascot_rect.z_index = 1
	for node in [
		logo_rect,
		restart_button,
		stage_panel,
		resource_panel,
		attribute_panel,
		right_panel,
		stage_name_label,
		stage_turn_label,
		trend_label,
		attribute_list,
		log_label,
		category_list,
		action_list,
		plan_panel,
		plan_label,
		finish_button,
		clear_button
	]:
		if node is CanvasItem:
			node.z_index = 5
	event_panel.z_index = 20
	ending_panel.z_index = 20

func _apply_readable_text_colors() -> void:
	var dark := Color("#4d372d")
	for node in get_tree().get_nodes_in_group("readable_text"):
		if node is Label:
			node.add_theme_color_override("font_color", dark)
	for label in [event_title, event_body, ending_title, ending_body, plan_label, trend_label]:
		if label is Label:
			label.add_theme_color_override("font_color", dark)
	for button in [restart_button, finish_button, clear_button, close_ending_button]:
		if button is Button:
			_apply_button_text_colors(button)
	for path in [
		"ResourcePanel/ResourceMargin/ResourceGrid/FundsTile/FundsBox/FundsName",
		"ResourcePanel/ResourceMargin/ResourceGrid/FundsTile/FundsBox/FundsValue",
		"ResourcePanel/ResourceMargin/ResourceGrid/APTile/APBox/APName",
		"ResourcePanel/ResourceMargin/ResourceGrid/APTile/APBox/APValue",
		"ResourcePanel/ResourceMargin/ResourceGrid/RiskTile/RiskBox/RiskName",
		"ResourcePanel/ResourceMargin/ResourceGrid/RiskTile/RiskBox/RiskValue",
		"ResourcePanel/ResourceMargin/ResourceGrid/SaleTile/SaleBox/SaleName",
		"ResourcePanel/ResourceMargin/ResourceGrid/SaleTile/SaleBox/SaleValue"
	]:
		var label := get_node_or_null(path)
		if label is Label:
			label.add_theme_color_override("font_color", dark)
	for fallback_path in [
		"FundsTile/FundsBox/FundsName",
		"FundsTile/FundsBox/FundsValue",
		"APTile/APBox/APName",
		"APTile/APBox/APValue",
		"RiskTile/RiskBox/RiskName",
		"RiskTile/RiskBox/RiskValue",
		"SaleTile/SaleBox/SaleName",
		"SaleTile/SaleBox/SaleValue"
	]:
		var fallback_label := get_node_or_null(fallback_path)
		if fallback_label is Label:
			fallback_label.add_theme_color_override("font_color", dark)

func _apply_button_text_colors(button: Button) -> void:
	var dark := Color("#4d372d")
	var muted := Color("#8a6a5c")
	button.add_theme_color_override("font_color", dark)
	button.add_theme_color_override("font_hover_color", dark)
	button.add_theme_color_override("font_pressed_color", dark)
	button.add_theme_color_override("font_focus_color", dark)
	button.add_theme_color_override("font_disabled_color", muted)

func _setup_resource_tiles() -> void:
	_setup_resource_tile("FundsTile/FundsBox", "资金", ICON_PATHS.funds)
	_setup_resource_tile("APTile/APBox", "行动点", ICON_PATHS.action_points)
	_setup_resource_tile("RiskTile/RiskBox", "舆情风险", ICON_PATHS.public_risk)
	_setup_resource_tile("SaleTile/SaleBox", "风口", ICON_PATHS.trend)

func _setup_resource_tile(relative_path: String, display_name: String, icon_path: String) -> void:
	var box := get_node_or_null("ResourcePanel/ResourceMargin/ResourceGrid/" + relative_path)
	if box == null:
		box = get_node_or_null(relative_path)
	if not box is VBoxContainer:
		return
	if box.get_node_or_null("TileIcon") == null:
		var icon := TextureRect.new()
		icon.name = "TileIcon"
		icon.texture = _scaled_tex(icon_path, 42)
		icon.custom_minimum_size = Vector2(42, 34)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		box.add_child(icon)
		box.move_child(icon, 0)
	var labels := []
	for child in box.get_children():
		if child is Label:
			labels.append(child)
	if labels.size() >= 1:
		(labels[0] as Label).text = display_name
		(labels[0] as Label).add_theme_font_size_override("font_size", 12)
		(labels[0] as Label).add_theme_color_override("font_color", Color("#4d372d"))
	if labels.size() >= 2:
		(labels[1] as Label).add_theme_font_size_override("font_size", 18)
		(labels[1] as Label).add_theme_color_override("font_color", Color("#4d372d"))

func _build_attribute_rows() -> void:
	attr_rows.clear()
	for child in attribute_list.get_children():
		child.queue_free()
	for attr_info in all_data.get("attributes", {}).get("attributes", []):
		var attr_id := str(attr_info.get("id", ""))
		attribute_list.add_child(_attribute_row(attr_id, str(attr_info.get("name", ""))))

func _refresh_ui(message := "") -> void:
	background_rect.texture = _tex(str(BACKGROUND_PATHS.get(state.stage_id, BACKGROUND_PATHS.startup)))
	stage_name_label.text = _stage_name()
	stage_turn_label.text = "%d / %d 回合" % [state.current_turn, state.max_turns]
	var next_text := ""
	if state.has_tag("forecast_next_trend") and not state.next_trend.is_empty():
		next_text = " | 下季：%s" % state.next_trend.get("name", "")
	trend_label.text = "风口：%s%s" % [state.current_trend.get("name", "无"), next_text]

	var planned_cost := _planned_cost()
	var planned_ap := _planned_ap()
	funds_label.text = "%d\n计划 -%d" % [state.funds, planned_cost]
	ap_label.text = "%d/%d\n已排 %d" % [state.action_points, state.action_points_max, planned_ap]
	risk_label.text = "%d" % state.public_risk
	sale_label.text = "本回合" if turn_manager.is_major_sale_turn(state, all_data) else "无"
	status_label.text = message
	funds_label.text = "%d" % state.funds
	funds_label.tooltip_text = "本回合计划资金：-%d" % planned_cost
	ap_label.text = "%d / %d" % [state.action_points - planned_ap, state.action_points_max]
	ap_label.tooltip_text = "本回合已安排 AP：%d" % planned_ap
	sale_label.text = _trend_tile_text()

	for attr in GameStateClass.ATTRIBUTES:
		if attr_rows.has(attr):
			var row: Dictionary = attr_rows[attr]
			(row.get("bar") as ProgressBar).value = int(state.attributes.get(attr, 0))

	_rebuild_categories()
	_rebuild_actions()
	_rebuild_plan()
	_rebuild_log()
	if state.game_over and state.final_ending.is_empty():
		state.final_ending = ending_system.decide(state, all_data)
		_show_ending()

func _rebuild_categories() -> void:
	for child in category_list.get_children():
		child.queue_free()
	for category in _categories_in_order():
		var id := str(category.get("id", ""))
		var btn := Button.new()
		btn.text = ""
		btn.tooltip_text = str(category.get("name", id))
		btn.icon = _scaled_tex(str(CATEGORY_ICON_PATHS.get(id, ICON_PATHS.get(_category_icon_id(id), ""))), 54)
		btn.expand_icon = false
		btn.custom_minimum_size = Vector2(58, 66)
		btn.clip_text = true
		btn.add_theme_font_size_override("font_size", 9)
		_apply_button_text_colors(btn)
		var style := _flat_style(Color("#fff0f4") if id == selected_category else Color(1, 1, 1, 0.92), Color("#ff9fb4") if id == selected_category else Color("#ead2bf"), 12, 2)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.pressed.connect(_on_category_pressed.bind(id))
		category_list.add_child(btn)

func _rebuild_actions() -> void:
	for child in action_list.get_children():
		child.queue_free()
	for action in all_data.get("actions", {}).get("actions", []):
		if action.get("category", "") == selected_category:
			action_list.add_child(_action_card(action))

func _action_card(action: Dictionary) -> Button:
	var btn := Button.new()
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.custom_minimum_size = Vector2(0, 52)
	btn.icon = _scaled_tex(str(CATEGORY_ICON_PATHS.get(str(action.get("category", "")), ICON_PATHS.get(_category_icon_id(str(action.get("category", ""))), ""))), 42)
	btn.expand_icon = false
	btn.text = "%s\n资金 %d   AP %d    %s" % [
		action.get("name", ""),
		int(action.get("cost", 0)),
		int(action.get("ap", 1)),
		_action_effect_text(action)
	]
	btn.tooltip_text = "点击加入本回合计划，结束回合后统一执行"
	btn.add_theme_font_size_override("font_size", 12)
	_apply_button_text_colors(btn)
	var style := _texture_style(ACTION_CARD_ACTIVE_PATH if _planned_has_action(action) else ACTION_CARD_PATH, 28, 18)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.disabled = state.game_over or event_panel.visible or not _can_plan(action)
	btn.pressed.connect(_on_plan_action.bind(action))
	return btn

func _attribute_row(attr_id: String, display_name: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var icon := TextureRect.new()
	icon.texture = _tex(str(ICON_PATHS.get(attr_id, "")))
	icon.custom_minimum_size = Vector2(30, 30)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = display_name
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("#5a5362"))
	var bar := ProgressBar.new()
	bar.max_value = 300
	bar.show_percentage = true
	bar.custom_minimum_size = Vector2(0, 18)
	box.add_child(label)
	box.add_child(bar)
	row.add_child(box)
	attr_rows[attr_id] = { "bar": bar, "label": label }
	return row

func _action_effect_text(action: Dictionary) -> String:
	var bits := []
	for attr in action.get("effects", {}).keys():
		bits.append("%s %+d" % [_short_attr(attr), int(action["effects"][attr])])
	var risk := int(action.get("risk", 0))
	if risk != 0:
		bits.append("风险 %+d" % risk)
	if _action_matches_trend(action):
		bits.append("风口加成")
	return "  ".join(bits)

func _trend_tile_text() -> String:
	var trend := state.current_trend
	if trend.is_empty():
		return "无"
	var trend_name := str(trend.get("name", "无"))
	var effect := str(trend.get("effect", ""))
	return "%s\n%s" % [trend_name, _extract_multiplier(effect)]

func _extract_multiplier(effect: String) -> String:
	var regex := RegEx.new()
	if regex.compile("[x×X]\\s*[0-9]+(?:\\.[0-9]+)?") != OK:
		return "本回合增益"
	var result := regex.search(effect)
	if result == null:
		return "本回合增益"
	return result.get_string().replace("x", "×").replace("X", "×")

func _rebuild_plan() -> void:
	var names := []
	for action in planned_actions:
		names.append(str(action.get("name", "")))
	plan_label.text = "本回合计划：%s    合计资金 %d / AP %d" % [
		"、".join(names) if not names.is_empty() else "未选择",
		_planned_cost(),
		_planned_ap()
	]

func _rebuild_log() -> void:
	var lines := []
	for i in range(max(0, state.turn_log.size() - 6), state.turn_log.size()):
		var item: Dictionary = state.turn_log[i]
		lines.append("T%d 收入%d 开销%d 利润%+d 资金%d 风险%d" % [item.get("turn", 0), item.get("income", 0), item.get("expense", 0), item.get("profit", 0), item.get("funds", 0), item.get("risk", 0)])
	for i in range(max(0, state.event_log.size() - 4), state.event_log.size()):
		var item: Dictionary = state.event_log[i]
		lines.append("事件 T%d：%s / %s" % [item.get("turn", 0), item.get("event", ""), item.get("option", "")])
	log_label.text = "\n".join(lines)

func _on_category_pressed(category_id: String) -> void:
	selected_category = category_id
	_refresh_ui("已切换行动分类：%s" % _category_name(category_id))

func _on_plan_action(action: Dictionary) -> void:
	if Engine.is_editor_hint():
		return
	planned_actions.append(action.duplicate(true))
	_refresh_ui("已加入计划：%s" % action.get("name", ""))

func _on_clear_plan() -> void:
	if Engine.is_editor_hint():
		return
	planned_actions.clear()
	_refresh_ui("已清空本回合计划。")

func _on_finish_turn() -> void:
	if Engine.is_editor_hint() or state.game_over:
		return
	var executed := []
	for action in planned_actions:
		var result: Dictionary = action_system.execute(action, state, all_data)
		if bool(result.get("ok", false)):
			executed.append(str(action.get("name", "")))
	planned_actions.clear()
	pending_event = event_system.pick_event(state, all_data)
	if not pending_event.is_empty():
		_show_event(pending_event)
		return
	_finish_turn_after_events("执行：%s" % ("、".join(executed) if not executed.is_empty() else "无行动"))

func _finish_turn_after_events(prefix := "") -> void:
	var summary := turn_manager.finish_turn(state, all_data)
	var text := "回合结算：收入 %d，开销 %d，利润 %+d。" % [summary.get("income", 0), summary.get("expense", 0), summary.get("profit", 0)]
	_refresh_ui("%s  %s" % [prefix, text])

func _show_event(event: Dictionary) -> void:
	event_panel.visible = true
	event_title.text = event.get("name", "")
	event_body.text = "%s\n\n触发条件：%s" % [event.get("description", ""), event.get("condition_text", "")]
	for child in event_options.get_children():
		child.queue_free()
	for option in event.get("options", []):
		var btn := _basic_button(option.get("name", ""))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_event_option.bind(event, option))
		event_options.add_child(btn)

func _on_event_option(event: Dictionary, option: Dictionary) -> void:
	if Engine.is_editor_hint():
		return
	var result := event_system.apply_option(event, option, state, all_data)
	event_panel.visible = false
	_finish_turn_after_events(result.get("message", ""))

func _show_ending() -> void:
	ending_panel.visible = true
	ending_title.text = "结局：%s" % state.final_ending.get("name", "")
	ending_body.text = "%s\n\n判定：%s\n\n最终资金：%d\n累计利润：%d\n知名/认知/联想/忠诚/渠道：%d / %d / %d / %d / %d" % [
		state.final_ending.get("description", ""),
		state.final_ending.get("condition_text", ""),
		state.funds,
		state.cumulative_profit,
		state.attributes.get("brand_awareness", 0),
		state.attributes.get("brand_cognition", 0),
		state.attributes.get("brand_association", 0),
		state.attributes.get("brand_loyalty", 0),
		state.attributes.get("channel_control", 0)
	]

func _on_restart() -> void:
	if Engine.is_editor_hint():
		return
	ending_panel.visible = false
	event_panel.visible = false
	planned_actions.clear()
	state.reset(all_data)
	_refresh_ui("已重新开始。")

func _on_close_ending() -> void:
	ending_panel.visible = false

func _can_plan(action: Dictionary) -> bool:
	return _planned_ap() + int(action.get("ap", 1)) <= state.action_points and _planned_cost() + int(action.get("cost", 0)) <= state.funds

func _planned_cost() -> int:
	var total := 0
	for action in planned_actions:
		total += int(action.get("cost", 0))
	return total

func _planned_ap() -> int:
	var total := 0
	for action in planned_actions:
		total += int(action.get("ap", 1))
	return total

func _categories_in_order() -> Array:
	var by_id := {}
	for category in all_data.get("actions", {}).get("categories", []):
		by_id[str(category.get("id", ""))] = category
	var ordered := []
	for id in CATEGORY_ORDER:
		if by_id.has(id):
			ordered.append(by_id[id])
	return ordered

func _category_name(category_id: String) -> String:
	for category in all_data.get("actions", {}).get("categories", []):
		if category.get("id", "") == category_id:
			return category.get("name", category_id)
	return category_id

func _action_matches_trend(action: Dictionary) -> bool:
	var tags: Array = action.get("tags", [])
	var trend_tags: Array = state.current_trend.get("tags", [])
	if trend_tags.has("visual_design") and action.get("category", "") == "visual_design":
		return true
	for tag in tags:
		if trend_tags.has(tag):
			return true
	return false

func _planned_has_action(action: Dictionary) -> bool:
	for planned in planned_actions:
		if str(planned.get("id", "")) == str(action.get("id", "")):
			return true
	return false

func _category_icon_id(category_id: String) -> String:
	match category_id:
		"market_research": return "trend"
		"product_rnd": return "brand_cognition"
		"visual_design": return "brand_association"
		"marketing": return "brand_awareness"
		"channel": return "channel_control"
		"user_ops": return "brand_loyalty"
		"crisis_pr": return "public_risk"
	return "trend"

func _short_attr(attr: String) -> String:
	match attr:
		"brand_awareness": return "知名"
		"brand_cognition": return "认知"
		"brand_association": return "联想"
		"brand_loyalty": return "忠诚"
		"channel_control": return "渠道"
	return attr

func _stage_name() -> String:
	for stage in all_data.get("stages", {}).get("stages", []):
		if stage.get("id", "") == state.stage_id:
			return stage.get("name", state.stage_id)
	return state.stage_id

func _basic_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(120, 44)
	btn.add_theme_font_size_override("font_size", 15)
	_apply_button_text_colors(btn)
	var style := _flat_style(Color(1, 1, 1, 0.9), Color("#ead2bf"), 12, 2)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	return btn

func _texture_style(path: String, x_margin: int, y_margin: int) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = _tex(path)
	style.texture_margin_left = x_margin
	style.texture_margin_right = x_margin
	style.texture_margin_top = y_margin
	style.texture_margin_bottom = y_margin
	return style

func _flat_style(color: Color, border_color: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.45, 0.28, 0.18, 0.10)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 2)
	return style

func _scaled_tex(path: String, max_size: int) -> Texture2D:
	var texture: Texture2D = _tex(path)
	if texture == null:
		return null
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return texture
	var image_size: Vector2i = image.get_size()
	if image_size.x <= max_size and image_size.y <= max_size:
		return texture
	var icon_scale: float = min(float(max_size) / float(image_size.x), float(max_size) / float(image_size.y))
	var width: int = max(1, int(round(image_size.x * icon_scale)))
	var height: int = max(1, int(round(image_size.y * icon_scale)))
	image.resize(width, height, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)

func _tex(path: String) -> Texture2D:
	if path == "":
		return null
	if FileAccess.file_exists(path + ".import"):
		var resource := load(path)
		if resource is Texture2D:
			return resource
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_warning("无法加载图片资源：%s" % path)
		return null
	return ImageTexture.create_from_image(image)
