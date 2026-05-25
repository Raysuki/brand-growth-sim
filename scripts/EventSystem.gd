class_name EventSystem
extends RefCounted

var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.seed = 20260521

func pick_event(state, all_data: Dictionary) -> Dictionary:
	if state.game_over:
		return {}
	var events: Array = all_data.get("events", {}).get("events", [])
	for event in events:
		if event.get("type", "") == "milestone" and _eligible(event, state):
			return event
	if state.public_risk >= 80:
		for event in events:
			if event.get("type", "") == "crisis" and _eligible(event, state):
				return event
	for event in events:
		if _eligible(event, state):
			var chance := int(event.get("condition", {}).get("chance", 0))
			if event.get("type", "") == "opportunity" and state.no_opportunity_turns >= 3:
				chance += 50
			if event.get("type", "") == "crisis" and state.public_risk >= 50 and int(event.get("condition", {}).get("risk_double_gte", 999)) <= state.public_risk:
				chance *= 2
			if chance > 0 and rng.randi_range(1, 100) <= chance:
				return event
	return {}

func apply_option(event: Dictionary, option: Dictionary, state, all_data := {}) -> Dictionary:
	var result := { "effects": {}, "message": "" }
	if option.has("cost"):
		state.funds -= int(option.get("cost", 0))
	if option.has("funds"):
		state.funds += int(option.get("funds", 0))
	if option.has("ap"):
		state.action_points = max(0, state.action_points - int(option.get("ap", 0)))
	var effect_multiplier := 1.0
	if typeof(all_data) == TYPE_DICTIONARY:
		effect_multiplier = float(all_data.get("economy", {}).get("balance", {}).get("event_effect_multiplier", 1.0))
	var applied: Dictionary = state.add_effects(option.get("effects", {}), effect_multiplier)
	state.public_risk += int(option.get("risk", 0))
	state.public_risk = clampi(state.public_risk, 0, 100)
	state.ongoing_expense += int(option.get("ongoing_expense", 0))
	if option.has("tags"):
		for tag in option.get("tags", []):
			state.add_tag(str(tag))
	if option.has("income_multiplier_turns"):
		state.income_multiplier_turns = int(option.get("income_multiplier_turns", 0))
		state.income_multiplier = float(option.get("income_multiplier", 1.0))
	if event.get("type", "") == "milestone":
		state.milestone_triggered[event.get("id", "")] = true
	if event.get("id", "") in ["divine_connection", "hit_product"] and option.get("id", "") != "refuse":
		state.successful_collab_or_innovation_count += 1
	state.event_log.append({ "turn": state.current_turn, "event": event.get("name", ""), "option": option.get("name", "") })
	result.effects = applied
	result.message = "%s：%s" % [event.get("name", ""), option.get("name", "")]
	return result

func _eligible(event: Dictionary, state) -> bool:
	if bool(event.get("condition", {}).get("once", false)) and state.milestone_triggered.has(event.get("id", "")):
		return false
	var c: Dictionary = event.get("condition", {})
	if c.has("turn_min") and state.current_turn < int(c["turn_min"]):
		return false
	if c.has("turn_max") and state.current_turn > int(c["turn_max"]):
		return false
	if c.has("brand_awareness_gte") and int(state.attributes.get("brand_awareness", 0)) < int(c["brand_awareness_gte"]):
		return false
	if c.has("brand_awareness_lte") and int(state.attributes.get("brand_awareness", 0)) > int(c["brand_awareness_lte"]):
		return false
	if c.has("brand_cognition_gte") and int(state.attributes.get("brand_cognition", 0)) < int(c["brand_cognition_gte"]):
		return false
	if c.has("brand_association_gte") and int(state.attributes.get("brand_association", 0)) < int(c["brand_association_gte"]):
		return false
	if c.has("brand_association_lte") and int(state.attributes.get("brand_association", 0)) > int(c["brand_association_lte"]):
		return false
	if c.has("brand_loyalty_gte") and int(state.attributes.get("brand_loyalty", 0)) < int(c["brand_loyalty_gte"]):
		return false
	if c.has("funds_gte") and state.funds < int(c["funds_gte"]):
		return false
	if c.has("funds_lte") and state.funds > int(c["funds_lte"]):
		return false
	if c.has("channel_control_gte") and int(state.attributes.get("channel_control", 0)) < int(c["channel_control_gte"]):
		return false
	if c.has("no_visual_design_turns_gte") and state.has_recent_category("visual_design", int(c["no_visual_design_turns_gte"])):
		return false
	if bool(c.get("recent_rnd_and_marketing", false)):
		if not state.has_recent_category("product_rnd", 3) or not state.has_recent_category("marketing", 3):
			return false
	if c.has("any"):
		var any_ok := false
		for item in c["any"]:
			any_ok = any_ok or _simple_condition(item, state)
		if not any_ok:
			return false
	return true

func _simple_condition(c: Dictionary, state) -> bool:
	if c.has("brand_association_lte") and int(state.attributes.get("brand_association", 0)) > int(c["brand_association_lte"]):
		return false
	if c.has("brand_awareness_gte") and int(state.attributes.get("brand_awareness", 0)) < int(c["brand_awareness_gte"]):
		return false
	if c.has("funds_gte") and state.funds < int(c["funds_gte"]):
		return false
	return true
