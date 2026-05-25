class_name EndingSystem
extends RefCounted

func decide(state, all_data: Dictionary) -> Dictionary:
	var endings: Array = all_data.get("endings", {}).get("endings", [])
	for ending in endings:
		if _matches(ending.get("id", ""), state):
			return ending
	return _find(endings, "steady")

func _matches(id: String, state) -> bool:
	var a: Dictionary = state.attributes
	match id:
		"bankruptcy":
			return state.bankruptcy_negative_turns >= 3 or state.funds < 0
		"public_enemy":
			return int(a.get("brand_loyalty", 0)) <= 15
		"renaissance":
			return state.had_low_valley and state.recovered_from_low_valley and int(a.get("brand_loyalty", 0)) >= 70 and int(a.get("brand_association", 0)) >= 70 and state.funds >= 50 and state.successful_collab_or_innovation_count >= 1
		"flash_in_pan":
			return state.peak_awareness >= 90 and int(a.get("brand_awareness", 0)) < 30 and int(a.get("brand_loyalty", 0)) <= 40 and int(a.get("brand_cognition", 0)) <= 50
		"monument":
			return int(a.get("brand_awareness", 0)) >= 90 and int(a.get("brand_cognition", 0)) >= 90 and int(a.get("brand_association", 0)) >= 90 and int(a.get("brand_loyalty", 0)) >= 90 and int(a.get("channel_control", 0)) >= 80 and state.funds >= 200 and state.count_matched_trends() >= 3
		"hidden_champion":
			return int(a.get("brand_awareness", 0)) <= 55 and int(a.get("brand_cognition", 0)) >= 85 and int(a.get("brand_association", 0)) >= 70 and int(a.get("brand_loyalty", 0)) >= 85 and int(a.get("channel_control", 0)) <= 60 and state.funds >= 150 and state.cumulative_profit >= 280
		"capital_behemoth":
			return state.funds >= 300 and int(a.get("brand_loyalty", 0)) <= 30 and int(a.get("brand_association", 0)) <= 45 and int(a.get("brand_awareness", 0)) >= 60 and int(a.get("brand_cognition", 0)) >= 50 and state.high_risk_action_count >= 2
		"national_brand":
			return int(a.get("brand_awareness", 0)) >= 85 and int(a.get("brand_cognition", 0)) >= 70 and int(a.get("channel_control", 0)) >= 80 and int(a.get("brand_loyalty", 0)) >= 60 and state.funds >= 150
		"art_totem":
			return int(a.get("brand_association", 0)) >= 95 and int(a.get("brand_awareness", 0)) >= 70 and int(a.get("brand_loyalty", 0)) >= 70 and state.funds >= 80 and state.successful_collab_or_innovation_count >= 2
		"small_beautiful":
			return int(a.get("brand_loyalty", 0)) >= 90 and int(a.get("brand_cognition", 0)) >= 80 and int(a.get("brand_association", 0)) >= 70 and int(a.get("brand_awareness", 0)) <= 55 and int(a.get("channel_control", 0)) <= 50 and state.funds >= 50
		"reputation_island":
			return int(a.get("brand_loyalty", 0)) >= 80 and int(a.get("brand_cognition", 0)) >= 75 and int(a.get("brand_awareness", 0)) <= 40 and int(a.get("channel_control", 0)) <= 40 and state.funds <= 20
		"classic_old_brand":
			return state.has_tag("classic") and int(a.get("brand_loyalty", 0)) >= 75 and int(a.get("brand_awareness", 0)) >= 55 and int(a.get("brand_association", 0)) >= 65 and state.funds >= 60
		"sigh":
			return int(a.get("brand_cognition", 0)) >= 70 and int(a.get("brand_loyalty", 0)) >= 60 and int(a.get("brand_awareness", 0)) <= 50 and int(a.get("channel_control", 0)) <= 50 and state.funds <= 0
		"over_expansion":
			return int(a.get("channel_control", 0)) >= 80 and int(a.get("brand_awareness", 0)) >= 75 and int(a.get("brand_loyalty", 0)) <= 35 and state.funds <= 20
		"steady":
			return true
	return false

func _find(endings: Array, id: String) -> Dictionary:
	for ending in endings:
		if ending.get("id", "") == id:
			return ending
	return { "id": "steady", "name": "稳步经营", "description": "未找到结局数据。" }
