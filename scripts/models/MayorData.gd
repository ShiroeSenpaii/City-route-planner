class_name MayorData
extends RefCounted

var display_name: String
var trait_name: String
var production_bonus: float
var happiness_bonus: float
var corruption_bonus: float

func _init(data: Dictionary = {}) -> void:
	display_name = str(data.get("name", "Unappointed"))
	trait_name = str(data.get("trait", "None"))
	production_bonus = float(data.get("production_bonus", 0.0))
	happiness_bonus = float(data.get("happiness_bonus", 0.0))
	corruption_bonus = float(data.get("corruption_bonus", 0.0))
