extends Node2D

signal left_mouse_btn_clicked
signal left_mouse_btn_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4

var card_manager_reference
var deck_reference
var room_reference

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"
	room_reference = $"../Room"

func _input(event: InputEvent) -> void:
	if (room_reference.game_over):
		return;
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_btn_clicked");
			raycast_at_cursor();
		else:
			emit_signal("left_mouse_btn_released");

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters);
	if (result.size() > 0):
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			# CARD CLICKED
			var card_found = result[0].collider.get_parent();
			if (card_found && card_found.drag_enabled):
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			pass
			# DECK CLICKED
			#deck_reference.draw_card()
			#room_reference.advance_room();


func _on_end_game_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StartScreen.tscn");
