class_name Card extends Node2D

signal hovered
signal hovered_off

enum CARD_PILE {
	DRAW,
	DISCARD,
	ROOM,
	WEAPON,
	OTHER
};

enum SUIT {
	SPADE,
	HEART,
	CLUB,
	DIAMOND,
	UNDEFINED
};

const SUIT_MAP = {
	"S": SUIT.SPADE,
	"H": SUIT.HEART,
	"C": SUIT.CLUB,
	"D": SUIT.DIAMOND,
	"": SUIT.UNDEFINED
};

var source_position;
var drag_enabled = false;
var card_name = "";
var card_pile = CARD_PILE.OTHER;
var collision_enabled = true;
var value = 0;
var suit: SUIT = SUIT.UNDEFINED;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be a child of cardmanager or this will error
	get_parent().connect_card_signals(self);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self);


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self);
