extends Control

const DIALOGUE_DATA := [
	{"speaker": "看板娘", "text": "                 项目终于结项了。(你慢腾腾从会议室回到工位上，深舒了一口气)"},
	{"speaker": "看板娘", "text": "                 连续三个月，盯完了六轮物料修改、扛住了三次预算缩减、安抚了两个想中途退出的供应商。"},
	{"speaker": "看板娘", "text": "               好在最后数据很漂亮——ROI 达成 132%，比目标还超了 12 个百分点"},
	{"speaker": "看板娘", "text": "               终于能歇一歇了，你想。（全然没注意到转角走过来欲言又止的主管）"},
	{"speaker": "主管", "text": "               这次项目你辛苦了，但公司复盘后，认为成本控制和团队协作上还有很大优化空间"},
	{"speaker": "主管", "text": "               接下来会调整市场打法，你负责的方向暂时没有headcount了"},
	{"speaker": "看板娘", "text": "               可项目刚顺利结束，我们的数据反馈也很好……"},
	{"speaker": "主管", "text": "               你的能力没问题的，只是方向调整。公司会按N+2补偿，刚好你也趁这个机会多休息休息，陪陪家里人"},
]

@onready var background: TextureRect = $Background
@onready var mascot: TextureRect = $Mascot
@onready var supervisor: TextureRect = $Supervisor
@onready var name_label: Label = $DialogueBox/NameLabel
@onready var text_label: Label = $DialogueBox/TextLabel
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var click_hint: Label = $DialogueBox/ClickHint

var current_index := -1
var mascot_visible := false
var supervisor_visible := false
var supervisor_target_pos: Vector2
var supervisor_moving := false
var move_speed := 1500.0  # 像素/秒

func _ready() -> void:
	mascot.visible = false
	supervisor.visible = false
	dialogue_box.visible = false
	supervisor_target_pos = supervisor.position  # 记录目标位置
	_advance_dialogue()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance_dialogue()

func _process(delta: float) -> void:
	if supervisor_moving:
		supervisor.position = supervisor.position.move_toward(
			supervisor_target_pos,
			move_speed * delta
		)

		if supervisor.position.distance_to(supervisor_target_pos) < 1.0:
			supervisor.position = supervisor_target_pos
			supervisor_moving = false

func _advance_dialogue() -> void:
	current_index += 1
	if current_index >= DIALOGUE_DATA.size():
		get_tree().change_scene_to_file("res://scenes/TransitionScreen.tscn")
		return

	var entry: Dictionary = DIALOGUE_DATA[current_index]
	var speaker: String = entry["speaker"]

	dialogue_box.visible = true
	name_label.text = speaker
	text_label.text = entry["text"]

	if speaker == "看板娘":
		if not mascot_visible:
			mascot.visible = true
			mascot_visible = true
		mascot.modulate = Color(1, 1, 1, 1)
		if supervisor_visible:
			supervisor.modulate = Color(0.5, 0.5, 0.5, 1)
	elif speaker == "主管":
		if not supervisor_visible:
			supervisor.visible = true
			supervisor_visible = true
				# 👇 从右侧屏幕外开始
			var viewport_size = get_viewport_rect().size
			supervisor.position = Vector2(viewport_size.x + 200, supervisor_target_pos.y)

			supervisor_moving = true
		supervisor.modulate = Color(1, 1, 1, 1)
		if mascot_visible:
			mascot.modulate = Color(0.5, 0.5, 0.5, 1)
