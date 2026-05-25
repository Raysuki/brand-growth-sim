class_name DataLoader
extends RefCounted

const DATA_FILES := {
	"attributes": "res://data/attributes.json",
	"economy": "res://data/economy.json",
	"stages": "res://data/stages.json",
	"trends": "res://data/trends.json",
	"actions": "res://data/actions.json",
	"events": "res://data/events.json",
	"endings": "res://data/endings.json"
}

var data := {}

func load_all() -> Dictionary:
	data.clear()
	for key in DATA_FILES.keys():
		data[key] = _load_json(DATA_FILES[key])
	return data

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing data file: %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON dictionary: %s" % path)
		return {}
	return parsed
