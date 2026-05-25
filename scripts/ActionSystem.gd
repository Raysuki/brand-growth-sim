class_name ActionSystem
extends RefCounted

func execute(action: Dictionary, state, all_data: Dictionary) -> Dictionary:
	var result := { "ok": false, "message": "", "applied": {} }
	var cost := int(action.get("cost", 0))
	var ap := int(action.get("ap", 1))
	if state.game_over:
		result.message = "游戏已结束"
		return result
	if state.action_points < ap:
		result.message = "行动点不足"
		return result
	if state.funds < cost:
		result.message = "资金不足"
		return result

	state.funds -= cost
	state.action_points -= ap
	var multiplier_value := _effect_multiplier(action, state, all_data)
	var applied: Dictionary = state.add_effects(action.get("effects", {}), multiplier_value)
	var risk_delta := int(action.get("risk", 0))
	state.public_risk += risk_delta
	state.public_risk = clampi(state.public_risk, 0, 100)
	state.ongoing_expense += int(action.get("ongoing_expense", 0))
	if bool(action.get("forecast_next_trend", false)):
		state.add_tag("forecast_next_trend")
	if action.has("tags"):
		for tag in action.get("tags", []):
			state.add_tag(str(tag))
	if _matches_current_trend(action, state):
		var entry := { "turn": state.current_turn, "id": action.get("id", ""), "category": action.get("category", ""), "trend": state.current_trend.get("id", "") }
		state.action_log.append(entry)
		state.recent_actions.append(entry)
	else:
		state.remember_action(action)

	result.ok = true
	result.applied = applied
	result.risk_delta = risk_delta
	result.cost = cost
	result.ap = ap
	result.multiplier = multiplier_value
	result.message = "%s 执行完成" % action.get("name", "行动")
	return result

func _effect_multiplier(action: Dictionary, state, all_data: Dictionary) -> float:
	var balance: Dictionary = all_data.get("economy", {}).get("balance", {})
	var base := float(balance.get("action_effect_multiplier", 1.0))
	base *= _diminishing_multiplier(action, state, all_data)
	base *= _beauty_multiplier(action, all_data)
	base *= _trend_multiplier(action, state)
	return base

func _diminishing_multiplier(action: Dictionary, state, all_data: Dictionary) -> float:
	var config: Dictionary = all_data.get("actions", {}).get("diminishing_returns", {})
	if action.get("category", "") == "crisis_pr" and bool(config.get("crisis_pr_exempt", true)):
		return 1.0
	var occurrences: int = state.count_recent_action(str(action.get("id", "")), int(config.get("window_turns", 3))) + 1
	if bool(config.get("trend_match_offsets_one_decay", true)) and _matches_current_trend(action, state):
		occurrences = max(1, occurrences - 1)
	var multipliers: Array = config.get("multipliers", [1.0, 0.85, 0.7])
	var value: float = float(multipliers[min(occurrences - 1, multipliers.size() - 1)])
	if action.get("category", "") == "market_research":
		value = max(value, float(config.get("market_research_minimum", 0.8)))
	return value

func _beauty_multiplier(action: Dictionary, all_data: Dictionary) -> float:
	var mods: Dictionary = all_data.get("attributes", {}).get("beauty_modifiers", {})
	var value := 1.0
	if action.get("category", "") == "visual_design":
		value *= float(mods.get("visual_design_multiplier", 1.0))
	var tags: Array = action.get("tags", [])
	if tags.has("social_seeding") or tags.has("kol"):
		value *= float(mods.get("social_or_kol_multiplier", 1.0))
	return value

func _trend_multiplier(action: Dictionary, state) -> float:
	if state.current_trend.is_empty():
		return 1.0
	if not _matches_current_trend(action, state):
		return 1.0
	var effect := str(state.current_trend.get("effect", ""))
	if effect.contains("2.0"):
		return 2.0
	if effect.contains("1.5"):
		return 1.5
	if effect.contains("1.3"):
		return 1.3
	return 1.0

func _matches_current_trend(action: Dictionary, state) -> bool:
	if state.current_trend.is_empty():
		return false
	var trend_tags: Array = state.current_trend.get("tags", [])
	var action_tags: Array = action.get("tags", [])
	if trend_tags.has("visual_design") and action.get("category", "") == "visual_design":
		return true
	for tag in action_tags:
		if trend_tags.has(tag):
			return true
	return false
