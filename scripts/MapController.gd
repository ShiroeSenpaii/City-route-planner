class_name MapController
extends Node2D

signal settlement_tapped(settlement_id: String)

var game_state: Node
var tile_size := Vector2(132, 132)
var origin := Vector2(30, 140)
var settlement_positions: Dictionary = {}
var terrain_colors := {"plains": Color("8fc46a"), "forest": Color("397d45"), "hill": Color("8b7a5e"), "river": Color("4b9bd3")}

func setup(state: Node) -> void:
	game_state = state
	game_state.state_changed.connect(queue_redraw)

func _draw() -> void:
	if game_state == null: return
	settlement_positions.clear()
	for tile in game_state.tiles:
		var pos := origin + Vector2(tile.x, tile.y) * tile_size
		draw_rect(Rect2(pos, tile_size - Vector2(8, 8)), terrain_colors.get(tile.terrain, Color.GRAY), true)
		draw_rect(Rect2(pos, tile_size - Vector2(8, 8)), Color(0,0,0,0.25), false, 3)
		_draw_text(tile.terrain.capitalize(), pos + Vector2(8, 24), 16, Color(0,0,0,0.65))
	for route in game_state.routes:
		var a = _settlement_center(route.origin_id)
		var b = _settlement_center(route.destination_id)
		draw_line(a, b, Color("f0d36a"), 8)
		draw_line(a, b, Color("5b421c"), 3)
		var cart := a.lerp(b, route.progress)
		draw_circle(cart, 14, Color("f4a742"))
		draw_rect(Rect2(cart - Vector2(10, 6), Vector2(20, 12)), Color("7a4a20"), true)
	for settlement in game_state.settlements.values():
		var center := _settlement_center(settlement.id)
		settlement_positions[settlement.id] = center
		draw_circle(center, 28, Color("f6e7b8"))
		draw_arc(center, 28, 0.0, TAU, 48, Color("3b2b1a"), 4.0)
		_draw_text(settlement.display_name, center + Vector2(-45, 50), 20, Color.WHITE)

func _settlement_center(id: String) -> Vector2:
	var settlement = game_state.get_settlement(id)
	return origin + Vector2(settlement.tile.x, settlement.tile.y) * tile_size + tile_size * 0.5

func _draw_text(text: String, pos: Vector2, size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_check_tap(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_check_tap(event.position)

func _check_tap(position: Vector2) -> void:
	for id in settlement_positions.keys():
		if position.distance_to(settlement_positions[id]) <= 44:
			emit_signal("settlement_tapped", id)
			return
