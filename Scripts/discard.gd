extends Node2D

var discard_pile = [];
var room_reference;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room_reference = $"../Room";
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_card_to_discard_pile(card):
	discard_pile.push_back(card);
	card.card_pile = Card.CARD_PILE.DISCARD;
	var discard_pos = $".".position;
	
	room_reference.animate_card_to_position(card, discard_pos);
	card.z_index = len(discard_pile) - 1;
	card.source_position = discard_pos;

func _on_discard_pile_clicked() -> void:
	room_reference._on_discard_pile_clicked();
	pass # Replace with function body.
