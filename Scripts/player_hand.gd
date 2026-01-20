extends Node2D

const CARD_WIDTH = 180
const HAND_Y_POSITION = 180
const CARD_DEFAULT_SPEED = 0.1;

var hand = [];
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	#var card_scene = preload(CARD_SCENE_PATH)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_card_to_hand(card, speed = CARD_DEFAULT_SPEED):
	if card not in hand:
		hand.insert(0, card);
		update_hand_positions(speed);
	else:
		animate_card_to_position(card, card.source_position)


func update_hand_positions(speed = CARD_DEFAULT_SPEED):
	for i in range(hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION);
		var card = hand[i];
		card.source_position = new_position;
		animate_card_to_position(card, new_position, speed);


func calculate_card_position(index):
	var total_width = (hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset


func animate_card_to_position(card, new_position, speed = CARD_DEFAULT_SPEED):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed);

func remove_card_from_hand(card):
	if (card in hand):
		hand.erase(card);
		update_hand_positions();
