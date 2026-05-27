@tool
extends Control

const DataLoaderClass := preload("res://scripts/DataLoader.gd")
const GameStateClass := preload("res://scripts/GameState.gd")
const ActionSystemClass := preload("res://scripts/ActionSystem.gd")
const TurnManagerClass := preload("res://scripts/TurnManager.gd")
const EventSystemClass := preload("res://scripts/EventSystem.gd")
const EndingSystemClass := preload("res://scripts/EndingSystem.gd")
const KnowledgeDataClass := preload("res://scripts/KnowledgeData.gd")
const GrowthDialogueScreenScene := preload("res://scenes/GrowthDialogueScreen.tscn")
const MatureDialogueScreenScene := preload("res://scenes/MatureDialogueScreen.tscn")

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

const ATTRIBUTE_MAX := 500

const ACTION_UNLOCK_TURNS := {
	"competitor_breakdown": 1,
	"data_mining": 1,
	"tech_breakthrough": 1,
	"visual_standard": 1,
	"ip_design": 1,
	"social_seeding": 1,
	"controversial_marketing": 1,
	"online_store": 1,
	"consumer_interview": 2,
	"function_iteration": 2,
	"community_ops": 2,
	"sincere_apology": 2,
	"logo_upgrade": 3,
	"package_redesign": 3,
	"business_negotiation": 3,
	"self_audit": 3,
	"ingredient_upgrade": 4,
	"ad_campaign": 4,
	"kol_collaboration": 4,
	"offline_distribution": 4,
	"user_co_creation": 5,
	"paid_astroturfing": 5,
	"market_forecast": 6,
	"vertical_channel": 6,
	"product_line_extension": 7,
	"event_marketing": 7,
	"membership_system": 8,
	"customer_service": 8,
	"media_briefing": 9
}

const ENDING_COPY := {
	"monument": {"title": "\u65f6\u4ee3\u4e30\u7891", "body": "\u4f60\u5b9a\u4e49\u4e86\u4e00\u6761\u65b0\u7684\u8d5b\u9053\n\u540e\u6765\u8005\u7ed5\u4e0d\u5f00\uff0c\u53ea\u80fd\u60f3\u529e\u6cd5\u8d70\u5f97\u66f4\u8fdc\n\u4e00\u4e2a\u54c1\u724c\u6d3b\u6210\u4e86\u65f6\u4ee3\u7684\u540d\u8bcd"},
	"hidden_champion": {"title": "\u9690\u5f62\u51a0\u519b", "body": "\u4f60\u505a\u5230\u4e86\u6781\u81f4\u7684\u7ec6\u5206\n\u867d\u7136\u8fd8\u6ca1\u7ed9\u6d88\u8d39\u8005\u4eec\u7559\u4e0b\u6df1\u523b\u5370\u8c61\n\u4f46\u5df2\u7136\u6210\u4e3a\u7ec6\u5206\u9886\u57df\u7684\u6807\u6746"},
	"capital_behemoth": {"title": "\u8d44\u672c\u5de8\u517d", "body": "\u89c4\u6a21\u3001\u62a5\u8868\u3001\u5229\u6da6\n\u4f60\u62e5\u6709\u4e86\u4e00\u5207\n\u9664\u4e86\u7528\u6237\u7684\u559c\u7231"},
	"national_brand": {"title": "\u56fd\u6c11\u54c1\u724c", "body": "\u5927\u4f17\u7684\u9009\u62e9\n\u65e5\u5e38\u7684\u4ee3\u8868\n\u4f60\u6210\u4e86\u6781\u5177\u4ee3\u8868\u6027\u7684\u56fd\u6c11\u54c1\u724c\u4e4b\u4e00"},
	"art_totem": {"title": "\u827a\u672f\u56fe\u817e", "body": "\u4f60\u7684\u4ea7\u54c1\u662f\u827a\u672f\u7684\u85cf\u54c1\n\u4f60\u7684\u54c1\u724c\u662f\u6587\u5316\u4e0e\u5ba1\u7f8e\u7684\u8c61\u5f81\n\u4f60\u662f\u7f8e\u7684\u6807\u6746\u4e0e\u98ce\u5411"},
	"small_beautiful": {"title": "\u5c0f\u800c\u7f8e\u4f20\u5947", "body": "\u4f60\u62e5\u6709\u4e00\u7fa4\u6781\u5ea6\u5fe0\u8bda\u7684\u7528\u6237\n\u4e0d\u5fc5\u8ba8\u597d\u6240\u6709\u4eba\uff0c\u4e5f\u80fd\u6d3b\u5f97\u6f02\u4eae"},
	"renaissance": {"title": "\u6587\u827a\u590d\u5174", "body": "\u66fe\u7ecf\u6c89\u5bc2\u4e86\u8bb8\u4e45\n\u4f46\u4e00\u6b21\u51b3\u7b56\u7684\u529b\u633d\u72c2\u6f9c\n\u8ba9\u4f60\u4e1c\u5c71\u518d\u8d77"},
	"reputation_island": {"title": "\u53e3\u7891\u5b64\u5c9b", "body": "\u6240\u6709\u4eba\u90fd\u79f0\u8d5e\u4f60\u7684\u4ea7\u54c1\n\u4f46\u5e02\u573a\u89c4\u6a21\u59cb\u7ec8\u505a\u4e0d\u8d77\u6765\n\u54c1\u724c\u6d3b\u5728\u53e3\u7891\u91cc\uff0c\u5374\u56f0\u5728\u8d26\u672c\u91cc"},
	"classic_old_brand": {"title": "\u7ecf\u5178\u8001\u724c", "body": "\u5fc3\u7167\u4e0d\u5ba3\u7684\u5171\u8bc6\n\u4ea4\u53e3\u79f0\u8d5e\u7684\u597d\u8bc4\n\u4f60\u7684\u54c1\u724c\u6700\u7ec8\u6210\u4e3a\u4e86\u4e00\u4ee3\u7ecf\u5178"},
	"sigh": {"title": "\u4e00\u58f0\u53f9\u606f", "body": "\u5162\u5162\u4e1a\u4e1a \u52e4\u52e4\u6073\u6073 \u6beb\u65e0\u8d77\u8272\n\u4f60\u7684\u6210\u679c\u5316\u4e3a\u529e\u516c\u5ba4\u91cc\u7684\u4e00\u58f0\u53f9\u606f"},
	"public_enemy": {"title": "\u4f17\u77e2\u4e4b\u7684", "body": "\u5371\u673a\u4e0e\u6d41\u91cf\u72c2\u6b22\n\u5168\u7f51\u4e00\u9762\u5012\u7684\u8bc4\u4ef7\n\u4f60\u88ab\u9489\u5728\u96c6\u4f53\u62b5\u5236\u7684\u53cd\u9762\u6848\u4f8b\u6559\u6750\u91cc"},
	"flash_in_pan": {"title": "\u6619\u82b1\u4e00\u73b0", "body": "\u6240\u6709\u4eba\u90fd\u5728\u8ba8\u8bba\u5b83\n\u6240\u6709\u4eba\u90fd\u9057\u5fd8\u4e86\u5b83\n\u98ce\u505c\u4e86\uff0c\u82b1\u8c22\u4e86"},
	"bankruptcy": {"title": "\u7834\u4ea7\u6e05\u7b97", "body": "\u8d44\u91d1\u94fe\u65ad\u88c2\n\u54c1\u724c\u7ecf\u8425\u5ba3\u544a\u7ec8\u6b62\n\u4f60\u8fce\u6765\u4e86\u7834\u4ea7\u6e05\u7b97"},
	"over_expansion": {"title": "\u8fc7\u5ea6\u6269\u5f20", "body": "\u57ce\u5e02\u6570\u91cf\u3001\u4ea7\u7ebf\u89c4\u6a21\u3001\u95e8\u5e97\u3001\n\u4f46\u7528\u6237\u5e76\u4e0d\u8ba4\u53ef\u4f60\n\u4f60\u906d\u53d7\u4e86\u53cd\u566c"}
}

const NPC_PATHS := {
	"市场部小划": "res://assets/npcs/市场部小划.png",
	"研发部小牌": "res://assets/npcs/研发部小牌.png",
	"设计部小计": "res://assets/npcs/设计部小计.png",
	"运营部小品": "res://assets/npcs/运营部小品.png",
	"主管": "res://assets/npcs/主管.png"
}

const KNOWLEDGE_ACTION_DROPS := {
	"event_marketing": [{"category": "marketing_theories", "name": "IMC整合营销"}],
	"ad_campaign": [{"category": "ad_types", "name": "程序化广告"}],
	"online_store": [{"category": "ad_types", "name": "搜索广告"}],
	"social_seeding": [{"category": "ad_types", "name": "社交媒体广告"}],
	"kol_collaboration": [{"category": "marketing_theories", "name": "AIDA法则"}],
	"community_ops": [{"category": "marketing_theories", "name": "4C营销理论"}],
	"business_negotiation": [{"category": "platform_terms", "name": "SSP"}],
	"market_forecast": [{"category": "platform_terms", "name": "DMP"}]
}

const KNOWLEDGE_EVENT_DROPS := {
	"organic_miracle": [{"category": "ad_types", "name": "信息流广告"}],
	"platform_tailwind": [{"category": "platform_terms", "name": "ADX"}, {"category": "platform_terms", "name": "RTB"}],
	"divine_connection": [{"category": "marketing_theories", "name": "USP理论"}],
	"breakthrough": [{"category": "effect_terms", "name": "ROI"}],
	"capital_temptation": [{"category": "pricing_terms", "name": "VCG"}],
	"position_crossroad": [{"category": "marketing_theories", "name": "4P营销理论"}],
	"hit_product": [{"category": "effect_terms", "name": "ARPU"}],
	"reputation_collapse": [{"category": "effect_terms", "name": "CVR"}]
}

const KNOWLEDGE_TURN_DROPS := [
	{"turn": 6, "category": "basic_terms", "name": "CTR"},
	{"turn": 12, "category": "basic_terms", "name": "CPC"},
	{"turn": 18, "category": "basic_terms", "name": "CPM"},
	{"turn": 24, "category": "basic_terms", "name": "eCPM"}
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
var previous_trend_id := ""
var action_stories := {}
var story_card_panel: PanelContainer = null
var story_card_queue: Array = []
var _story_finish_prefix := ""
var knowledge_popup: PanelContainer = null
var knowledge_popup_queue: Array = []
var growth_dialogue_screen: Control = null
var mature_dialogue_screen: Control = null

@onready var background_rect: TextureRect = %Background
@onready var mascot_rect: TextureRect = %Mascot
@onready var logo_rect: TextureRect = %Logo
@onready var status_label: Label = %StatusLabel
@onready var restart_button: Button = %RestartButton
@onready var stage_panel: PanelContainer = get_node_or_null("StagePanel") as PanelContainer
@onready var resource_panel: PanelContainer = get_node_or_null("ResourcePanel") as PanelContainer
@onready var attribute_panel: PanelContainer = $AttributePanel
@onready var action_panel_root: Control = $ActionPlanPanel
@onready var right_panel: PanelContainer = $ActionPlanPanel/RightPanel
@onready var stage_name_label: Label = %StageNameLabel
@onready var stage_turn_label: Label = %StageTurnLabel
@onready var funds_label: Label = %FundsValue
@onready var ap_label: Label = %APValue
@onready var risk_label: Label = %RiskValue
@onready var attribute_list: VBoxContainer = %AttributeList
@onready var log_label: RichTextLabel = %LogLabel
@onready var action_screen_shade: ColorRect = $ActionPlanPanel/ActionScreenShade
@onready var action_title: Label = $ActionPlanPanel/ActionTitle
@onready var category_scroll: ScrollContainer = $ActionPlanPanel/CategoryScroll
@onready var action_scroll: ScrollContainer = $ActionPlanPanel/ActionScroll
@onready var category_list: HBoxContainer = $ActionPlanPanel/CategoryScroll/CategoryList
@onready var action_list: VBoxContainer = $ActionPlanPanel/ActionScroll/ActionList
@onready var plan_label: Label = $ActionPlanPanel/PlanLabel
@onready var plan_panel: PanelContainer = $ActionPlanPanel/PlanPanel
@onready var finish_button: Button = $ActionPlanPanel/FinishTurnButton
@onready var clear_button: Button = $ActionPlanPanel/ClearPlanButton
@onready var event_panel: Control = %EventPanel
@onready var event_title: Label = %EventTitle
@onready var event_body: Label = %EventBody
@onready var event_options: VBoxContainer = %EventOptions
@onready var ending_panel: Control = %EndingPanel
@onready var ending_title: Label = %EndingTitle
@onready var ending_body: Label = %EndingBody
@onready var close_ending_button: Button = %CloseEndingButton
@onready var knowledge_button: Button = %KnowledgeButton
@onready var knowledge_panel: Control = $KnowledgePanel
@onready var sale_label: Label = %SaleValue
@onready var sale_button: Button = %SaleButton
@onready var trend_card_panel: Control = %TrendCardPanel
@onready var trend_card_name: Label = %TrendCardName
@onready var trend_card_desc: Label = %TrendCardDesc
@onready var trend_card_effect: Label = %TrendCardEffect
@onready var trend_card_close: Button = %TrendCardClose
@onready var trend_card_attr: Label = %TrendCardAttr
@onready var action_open_button: Button = $ActionPlanPanel/ActionOpenButton
@onready var action_close_button: Button = $ActionPlanPanel/ActionCloseButton

func _ready() -> void:
	all_data = loader.load_all()
	action_stories = _load_action_stories()
	state.reset(all_data)
	_bind_static_nodes()
	_build_attribute_rows()
	_build_story_card()
	_build_knowledge_popup()
	_unlock_knowledge_for_turn(state.current_turn)
	_refresh_ui("选择行动后，点击结束回合。")

func _bind_static_nodes() -> void:
	var startup_texture := _tex(str(BACKGROUND_PATHS.get("startup", "")))
	if startup_texture != null:
		background_rect.texture = startup_texture
	var mascot_texture := _tex(MASCOT_PATH)
	if mascot_texture != null:
		mascot_rect.texture = mascot_texture
	var logo_texture := _tex(LOGO_PATH)
	if logo_texture != null:
		logo_rect.texture = logo_texture
	var restart_texture := _tex(RESTART_ICON)
	if restart_texture != null:
		restart_button.icon = restart_texture
	restart_button.expand_icon = true
	action_panel_root.visible = true
	finish_button.text = ""
	var finish_texture := _tex(END_TURN_IMAGE_PATH)
	if finish_texture != null:
		finish_button.icon = finish_texture
	finish_button.expand_icon = true
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
	if not knowledge_button.pressed.is_connected(_on_knowledge_pressed):
		knowledge_button.pressed.connect(_on_knowledge_pressed)
	if not trend_card_close.pressed.is_connected(_on_trend_card_close):
		trend_card_close.pressed.connect(_on_trend_card_close)
	if not sale_button.pressed.is_connected(_on_sale_button_pressed):
		sale_button.pressed.connect(_on_sale_button_pressed)
	if not action_open_button.pressed.is_connected(_on_action_open):
		action_open_button.pressed.connect(_on_action_open)
	if not action_close_button.pressed.is_connected(_on_action_close):
		action_close_button.pressed.connect(_on_action_close)
	event_panel.visible = false
	ending_panel.visible = false
	knowledge_panel.visible = false
	if knowledge_panel.has_method("set_unlocked_knowledge"):
		knowledge_panel.call("set_unlocked_knowledge", state.acquired_knowledge)
	trend_card_panel.visible = false
	_set_action_panel_visible(false)
	previous_trend_id = str(state.current_trend.get("id", ""))

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
	knowledge_panel.z_index = 25
	trend_card_panel.z_index = 22
	action_screen_shade.z_index = 17
	right_panel.z_index = 18
	action_title.z_index = 19
	category_scroll.z_index = 19
	action_scroll.z_index = 19
	plan_panel.z_index = 19
	plan_label.z_index = 19
	finish_button.z_index = 19
	clear_button.z_index = 19
	action_close_button.z_index = 20

func _apply_readable_text_colors() -> void:
	var dark := Color("#4d372d")
	for node in get_tree().get_nodes_in_group("readable_text"):
		if node is Label:
			node.add_theme_color_override("font_color", dark)
	for label in [event_title, event_body, ending_title, ending_body, plan_label]:
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
		"ResourcePanel/ResourceMargin/ResourceGrid/RiskTile/RiskBox/RiskValue"
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
		"RiskTile/RiskBox/RiskValue"
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
	_setup_resource_tile("APTile/APBox", "AP", ICON_PATHS.action_points)
	_setup_resource_tile("RiskTile/RiskBox", "舆情风险", ICON_PATHS.public_risk)

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
	var stage_texture := _tex(str(BACKGROUND_PATHS.get(state.stage_id, BACKGROUND_PATHS.startup)))
	if stage_texture != null:
		background_rect.texture = stage_texture
	stage_name_label.text = _stage_name()
	stage_turn_label.text = "%d / %d 回合" % [state.current_turn, state.max_turns]
	sale_label.text = _trend_tile_text()
	var current_trend_id := str(state.current_trend.get("id", ""))
	if current_trend_id != "" and current_trend_id != previous_trend_id and previous_trend_id != "":
		_show_trend_card()
	previous_trend_id = current_trend_id

	var planned_cost := _planned_cost()
	var planned_ap := _planned_ap()
	risk_label.text = "%d" % state.public_risk
	status_label.text = message
	funds_label.text = "%d" % state.funds
	funds_label.tooltip_text = "本回合计划资金：-%d" % planned_cost
	ap_label.text = "%d / %d" % [state.action_points - planned_ap, state.action_points_max]
	ap_label.tooltip_text = "本回合已安排 AP：%d" % planned_ap

	for attr in GameStateClass.ATTRIBUTES:
		if attr_rows.has(attr):
			var row: Dictionary = attr_rows[attr]
			var value := int(state.attributes.get(attr, 0))
			(row.get("bar") as ProgressBar).value = value
			if row.has("value_label"):
				(row.get("value_label") as Label).text = "%d / %d" % [value, ATTRIBUTE_MAX]

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
		btn.icon = _scaled_tex(str(CATEGORY_ICON_PATHS.get(id, ICON_PATHS.get(_category_icon_id(id), ""))), 64)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn.expand_icon = false
		btn.custom_minimum_size = Vector2(96, 82)
		btn.clip_text = true
		btn.add_theme_font_size_override("font_size", 1)
		_apply_button_text_colors(btn)
		var style := _flat_style(Color("#fff0f4") if id == selected_category else Color(1, 1, 1, 0.94), Color("#ff9fb4") if id == selected_category else Color("#ead2bf"), 14, 3 if id == selected_category else 2)
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
	btn.custom_minimum_size = Vector2(0, 72)
	btn.icon = _scaled_tex(str(CATEGORY_ICON_PATHS.get(str(action.get("category", "")), ICON_PATHS.get(_category_icon_id(str(action.get("category", ""))), ""))), 56)
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	btn.expand_icon = false
	btn.text = "%s\n资金 %d   AP %d    %s" % [
		action.get("name", ""),
		int(action.get("cost", 0)),
		int(action.get("ap", 1)),
		_action_effect_text(action)
	]
	btn.tooltip_text = "点击加入本回合计划，结束回合后统一执行"
	btn.add_theme_font_size_override("font_size", 18)
	_apply_button_text_colors(btn)
	var style := _texture_style(ACTION_CARD_ACTIVE_PATH if _planned_has_action(action) else ACTION_CARD_PATH, 34, 22)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	var disabled_reason := _action_disabled_reason(action)
	if disabled_reason != "":
		btn.tooltip_text = disabled_reason
		btn.modulate = Color(0.55, 0.55, 0.55, 0.72)
	btn.disabled = disabled_reason != ""
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
	bar.max_value = ATTRIBUTE_MAX
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 18)
	var value_label := Label.new()
	value_label.text = "0 / %d" % ATTRIBUTE_MAX
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 13)
	value_label.add_theme_color_override("font_color", Color("#ffffff"))
	value_label.add_theme_color_override("font_outline_color", Color("#7a6d66"))
	value_label.add_theme_constant_override("outline_size", 2)
	value_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.add_child(label)
	box.add_child(bar)
	bar.add_child(value_label)
	row.add_child(box)
	attr_rows[attr_id] = { "bar": bar, "label": label, "value_label": value_label }
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

func _rebuild_plan() -> void:
	var names := []
	for action in planned_actions:
		names.append(str(action.get("name", "")))
	plan_label.text = "本回合计划：%s    合计资金 %d / AP %d" % [
		", ".join(names) if not names.is_empty() else "未选择",
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
	if _action_disabled_reason(action) != "":
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
	_set_action_panel_visible(false)
	var executed := []
	var executed_actions: Array = []
	for action in planned_actions:
		var result: Dictionary = action_system.execute(action, state, all_data)
		if bool(result.get("ok", false)):
			executed.append(str(action.get("name", "")))
			executed_actions.append(action.duplicate(true))
			_unlock_knowledge_for_action(action)
	planned_actions.clear()
	_story_finish_prefix = "已执行：%s" % (", ".join(executed) if not executed.is_empty() else "无")
	if executed_actions.is_empty():
		_after_story_cards()
		return
	story_card_queue.clear()
	for i in range(1, executed_actions.size()):
		story_card_queue.append({"action": executed_actions[i], "turn": state.current_turn})
	_show_story_card(executed_actions[0], state.current_turn)

func _finish_turn_after_events(prefix := "") -> void:
	var previous_stage_id := state.stage_id
	var summary := turn_manager.finish_turn(state, all_data)
	_unlock_knowledge_for_turn(int(summary.get("turn", 0)))
	var text := "回合结算：收入 %d，总开销 %d，净利润 %+d。" % [summary.get("income", 0), summary.get("expense", 0), summary.get("profit", 0)]
	if int(summary.get("spending", 0)) > 0:
		text += " 其中行动/事件花费 %d。" % summary.get("spending", 0)
	_refresh_ui("%s  %s" % [prefix, text])
	_maybe_show_growth_dialogue(previous_stage_id)
	_maybe_show_mature_dialogue(previous_stage_id)

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
	_unlock_knowledge_for_event(event)
	event_panel.visible = false
	_finish_turn_after_events(result.get("message", ""))

func _show_ending() -> void:
	_apply_ending_copy()

func _apply_ending_copy() -> void:
	ending_panel.visible = true
	var ending_id := str(state.final_ending.get("id", ""))
	var copy: Dictionary = ENDING_COPY.get(ending_id, {})
	var ending_name := str(copy.get("title", state.final_ending.get("name", "")))
	var ending_text := str(copy.get("body", state.final_ending.get("description", "")))
	ending_title.text = "结局：%s" % ending_name
	ending_body.text = "%s\n\n最终资金：%d\n累计利润：%d\n知名/认知/联想/忠诚/渠道：%d / %d / %d / %d / %d" % [
		ending_text,
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
	knowledge_popup_queue.clear()
	if knowledge_popup != null:
		knowledge_popup.visible = false
	if growth_dialogue_screen != null:
		growth_dialogue_screen.queue_free()
		growth_dialogue_screen = null
	if mature_dialogue_screen != null:
		mature_dialogue_screen.queue_free()
		mature_dialogue_screen = null
	planned_actions.clear()
	state.reset(all_data)
	_unlock_knowledge_for_turn(state.current_turn)
	if knowledge_panel.has_method("set_unlocked_knowledge"):
		knowledge_panel.call("set_unlocked_knowledge", state.acquired_knowledge)
	_refresh_ui("已重新开始。")

func _on_close_ending() -> void:
	ending_panel.visible = false

func _on_knowledge_pressed() -> void:
	knowledge_panel.visible = true

func _on_action_open() -> void:
	_set_action_panel_visible(true)
	_rebuild_categories()
	_rebuild_actions()

func _on_action_close() -> void:
	_set_action_panel_visible(false)

func _set_action_panel_visible(visible_flag: bool) -> void:
	action_screen_shade.visible = visible_flag
	right_panel.visible = visible_flag
	action_title.visible = visible_flag
	category_scroll.visible = visible_flag
	category_list.visible = visible_flag
	action_scroll.visible = visible_flag
	action_list.visible = visible_flag
	plan_panel.visible = visible_flag
	plan_label.visible = visible_flag
	finish_button.visible = visible_flag
	clear_button.visible = visible_flag
	action_close_button.visible = visible_flag
	action_open_button.visible = not visible_flag
	get_node("LogPanel").visible = not visible_flag
	get_node("LogTitlePanel").visible = not visible_flag
	log_label.visible = not visible_flag

func _on_sale_button_pressed() -> void:
	if not state.current_trend.is_empty():
		_show_trend_card()

func _on_trend_card_close() -> void:
	trend_card_panel.visible = false

func _show_trend_card() -> void:
	var trend := state.current_trend
	if trend.is_empty():
		return
	trend_card_name.text = str(trend.get("name", ""))
	trend_card_desc.text = str(trend.get("description", ""))
	trend_card_effect.text = str(trend.get("effect", ""))
	trend_card_attr.text = "关联属性：%s | 联动行动：%s" % [_trend_attr_name(trend), _trend_description(trend)]
	trend_card_panel.visible = true

func _trend_tile_text() -> String:
	var trend := state.current_trend
	if trend.is_empty():
		return "无"
	return "%s\n%s" % [trend.get("name", "无"), trend.get("effect", "")]

func _extract_multiplier(effect: String) -> String:
	var regex := RegEx.new()
	if regex.compile("[x×X]\\s*[0-9]+(?:\\.[0-9]+)?") != OK:
		return "加成"
	var result := regex.search(effect)
	if result == null:
		return "加成"
	return result.get_string().replace("x", "×").replace("X", "×")

func _trend_description(trend: Dictionary) -> String:
	var tags: Array = trend.get("tags", [])
	var tag_names := []
	for tag in tags:
		tag_names.append(_action_name_by_tag(str(tag)))
	return ", ".join(tag_names) if not tag_names.is_empty() else "无"

func _trend_attr_name(trend: Dictionary) -> String:
	return _short_attr(str(trend.get("attribute", "")))

func _action_name_by_tag(tag: String) -> String:
	for action in all_data.get("actions", {}).get("actions", []):
		var tags: Array = action.get("tags", [])
		if tags.has(tag) or str(action.get("id", "")) == tag:
			return str(action.get("name", tag))
	return tag

func _can_plan(action: Dictionary) -> bool:
	return _is_action_unlocked(action) and _planned_ap() + int(action.get("ap", 1)) <= state.action_points and _planned_cost() + int(action.get("cost", 0)) <= state.funds

func _action_disabled_reason(action: Dictionary) -> String:
	if state.game_over:
		return "游戏已结束"
	if event_panel.visible:
		return "请先处理当前事件"
	if not _is_action_unlocked(action):
		return "第 %d 回合解锁" % _unlock_turn_for_action(action)
	if _planned_ap() + int(action.get("ap", 1)) > state.action_points:
		return "行动点不足"
	if _planned_cost() + int(action.get("cost", 0)) > state.funds:
		return "资金不足"
	return ""

func _is_action_unlocked(action: Dictionary) -> bool:
	return state.current_turn >= _unlock_turn_for_action(action)

func _unlock_stage_for_action(action: Dictionary) -> String:
	return str(_unlock_turn_for_action(action))

func _unlock_turn_for_action(action: Dictionary) -> int:
	return int(ACTION_UNLOCK_TURNS.get(str(action.get("id", "")), 1))

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
		push_warning("Unable to load texture: %s" % path)
		return null
	return ImageTexture.create_from_image(image)

func _unlock_knowledge_for_action(action: Dictionary) -> void:
	var action_id := str(action.get("id", ""))
	for drop in KNOWLEDGE_ACTION_DROPS.get(action_id, []):
		_unlock_knowledge(drop, "行动掉落")

func _unlock_knowledge_for_event(event: Dictionary) -> void:
	var event_id := str(event.get("id", ""))
	for drop in KNOWLEDGE_EVENT_DROPS.get(event_id, []):
		_unlock_knowledge(drop, "事件掉落")

func _unlock_knowledge_for_turn(turn_number: int) -> void:
	for drop in KNOWLEDGE_TURN_DROPS:
		if int(drop.get("turn", 0)) == turn_number:
			_unlock_knowledge(drop, "回合掉落")

func _unlock_knowledge(drop: Dictionary, source: String) -> void:
	var category_id := str(drop.get("category", ""))
	var item_name := str(drop.get("name", ""))
	var item := KnowledgeDataClass.get_item(category_id, item_name)
	if item.is_empty():
		push_warning("Knowledge drop not found: %s / %s" % [category_id, item_name])
		return
	var knowledge_id := str(item.get("knowledge_id", KnowledgeDataClass.make_id(category_id, item_name)))
	if bool(state.acquired_knowledge.get(knowledge_id, false)):
		return
	state.acquired_knowledge[knowledge_id] = true
	if knowledge_panel != null and knowledge_panel.has_method("reveal_knowledge"):
		knowledge_panel.call("reveal_knowledge", knowledge_id)
	item["drop_source"] = source
	_queue_knowledge_popup(item)

func _queue_knowledge_popup(item: Dictionary) -> void:
	knowledge_popup_queue.append(item)
	if knowledge_popup == null or not knowledge_popup.visible:
		_show_next_knowledge_popup()

func _show_next_knowledge_popup() -> void:
	if knowledge_popup == null or knowledge_popup_queue.is_empty():
		return
	var item: Dictionary = knowledge_popup_queue.pop_front()
	var title_node := knowledge_popup.find_child("KnowledgePopupTitle", true, false)
	if title_node is Label:
		title_node.text = "获得知识：%s" % item.get("name", "")
	var source_node := knowledge_popup.find_child("KnowledgePopupSource", true, false)
	if source_node is Label:
		source_node.text = str(item.get("drop_source", "知识掉落"))
	var body_node := knowledge_popup.find_child("KnowledgePopupBody", true, false)
	if body_node is Label:
		body_node.text = "%s\n\n%s" % [item.get("summary", ""), item.get("detail", "")]
	knowledge_popup.visible = true
	knowledge_popup.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(knowledge_popup, "modulate:a", 1.0, 0.2)

func _on_knowledge_popup_close() -> void:
	if knowledge_popup == null:
		return
	knowledge_popup.visible = false
	_show_next_knowledge_popup()

func _build_knowledge_popup() -> void:
	knowledge_popup = PanelContainer.new()
	knowledge_popup.name = "KnowledgeDropPopup"
	knowledge_popup.visible = false
	knowledge_popup.z_index = 35
	knowledge_popup.offset_left = 330.0
	knowledge_popup.offset_top = 160.0
	knowledge_popup.offset_right = 950.0
	knowledge_popup.offset_bottom = 560.0
	knowledge_popup.add_theme_stylebox_override("panel", _flat_style(Color(1, 0.985, 0.955, 0.98), Color("#f0c8ac"), 20, 3))
	add_child(knowledge_popup)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_bottom", 26)
	knowledge_popup.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.name = "KnowledgePopupTitle"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#4d372d"))
	vbox.add_child(title)

	var source := Label.new()
	source.name = "KnowledgePopupSource"
	source.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	source.add_theme_font_size_override("font_size", 16)
	source.add_theme_color_override("font_color", Color("#9a6a54"))
	vbox.add_child(source)

	var body := Label.new()
	body.name = "KnowledgePopupBody"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", 18)
	body.add_theme_color_override("font_color", Color("#4d372d"))
	vbox.add_child(body)

	var close_btn := Button.new()
	close_btn.text = "收下"
	close_btn.custom_minimum_size = Vector2(140, 44)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.add_theme_font_size_override("font_size", 18)
	_apply_button_text_colors(close_btn)
	var btn_style := _flat_style(Color(1, 1, 1, 0.92), Color("#ead2bf"), 14, 2)
	close_btn.add_theme_stylebox_override("normal", btn_style)
	close_btn.add_theme_stylebox_override("hover", btn_style)
	close_btn.add_theme_stylebox_override("pressed", btn_style)
	close_btn.pressed.connect(_on_knowledge_popup_close)
	vbox.add_child(close_btn)

func _maybe_show_growth_dialogue(previous_stage_id: String) -> void:
	if previous_stage_id == "growth":
		return
	if state.stage_id != "growth":
		return
	if bool(state.seen_stage_dialogues.get("growth", false)):
		return
	state.seen_stage_dialogues["growth"] = true
	growth_dialogue_screen = GrowthDialogueScreenScene.instantiate()
	growth_dialogue_screen.z_index = 40
	if growth_dialogue_screen.has_signal("dialogue_finished"):
		growth_dialogue_screen.dialogue_finished.connect(_on_growth_dialogue_finished)
	add_child(growth_dialogue_screen)

func _on_growth_dialogue_finished() -> void:
	growth_dialogue_screen = null

func _maybe_show_mature_dialogue(previous_stage_id: String) -> void:
	if previous_stage_id == "mature":
		return
	if state.stage_id != "mature":
		return
	if bool(state.seen_stage_dialogues.get("mature", false)):
		return
	state.seen_stage_dialogues["mature"] = true
	mature_dialogue_screen = MatureDialogueScreenScene.instantiate()
	mature_dialogue_screen.z_index = 40
	if mature_dialogue_screen.has_signal("dialogue_finished"):
		mature_dialogue_screen.dialogue_finished.connect(_on_mature_dialogue_finished)
	add_child(mature_dialogue_screen)

func _on_mature_dialogue_finished() -> void:
	mature_dialogue_screen = null

func _load_action_stories() -> Dictionary:
	var path := "res://data/action_stories.json"
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed.get("stories", {})

func _build_story_card() -> void:
	story_card_panel = PanelContainer.new()
	story_card_panel.name = "StoryCardPanel"
	story_card_panel.visible = false
	story_card_panel.z_index = 20
	story_card_panel.offset_left = 250.0
	story_card_panel.offset_top = 160.0
	story_card_panel.offset_right = 1030.0
	story_card_panel.offset_bottom = 560.0
	var style := _flat_style(Color(1, 0.985, 0.955, 0.97), Color(0.941, 0.784, 0.675, 1), 22, 3)
	story_card_panel.add_theme_stylebox_override("panel", style)
	add_child(story_card_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 28)
	story_card_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var title_label := Label.new()
	title_label.name = "StoryTurnTitle"
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", Color("#4d372d"))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox)

	var portrait := TextureRect.new()
	portrait.name = "StoryPortrait"
	portrait.custom_minimum_size = Vector2(160, 200)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(portrait)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 12)
	hbox.add_child(text_box)

	var npc_name_label := Label.new()
	npc_name_label.name = "StoryNpcName"
	npc_name_label.add_theme_font_size_override("font_size", 18)
	npc_name_label.add_theme_color_override("font_color", Color("#6b4c3a"))
	text_box.add_child(npc_name_label)

	var story_text := Label.new()
	story_text.name = "StoryText"
	story_text.add_theme_font_size_override("font_size", 17)
	story_text.add_theme_color_override("font_color", Color("#4d372d"))
	story_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_box.add_child(story_text)

	var effect_label := Label.new()
	effect_label.name = "StoryEffect"
	effect_label.add_theme_font_size_override("font_size", 14)
	effect_label.add_theme_color_override("font_color", Color("#8a6a5c"))
	text_box.add_child(effect_label)

	var close_btn := Button.new()
	close_btn.name = "StoryCloseBtn"
	close_btn.text = "继续"
	close_btn.custom_minimum_size = Vector2(120, 44)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.add_theme_font_size_override("font_size", 18)
	_apply_button_text_colors(close_btn)
	var btn_style := _flat_style(Color(1, 1, 1, 0.92), Color("#ead2bf"), 14, 2)
	close_btn.add_theme_stylebox_override("normal", btn_style)
	close_btn.add_theme_stylebox_override("hover", btn_style)
	close_btn.add_theme_stylebox_override("pressed", btn_style)
	close_btn.pressed.connect(_on_story_card_close)
	vbox.add_child(close_btn)

func _show_story_card(action: Dictionary, turn_number: int) -> void:
	var action_id := str(action.get("id", ""))
	var story: Dictionary = action_stories.get(action_id, {})
	var story_text := str(story.get("text", "行动完成。"))
	var npc_name := str(story.get("npc", ""))
	var npc_path := str(NPC_PATHS.get(npc_name, ""))

	var title_node := story_card_panel.find_child("StoryTurnTitle", true, false)
	if title_node is Label:
		title_node.text = "第 %d 回合" % turn_number

	var portrait_node := story_card_panel.find_child("StoryPortrait", true, false)
	if portrait_node is TextureRect:
		portrait_node.texture = _tex(npc_path)

	var npc_label := story_card_panel.find_child("StoryNpcName", true, false)
	if npc_label is Label:
		npc_label.text = npc_name

	var text_node := story_card_panel.find_child("StoryText", true, false)
	if text_node is Label:
		text_node.text = story_text

	var effect_node := story_card_panel.find_child("StoryEffect", true, false)
	if effect_node is Label:
		effect_node.text = "花费 -%d，%s" % [int(action.get("cost", 0)), _action_effect_text(action) if not action.get("effects", {}).is_empty() else "无直接属性提升"]

	story_card_panel.visible = true

func _on_story_card_close() -> void:
	story_card_panel.visible = false
	if not story_card_queue.is_empty():
		var next: Dictionary = story_card_queue.pop_front()
		_show_story_card(next.get("action", {}), next.get("turn", 1))
	else:
		_after_story_cards()

func _after_story_cards() -> void:
	pending_event = event_system.pick_event(state, all_data)
	if not pending_event.is_empty():
		_show_event(pending_event)
		return
	_finish_turn_after_events(_story_finish_prefix)

func _cn_number(n: int) -> String:
	return str(n)
