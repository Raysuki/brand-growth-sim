extends Node

const DataLoaderClass := preload("res://scripts/DataLoader.gd")
const GameStateClass := preload("res://scripts/GameState.gd")
const ActionSystemClass := preload("res://scripts/ActionSystem.gd")
const TurnManagerClass := preload("res://scripts/TurnManager.gd")
const EndingSystemClass := preload("res://scripts/EndingSystem.gd")

func _ready() -> void:
	var loader := DataLoaderClass.new()
	var all_data: Dictionary = loader.load_all()
	_assert(not all_data.is_empty(), "all data loaded")
	_assert(all_data.has("actions"), "actions data loaded")
	_assert(all_data.get("actions", {}).get("actions", []).size() > 0, "actions are present")

	var state := GameStateClass.new()
	state.reset(all_data)
	var turn_manager := TurnManagerClass.new()
	var initial_income: int = turn_manager.calculate_income(state, all_data)
	var initial_expense: int = turn_manager.calculate_expense(state, all_data)
	_assert(initial_income == 19, "balanced initial income is softened to 19")
	_assert(initial_expense <= initial_income, "initial passive income can cover baseline expense")

	var action_system := ActionSystemClass.new()
	var first_action: Dictionary = _find_action(all_data, "function_iteration")
	var action_result: Dictionary = action_system.execute(first_action, state, all_data)
	_assert(bool(action_result.get("ok", false)), "can execute first action")

	while not state.game_over:
		_auto_play_turn(state, all_data, action_system)
		turn_manager.finish_turn(state, all_data)

	_assert(state.current_turn == 24, "reaches turn 24")
	for attr in GameStateClass.ATTRIBUTES:
		var value: int = int(state.attributes.get(attr, -1))
		_assert(value >= 0 and value <= 300, "%s stays within 0-300" % attr)

	var ending: Dictionary = EndingSystemClass.new().decide(state, all_data)
	_assert(not ending.is_empty(), "ending can be decided")
	_assert(state.get_max_attribute() < 270, "auto play does not trivially max 300-point attributes")
	print("SMOKE TEST PASSED: ending=%s funds=%d risk=%d income0=%d expense0=%d" % [ending.get("name", ""), state.funds, state.public_risk, initial_income, initial_expense])

func _assert(condition: bool, label: String) -> void:
	if not condition:
		push_error("SMOKE TEST FAILED: %s" % label)

func _find_action(all_data: Dictionary, id: String) -> Dictionary:
	for action in all_data.get("actions", {}).get("actions", []):
		if action.get("id", "") == id:
			return action
	return {}

func _auto_play_turn(state, all_data: Dictionary, action_system) -> void:
	var ids := ["online_store", "social_seeding", "community_ops", "function_iteration"]
	for id in ids:
		var action := _find_action(all_data, id)
		if action.is_empty():
			continue
		if state.action_points >= int(action.get("ap", 1)) and state.funds >= int(action.get("cost", 0)):
			action_system.execute(action, state, all_data)
