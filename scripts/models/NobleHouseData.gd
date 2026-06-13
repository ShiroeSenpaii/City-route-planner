class_name NobleHouseData
extends RefCounted

var display_name: String
var influence: int

func _init(data: Dictionary = {}) -> void:
	display_name = str(data.get("name", "House Unsworn"))
	influence = int(data.get("influence", 0))
