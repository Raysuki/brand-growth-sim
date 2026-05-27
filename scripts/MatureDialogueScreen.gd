extends Control

signal dialogue_finished

const BACKGROUND_PATH := "res://assets/backgrounds/行业峰会场景.png"

const DIALOGUE_DATA := [
	{"speaker": "旁白", "text": "看着台上正在侃侃而谈的人，你攥着提前准备好的手稿，抿了口水", "mode": "audience"},
	{"speaker": "旁边人", "text": "您好您好，我们是开风旗下的花花世界，上个月拜访过贵司的那个……", "mode": "audience"},
	{"speaker": "主理人", "text": "你点了点头，笑着没接话", "mode": "audience"},
	{"speaker": "旁白", "text": "台上的人讲完了，掌声一阵又一阵地响起，主持人念到了你的名字", "mode": "audience"},
	{"speaker": "旁白", "text": "你慢慢走上台去，聚光灯打在你身上，无数的视线看向你", "mode": "stage"},
	{"speaker": "主理人", "text": "作为特邀嘉宾，我很荣幸能够为大家分享经验……", "mode": "stage"},
	{"speaker": "主理人", "text": "三年前，我抱着纸箱从上一家公司走出来。三十五岁，被优化，不知道下一步往哪走。", "mode": "stage"},
	{"speaker": "主理人", "text": "我当时以为那是终点。后来才知道，那是起点。", "mode": "stage"},
	{"speaker": "旁白", "text": "你继续念着稿子，脑子里却回想着这些年，你创立品牌的点点滴滴。", "mode": "stage"},
	{"speaker": "旁白", "text": "从初创时的籍籍无名，到现在已然成为行业的领跑者……未来还很长", "mode": "stage"}
]

@onready var background: TextureRect = $Background
@onready var passerby_avatar: TextureRect = $PasserbyAvatar
@onready var mascot_avatar: TextureRect = $MascotAvatar
@onready var spotlight: ColorRect = $Spotlight
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
	_focus_speaker(speaker, str(entry.get("mode", "audience")))

func _focus_speaker(speaker: String, mode: String) -> void:
	var active_color := Color(1, 1, 1, 1)
	var inactive_color := Color(0.48, 0.48, 0.48, 0.86)
	var narration_color := Color(0.74, 0.74, 0.74, 0.74)

	var on_stage := mode == "stage"
	spotlight.visible = on_stage
	passerby_avatar.visible = not on_stage
	mascot_avatar.offset_left = 785.0 if not on_stage else 424.0
	mascot_avatar.offset_top = 104.0 if not on_stage else 36.0
	mascot_avatar.offset_right = 1275.0 if not on_stage else 896.0
	mascot_avatar.offset_bottom = 760.0 if not on_stage else 720.0

	passerby_avatar.modulate = inactive_color
	mascot_avatar.modulate = inactive_color

	match speaker:
		"旁边人":
			passerby_avatar.modulate = active_color
		"主理人":
			mascot_avatar.modulate = active_color
		_:
			passerby_avatar.modulate = narration_color
			mascot_avatar.modulate = active_color if on_stage else narration_color

func _load_texture(path: String) -> Texture2D:
	var loaded := load(path)
	if loaded is Texture2D:
		return loaded
	var image := Image.new()
	if image.load(path) != OK:
		push_warning("无法加载成熟期对话背景：%s" % path)
		return null
	return ImageTexture.create_from_image(image)
