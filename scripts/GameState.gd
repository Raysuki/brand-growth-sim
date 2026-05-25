class_name GameState
extends RefCounted

const ATTRIBUTES := [
	"brand_awareness",
	"brand_cognition",
	"brand_association",
	"brand_loyalty",
	"channel_control"
]

var current_turn := 1
var max_turns := 24
var stage_id := "startup"
var funds := 0
var cumulative_profit := 0
var public_risk := 0
var action_points_max := 4
var action_points := 4
var attributes := {}
var ongoing_expense := 0
var income_multiplier_turns := 0
var income_multiplier := 1.0
var current_trend := {}
var next_trend := {}
var trend_index := 0
var game_over := false
var final_ending := {}
var bankruptcy_negative_turns := 0
var no_opportunity_turns := 0
var milestone_triggered := {}
var tags := {}
var peak_awareness := 0
var had_low_valley := false
var recovered_from_low_valley := false
var successful_collab_or_innovation_count := 0
var high_risk_action_count := 0
var crisis_pr_recent_turns := []
var recent_actions := []
var action_log := []
var event_log := []
var turn_log := []

func reset(all_data: Dictionary) -> void:
	var initial: Dictionary = all_data.get("attributes", {}).get("initial", {})
	current_turn = 1
	stage_id = "startup"
	funds = int(initial.get("funds", 100))
	cumulative_profit = 0
	public_risk = int(initial.get("public_risk", 0))
	action_points_max = int(initial.get("action_points_max", 4))
	action_points = action_points_max
	attributes.clear()
	for attr in ATTRIBUTES:
		attributes[attr] = int(initial.get(attr, 0))
	ongoing_expense = 0
	income_multiplier_turns = 0
	income_multiplier = 1.0
	trend_index = 0
	game_over = false
	final_ending = {}
	bankruptcy_negative_turns = 0
	no_opportunity_turns = 0
	milestone_triggered.clear()
	tags.clear()
	peak_awareness = int(attributes.get("brand_awareness", 0))
	had_low_valley = false
	recovered_from_low_valley = false
	successful_collab_or_innovation_count = 0
	high_risk_action_count = 0
	crisis_pr_recent_turns.clear()
	recent_actions.clear()
	action_log.clear()
	event_log.clear()
	turn_log.clear()
	_update_trend(all_data)

func start_turn(all_data: Dictionary) -> void:
	action_points = action_points_max
	_update_stage(all_data)
	_update_trend(all_data)

func _update_trend(all_data: Dictionary) -> void:
	var trends: Array = all_data.get("trends", {}).get("trends", [])
	if trends.is_empty():
		current_trend = {}
		next_trend = {}
		return
	trend_index = int(floor(float(current_turn - 1) / 3.0)) % trends.size()
	current_trend = trends[trend_index]
	next_trend = trends[(trend_index + 1) % trends.size()]

func _update_stage(_all_data: Dictionary) -> void:
	var max_attr := get_max_attribute()
	if current_turn >= 17 and max_attr >= 75 and funds >= 150:
		stage_id = "mature"
	elif current_turn >= 9 and max_attr >= 50 and funds >= 80:
		stage_id = "growth"
	elif current_turn <= 8:
		stage_id = "startup"

func get_max_attribute() -> int:
	var value := 0
	for attr in ATTRIBUTES:
		value = max(value, int(attributes.get(attr, 0)))
	return value

func clamp_attributes() -> void:
	for attr in ATTRIBUTES:
		attributes[attr] = clampi(int(attributes.get(attr, 0)), 0, 300)
	public_risk = clampi(public_risk, 0, 100)

func add_effects(effects: Dictionary, multiplier_value := 1.0) -> Dictionary:
	var applied := {}
	for attr in effects.keys():
		var delta := int(round(float(effects[attr]) * multiplier_value))
		if ATTRIBUTES.has(attr):
			attributes[attr] = int(attributes.get(attr, 0)) + delta
			applied[attr] = delta
	clamp_attributes()
	peak_awareness = max(peak_awareness, int(attributes.get("brand_awareness", 0)))
	return applied

func remember_action(action: Dictionary) -> void:
	var entry := {
		"turn": current_turn,
		"id": action.get("id", ""),
		"name": action.get("name", ""),
		"category": action.get("category", "")
	}
	action_log.append(entry)
	recent_actions.append(entry)
	while recent_actions.size() > 12:
		recent_actions.pop_front()
	if bool(action.get("high_risk", false)):
		high_risk_action_count += 1
	if action.get("category", "") == "crisis_pr":
		crisis_pr_recent_turns.append(current_turn)
		while crisis_pr_recent_turns.size() > 8:
			crisis_pr_recent_turns.pop_front()

func add_tag(tag_id: String) -> void:
	if tag_id != "":
		tags[tag_id] = true

func has_tag(tag_id: String) -> bool:
	return bool(tags.get(tag_id, false))

func count_recent_category(category_id: String, turns_back: int) -> int:
	var count := 0
	for entry in action_log:
		if int(entry.get("turn", 0)) >= current_turn - turns_back + 1 and entry.get("category", "") == category_id:
			count += 1
	return count

func count_recent_action(action_id: String, turns_back: int) -> int:
	var count := 0
	for entry in action_log:
		if int(entry.get("turn", 0)) >= current_turn - turns_back + 1 and entry.get("id", "") == action_id:
			count += 1
	return count

func has_recent_category(category_id: String, turns_back: int) -> bool:
	return count_recent_category(category_id, turns_back) > 0

func had_recent_crisis_pr(turns_back: int) -> bool:
	for turn_number in crisis_pr_recent_turns:
		if int(turn_number) >= current_turn - turns_back + 1:
			return true
	return false

func count_matched_trends() -> int:
	var matched := {}
	for entry in action_log:
		if entry.has("trend") and str(entry["trend"]) != "":
			matched[str(entry["trend"])] = true
	return matched.size()

func log_turn(summary: Dictionary) -> void:
	turn_log.append(summary)
	if int(attributes.get("brand_awareness", 0)) <= 20 and int(attributes.get("brand_loyalty", 0)) <= 30:
		had_low_valley = true
	if had_low_valley and int(attributes.get("brand_awareness", 0)) >= 80:
		recovered_from_low_valley = true
