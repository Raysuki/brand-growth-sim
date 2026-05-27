class_name TurnManager
extends RefCounted

var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.seed = 20260520

func calculate_income(state, all_data := {}) -> int:
	var awareness := float(state.attributes.get("brand_awareness", 0))
	var cognition := float(state.attributes.get("brand_cognition", 0))
	var association := float(state.attributes.get("brand_association", 0))
	var loyalty := float(state.attributes.get("brand_loyalty", 0))
	var channel := float(state.attributes.get("channel_control", 0))
	var sales_index := (cognition * channel / 100.0) * (1.0 + awareness / 100.0)
	var price_factor := 1.0 + association / 200.0
	var repurchase_factor := 1.0 + loyalty / 250.0
	var balance := {}
	if typeof(all_data) == TYPE_DICTIONARY:
		balance = all_data.get("economy", {}).get("balance", {})
	var income_multiplier := float(balance.get("income_multiplier", 2.2))
	var income := int(round(sales_index * price_factor * repurchase_factor * income_multiplier))
	if state.income_multiplier_turns > 0:
		income = int(round(float(income) * state.income_multiplier))
	return income

func calculate_expense(state, all_data: Dictionary) -> int:
	var economy: Dictionary = all_data.get("economy", {})
	var balance: Dictionary = economy.get("balance", {})
	var expense := int(balance.get("base_expense", economy.get("base_expense", 10)))
	expense += int(economy.get("stage_extra", {}).get(state.stage_id, 0))
	var awareness := int(state.attributes.get("brand_awareness", 0))
	var channel := int(state.attributes.get("channel_control", 0))
	var scale: Dictionary = economy.get("scale_extra", {})
	if awareness >= 70 or channel >= 70:
		expense += int(scale.get("single_if_awareness_or_channel_gte_70", 3))
	if awareness >= 70 and channel >= 70:
		expense += int(scale.get("additional_if_awareness_and_channel_gte_70", 2))
	var total_attr := 0
	for attr in ["brand_awareness", "brand_cognition", "brand_association", "brand_loyalty", "channel_control"]:
		total_attr += int(state.attributes.get(attr, 0))
	expense += int(floor(float(total_attr) / float(balance.get("attribute_maintenance_divisor", 9999))))
	expense += max(0, state.ongoing_expense)
	return max(expense, int(balance.get("minimum_expense", expense)))

func finish_turn(state, all_data: Dictionary) -> Dictionary:
	var income := calculate_income(state, all_data)
	var operating_expense := calculate_expense(state, all_data)
	var spending := int(state.current_turn_spending)
	var expense := operating_expense + spending
	var operating_profit := income - operating_expense
	var profit := income - expense
	state.funds += operating_profit
	state.cumulative_profit += profit
	_apply_risk_decay(state, all_data)
	state.clamp_attributes()
	if state.funds < 0:
		state.bankruptcy_negative_turns += 1
	else:
		state.bankruptcy_negative_turns = 0
	if state.income_multiplier_turns > 0:
		state.income_multiplier_turns -= 1
		if state.income_multiplier_turns <= 0:
			state.income_multiplier = 1.0
	var summary := {
		"turn": state.current_turn,
		"income": income,
		"expense": expense,
		"operating_expense": operating_expense,
		"spending": spending,
		"profit": profit,
		"funds": state.funds,
		"risk": state.public_risk
	}
	state.log_turn(summary)
	if state.bankruptcy_negative_turns >= 3:
		state.game_over = true
	if state.current_turn >= state.max_turns:
		state.game_over = true
	else:
		state.current_turn += 1
		state.start_turn(all_data)
	return summary

func _apply_risk_decay(state, all_data: Dictionary) -> void:
	var decay: Dictionary = all_data.get("economy", {}).get("risk_decay", {})
	var delta := int(decay.get("base_per_turn", -4))
	var did_high_risk := false
	var did_repair := false
	for entry in state.action_log:
		if int(entry.get("turn", 0)) == state.current_turn:
			if str(entry.get("category", "")) == "crisis_pr":
				did_repair = true
	if int(state.attributes.get("brand_loyalty", 0)) >= 70:
		delta += int(decay.get("loyalty_gte_70_extra", -2))
	for entry in state.recent_actions:
		if int(entry.get("turn", 0)) == state.current_turn and str(entry.get("id", "")) in ["controversial_marketing", "paid_astroturfing"]:
			did_high_risk = true
	if did_repair:
		delta += int(decay.get("repair_action_extra", -3))
	if did_high_risk and bool(decay.get("high_risk_blocks_extra_decay", true)):
		delta = int(decay.get("base_per_turn", -4))
	state.public_risk += delta

func is_major_sale_turn(state, all_data: Dictionary) -> bool:
	var cycle_turn: int = ((int(state.current_turn) - 1) % 6) + 1
	return all_data.get("stages", {}).get("major_sales_turns_in_cycle", []).has(cycle_turn)
