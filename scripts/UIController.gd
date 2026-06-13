class_name UIController
extends CanvasLayer

signal create_route_pressed(origin_id: String)
signal confirm_route_pressed(destination_id: String, resource: String)
signal upgrade_pressed(settlement_id: String)
signal save_pressed
signal load_pressed
signal reset_pressed

var game_state: Node
var panel: PanelContainer
var info: RichTextLabel
var route_button: Button
var upgrade_button: Button
var resource_buttons: VBoxContainer
var routing_origin := ""

func setup(state: Node) -> void:
	game_state = state
	_build_ui()
	game_state.selection_changed.connect(_on_selection_changed)
	game_state.state_changed.connect(_refresh)

func _build_ui() -> void:
	var root := Control.new(); root.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(root)
	var top := HBoxContainer.new(); top.position = Vector2(12, 24); top.size = Vector2(696, 64); root.add_child(top)
	for label in ["Save", "Load", "Reset"]:
		var b := Button.new(); b.text = label; b.custom_minimum_size = Vector2(150, 56); top.add_child(b)
		if label == "Save": b.pressed.connect(func(): emit_signal("save_pressed"))
		if label == "Load": b.pressed.connect(func(): emit_signal("load_pressed"))
		if label == "Reset": b.pressed.connect(func(): emit_signal("reset_pressed"))
	var title := Label.new(); title.text = "Hearthlands Routebuilder"; title.position = Vector2(20, 94); title.add_theme_font_size_override("font_size", 28); root.add_child(title)
	panel = PanelContainer.new(); panel.position = Vector2(0, 820); panel.size = Vector2(720, 460); root.add_child(panel)
	var v := VBoxContainer.new(); v.add_theme_constant_override("separation", 8); panel.add_child(v)
	info = RichTextLabel.new(); info.fit_content = true; info.custom_minimum_size = Vector2(680, 245); v.add_child(info)
	route_button = Button.new(); route_button.text = "Create Route"; route_button.pressed.connect(_begin_route); v.add_child(route_button)
	upgrade_button = Button.new(); upgrade_button.text = "Upgrade"; upgrade_button.pressed.connect(func(): emit_signal("upgrade_pressed", game_state.selected_settlement_id)); v.add_child(upgrade_button)
	resource_buttons = VBoxContainer.new(); v.add_child(resource_buttons)

func _on_selection_changed(_id: String) -> void:
	if routing_origin != "" and _id != routing_origin:
		_show_resource_choices(_id)
	else:
		_refresh()

func _begin_route() -> void:
	routing_origin = game_state.selected_settlement_id
	_refresh("Tap a different settlement to choose a destination.")
	emit_signal("create_route_pressed", routing_origin)

func _show_resource_choices(destination_id: String) -> void:
	_clear_resource_buttons()
	info.text += "\n[b]Route destination selected. Choose cargo:[/b]"
	for resource in game_state.resources.keys():
		var b := Button.new(); b.text = "Send %s" % resource.capitalize(); resource_buttons.add_child(b)
		b.pressed.connect(_resource_choice_pressed.bind(destination_id, resource))

func _resource_choice_pressed(destination_id: String, resource: String) -> void:
	emit_signal("confirm_route_pressed", destination_id, resource)
	routing_origin = ""
	_refresh("Route created.")

func _refresh(message: String = "") -> void:
	_clear_resource_buttons()
	var settlement = game_state.get_settlement(game_state.selected_settlement_id)
	if settlement == null:
		info.text = "Tap a settlement to inspect it."
		route_button.disabled = true; upgrade_button.disabled = true
		return
	var industry: Dictionary = game_state.industries.get(settlement.industry_id, {})
	var mayor: Dictionary = game_state.mayors.get(settlement.mayor_id, {})
	var house: Dictionary = game_state.houses.get(settlement.house_id, {})
	var culture: Dictionary = game_state.cultures.get(settlement.culture_id, {})
	info.text = "[b]%s[/b]  %s\nPopulation: %d  Happiness: %.0f  Corruption: %.1f\nIndustry: %s\nMayor: %s (%s)\nHouse: %s, influence %s\nCulture: %s\nStorage: %s\nNeeds: %s\nShortages: %s" % [settlement.display_name, settlement.level_name(), settlement.population, settlement.happiness, settlement.corruption, industry.get("name", settlement.industry_id), mayor.get("name", "None"), mayor.get("trait", "None"), house.get("name", "None"), str(house.get("influence", 0)), culture.get("name", "None"), _dict_text(settlement.storage), _dict_text(settlement.needs), _dict_text(settlement.shortages)]
	if message != "": info.text += "\n[i]%s[/i]" % message
	route_button.disabled = routing_origin != ""
	upgrade_button.disabled = not can_upgrade(settlement)
	upgrade_button.text = "Upgrade to %s" % (["", "Village", "Town", "Max"][settlement.level])

func can_upgrade(settlement) -> bool:
	if settlement.level >= 3: return false
	if not settlement.shortages.is_empty() or settlement.happiness < 70.0: return false
	if settlement.level == 1: return settlement.population >= 25 and float(settlement.storage.get("wood", 0)) >= 5 and float(settlement.storage.get("food", 0)) >= 5
	return settlement.population >= 40 and float(settlement.storage.get("wood", 0)) >= 10 and float(settlement.storage.get("stone", 0)) >= 8

func _dict_text(dict: Dictionary) -> String:
	if dict.is_empty(): return "none"
	var parts := []
	for key in dict.keys(): parts.append("%s %.1f" % [str(key).capitalize(), float(dict[key])])
	return ", ".join(parts)

func _clear_resource_buttons() -> void:
	for child in resource_buttons.get_children(): child.queue_free()
