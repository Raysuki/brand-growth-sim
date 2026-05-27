extends Node

const BODY_FONT: FontFile = preload("res://assets/猫啃网糖圆体.ttf")
const TITLE_FONT: FontFile = preload("res://assets/优设标题圆.otf")

const TITLE_NODE_NAMES := {
	"ActionTitle": true,
	"EventTitle": true,
	"EndingTitle": true,
	"TrendCardName": true,
	"KnowledgeTitle": true,
	"DetailTitle": true,
	"LogTitleLabel": true,
	"StageNameLabel": true,
	"NameLabel": true
}

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	call_deferred("_apply_to_tree")

func _apply_to_tree() -> void:
	var root := get_tree().root
	if root != null:
		_apply_to_node(root)

func _on_node_added(node: Node) -> void:
	if node is Control:
		call_deferred("_apply_to_node", node)

func _apply_to_node(node: Node) -> void:
	_apply_font(node)
	for child in node.get_children():
		_apply_to_node(child)

func _apply_font(node: Node) -> void:
	var font := TITLE_FONT if _is_title_node(node) else BODY_FONT
	if node is Label:
		(node as Label).add_theme_font_override("font", font)
	elif node is Button:
		(node as Button).add_theme_font_override("font", font)
	elif node is RichTextLabel:
		var rich := node as RichTextLabel
		rich.add_theme_font_override("normal_font", font)
		rich.add_theme_font_override("bold_font", font)
		rich.add_theme_font_override("italics_font", font)
		rich.add_theme_font_override("bold_italics_font", font)
		rich.add_theme_font_override("mono_font", BODY_FONT)
	elif node is LineEdit:
		(node as LineEdit).add_theme_font_override("font", font)
	elif node is TextEdit:
		(node as TextEdit).add_theme_font_override("font", font)

func _is_title_node(node: Node) -> bool:
	var node_name := String(node.name)
	if TITLE_NODE_NAMES.has(node_name):
		return true
	return node_name.ends_with("Title") or node_name.ends_with("TitleLabel")
