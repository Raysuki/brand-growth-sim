extends RefCounted

static func get_categories() -> Array:
	return [
		{"id": "basic_terms", "name": "广告基础术语"},
		{"id": "pricing_terms", "name": "广告计价术语"},
		{"id": "platform_terms", "name": "广告平台术语"},
		{"id": "effect_terms", "name": "广告效果术语"},
		{"id": "ad_types", "name": "互联网广告类型"},
		{"id": "marketing_theories", "name": "营销理论与法则"},
	]

static func get_knowledge() -> Dictionary:
	return {
		"basic_terms": _basic_terms(),
		"pricing_terms": _pricing_terms(),
		"platform_terms": _platform_terms(),
		"effect_terms": _effect_terms(),
		"ad_types": _ad_types(),
		"marketing_theories": _marketing_theories(),
	}

static func make_id(category_id: String, item_name: String) -> String:
	return "%s:%s" % [category_id, item_name]

static func get_item(category_id: String, item_name: String) -> Dictionary:
	var items: Array = get_knowledge().get(category_id, [])
	for item in items:
		if str(item.get("name", "")) == item_name:
			var result: Dictionary = item.duplicate(true)
			result["category_id"] = category_id
			result["knowledge_id"] = make_id(category_id, item_name)
			return result
	return {}

static func _basic_terms() -> Array:
	return [
		{"name": "CTR", "summary": "点击率", "detail": "CTR(Click-Through-Rate):点击率，曝光变为点击的转化率，即点击到达率。"},
		{"name": "CPC", "summary": "点击付费", "detail": "CPC(Cost Per Click):一种点击付费广告，根据广告被点击的次数收费。"},
		{"name": "CPM", "summary": "展示付费", "detail": "CPM(Cost Per Mille):一种展示付费广告，只要展示了广告主的广告内容，广告主就为此付费。"},
		{"name": "eCPM", "summary": "千展收入", "detail": "eCPM(effective cost per mille)千展收入：已知CTR=5%，CPC=10元，则1000次展示收入eCPM=1000*5%*10=500元。对广告主来说是1000次展示需付费用，对广告平台来说是千展收入。"},
	]

static func _pricing_terms() -> Array:
	return [
		{"name": "CPA", "summary": "按效果计价", "detail": "CPA(Cost Per Action):按广告投放实际效果计价方式的广告，每次转化多少钱（如：注册）。"},
		{"name": "CPS", "summary": "按销售计价", "detail": "CPS(Cost Per Sales):以实际销售产品数量来计算广告费用的广告，每次成功交易收费。"},
		{"name": "CPT", "summary": "按时间计价", "detail": "CPT(Cost Per Time):以时间来计费的广告，和广告主签订合约在某个时间段内播放广告，固定收费模式。"},
		{"name": "CPD", "summary": "按下载计价", "detail": "CPD(Cost per Download):类似CPA，每次下载成本。也有解释为Cost per day即按天付费。"},
		{"name": "CPV", "summary": "视频播放计费", "detail": "CPV:视频信息流按播放计费的广告计费方式，一般按视频广告10s有效播放计费，只针对有效观看人群收费。"},
		{"name": "GFP", "summary": "广义第一价格", "detail": "GFP(Generalized First Price):广义第一价格，出价高者得，需要支付自己提出的报价。"},
		{"name": "GSP", "summary": "广义第二价格", "detail": "GSP(Generalized Second Price):广义第二价格，出价高者得，需要支付出价第二高者的报价再加一个最小溢价。是一种稳定的竞价方式，现阶段几乎所有互联网广告平台都使用。"},
		{"name": "VCG", "summary": "竞价计费方式", "detail": "VCG(Vickrey-Clarke-Groves):根据竞价者赢得广告位后，给整个竞价收入带来的收益损失收费。"},
		{"name": "oCPX", "summary": "优化出价方式", "detail": "oCPX:以目标转化为优化方式的出价方式，包括oCPC、oCPM、oCPA等。投放系统采用更精准的点击率和转化率预估机制，将广告展现给最容易产生转化的用户。"},
	]

static func _platform_terms() -> Array:
	return [
		{"name": "DMP", "summary": "数据管理平台", "detail": "DMP(Data-Management Platform):数据管理平台，有第一方和第三方的，加工用户数据在广告投放时做定向使用。"},
		{"name": "DSP", "summary": "需求方平台", "detail": "DSP(Demand Side Platform):需求方(广告主)平台，可管理广告计划及投放策略，包括设置受众定向条件、预算、出价、创意等。"},
		{"name": "ADX", "summary": "广告交易平台", "detail": "ADX(AdExchange):广告交易平台，基于RTB实时竞价，接入多家广告平台通过实时竞价实现收入最大化。"},
		{"name": "SSP", "summary": "广告供应平台", "detail": "SSP(Sell Side Platform):广告供应平台(面向售卖方)，媒体方通过SSP完成广告资源管理，如流量分配、价格筛选等。"},
		{"name": "RTB", "summary": "实时竞价", "detail": "RTB(RealTime Bidding):实时竞价，同一媒体的同一广告位同时有多个广告主需要时，通过实时竞价判断展示哪个广告。"},
		{"name": "RTA", "summary": "实时API", "detail": "RTA(RealTime API):通过实时挖掘海量数据，对用户兴趣迁移迅捷反应。可让广告主在投放前排除部分用户，减少重复投放或无效投放。设备重复率可低至2%。"},
		{"name": "BID", "summary": "出价", "detail": "BID(bid)出价:广告投放中，广告计划的出价。"},
	]

static func _effect_terms() -> Array:
	return [
		{"name": "ROI", "summary": "投资回报率", "detail": "ROI(Return On Investment):投资回报率，特定周期内广告主通过广告投放收回的价值占广告投入的比例。"},
		{"name": "CVR", "summary": "转化率", "detail": "CVR(Conversion Rate):转化率，衡量CPA广告效果的指标，即用户点击广告到成为有效激活或注册甚至付费用户的转化率。"},
		{"name": "ARPU", "summary": "每用户平均收入", "detail": "ARPU(Average Revenue Per User):每用户平均收入=总收入/总用户数。注重一个时间段内从每个用户所得到的利润，高端用户越多ARPU越高。"},
		{"name": "RPS", "summary": "每搜索收入", "detail": "RPS(Revenue Per Search):每搜索产生的收入，衡量搜索结果变现能力指标。"},
	]

static func _ad_types() -> Array:
	return [
		{"name": "信息流广告", "summary": "FEED ADS", "detail": "信息流广告(FEED ADS):融入用户自然浏览内容中的原生广告。展示在社交媒体、资讯平台、短视频平台。特点：原生性强、算法驱动精准推送、支持社交互动。计费方式：CPM/CPC/OCPM/OCPC。"},
		{"name": "搜索广告", "summary": "SEARCH ADS", "detail": "搜索广告(SEARCH ADS):基于用户主动搜索行为触发的广告。包括SEM(搜索引擎营销)、SEO(搜索引擎优化)、GEO(生成式引擎优化)。核心优势：高意向流量。计费方式：CPM/CPC/OCPM/OCPC。"},
		{"name": "展示广告", "summary": "DISPLAY ADS", "detail": "展示广告(DISPLAY ADS):通过视觉冲击吸引注意的曝光形式。包括Banner广告、开屏广告、插屏广告。投放逻辑：按人群包定向投放(DMP)、基于上下文匹配。计费方式：CPM/CPT。"},
		{"name": "社交媒体广告", "summary": "SOCIAL ADS", "detail": "社交媒体广告(SOCIAL ADS):依托社交关系链传播的广告形式。包括KOL/KOC推广、社群运营、互动广告。平台差异：微信生态高净值人群、抖音Z时代用户、小红书女性消费决策。"},
		{"name": "程序化广告", "summary": "PROGRAMMATIC", "detail": "程序化广告(PROGRAMMATIC ADS):通过自动化系统完成广告交易的模式。核心组件：DSP(需求方)、SSP(供应方)、DMP(数据)。交易模式：RTB(实时竞价)、PDB(私有程序化购买)、PMP(私有市场交易)。"},
	]

static func _marketing_theories() -> Array:
	return [
		{"name": "AIDA法则", "summary": "注意-兴趣-欲望-行动", "detail": "AIDA法则(1898年路易斯提出):描述消费者从接触广告到采取行动的心理路径。核心阶段：引起注意(Attention)→产生兴趣(Interest)→引起欲望(Desire)→促成行动(Action)。强调广告最终目的是引起购买行动。"},
		{"name": "USP理论", "summary": "独特销售主张", "detail": "USP理论(20世纪50年代罗瑟·瑞夫斯提出):广告应有独具特点的销售主张。三要素：①必须包含特定商品效用，给消费者明确利益承诺；②必须是独特的、唯一的；③必须有利于促进销售，能招来大众。"},
		{"name": "4P营销理论", "summary": "产品-价格-渠道-促销", "detail": "4P营销理论(1960年杰罗姆·麦卡锡提出):以产品为中心的营销组合理论。四要素：产品(Product)、价格(Price)、渠道(Place)、促销(Promotion)。"},
		{"name": "4C营销理论", "summary": "顾客-成本-方便-沟通", "detail": "4C营销理论(1990年罗伯特·劳特朋提出):从顾客角度出发，与4P对应。四要素：顾客(Consumer)、成本(Cost)、方便(Convenience)、沟通(Communication)。体现从产品中心到消费者中心的嬗变。"},
		{"name": "ROI理论", "summary": "关联-原创-震撼", "detail": "ROI理论(20世纪60年代威廉·伯恩巴克创立):优秀广告必须具备三个特征：关联性(Relevance)、原创性(Originality)、震撼力(Impact)。后演变为SPT法则：可搜索性、可参与性、可标签化。"},
		{"name": "IMC整合营销", "summary": "整合营销传播", "detail": "IMC(1991年唐·舒尔茨提出):以消费者和品牌关系为目的，以'一种声音'为支撑，以各种传播媒介整合运用为手段，使信息一体化，提供明晰持续且效果最大的营销沟通。目标是培植品牌忠诚，形成品牌资产。"},
		{"name": "SWOT分析法", "summary": "态势分析法", "detail": "SWOT分析法：将研究对象的内部优势(Strengths)、劣势(Weaknesses)和外部机会(Opportunities)、威胁(Threats)列举出来，依照矩阵形式排列，用系统分析思想相互匹配，得出相应结论，制定发展战略。"},
	]
