extends Control

signal dialogue_finished

const BACKGROUND_PATH := "res://assets/backgrounds/会议室开会场景.png"

const DIALOGUE_DATA := [
	{"speaker": "市场部小划", "text": "ROI超目标28%，新客成本比上季度降了四成。"},
	{"speaker": "市场部小划", "text": "各个渠道的增长率都进了品类前十。简单说——我们成功了！"},
	{"speaker": "旁白", "text": "会议室安静了两秒，随即响起持续不断的掌声和笑声"},
	{"speaker": "产品经理小成", "text": "现在要想清楚——接下来是往宽了做，还是往深了做。宽，扩品类；深，我们继续打透这一个。"},
	{"speaker": "旁白", "text": "大家讨论起来，声音嘈杂，人声交叠"},
	{"speaker": "主理人", "text": "好了，现在我们品牌经营步入正轨，各种策略免不得调整，各部门交一份下季度规划给我，会就先开到这里"}
]

@onready var background: TextureRect = $Background
@onready var market_avatar: TextureRect = $MarketAvatar
@onready var product_avatar: TextureRect = $ProductAvatar
@onready var mascot_avatar: TextureRect = $MascotAvatar
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var name_label: Label = $DialogueBox/Margin/VBox/NameLabel
@onready var text_label: Label = $DialogueBox/Margin/VBox/TextLabel
@onready var hint_label: Label = $DialogueBox/Margin/VBox/HintLabel

var current_index := -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	background.texture = _load_texture(BACKGROUND_PATH)
	dialogue_box.visible = true
	hint_label.text = "点击继续..."
	_advance_dialogue()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance_dialogue()

func _advance_dialogue() -> void:
	current_index += 1
	if current_index >= DIALOGUE_DATA.size():
		dialogue_finished.emit()
		queue_free()
		return

	var entry: Dictionary = DIALOGUE_DATA[current_index]
	var speaker := str(entry.get("speaker", "旁白"))
	name_label.text = speaker
	text_label.text = str(entry.get("text", ""))
	_focus_speaker(speaker)

func _focus_speaker(speaker: String) -> void:
	var active_color := Color(1, 1, 1, 1)
	var inactive_color := Color(0.45, 0.45, 0.45, 0.85)
	var narration_color := Color(0.72, 0.72, 0.72, 0.72)

	market_avatar.modulate = inactive_color
	product_avatar.modulate = inactive_color
	mascot_avatar.modulate = inactive_color

	match speaker:
		"市场部小划":
			market_avatar.modulate = active_color
		"产品经理小成":
			product_avatar.modulate = active_color
		"主理人":
			mascot_avatar.modulate = active_color
		_:
			market_avatar.modulate = narration_color
			product_avatar.modulate = narration_color
			mascot_avatar.modulate = narration_color

func _load_texture(path: String) -> Texture2D:
	var loaded := load(path)
	if loaded is Texture2D:
		return loaded
	var image := Image.new()
	if image.load(path) != OK:
		push_warning("无法加载对话背景：%s" % path)
		return null
	return ImageTexture.create_from_image(image)
