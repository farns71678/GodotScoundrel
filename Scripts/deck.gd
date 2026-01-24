extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn";
const CARD_DRAW_SPEED = 0.4;

var card_database = [];
var deck = [];
var card_database_reference;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_database();
	load_deck();
	deck.shuffle();
	update_deck_size_label();
	#card_database_reference = preload("res://Scripts/card_database.gd");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_database():
	var file = FileAccess.open("res://card_database.json", FileAccess.READ);
	var text_content = file.get_as_text();
	card_database = JSON.parse_string(text_content);

func load_deck():
	var file = FileAccess.open("res://card_collection.json", FileAccess.READ);
	var text_content = file.get_as_text();
	deck = JSON.parse_string(text_content);
	if (null):
		print("load deck failed");

func draw_card():
	var card_drawn = deck[0];
	deck.erase(card_drawn);
	
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true;
		$Sprite2D.visible = false;
		$RichTextLabel.visible = false;
	
	$RichTextLabel.text = str(deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate();
	$"../CardManager".add_child(new_card)
	new_card.name = "Card";
	var card_image_path = str("res://Assets/" + card_drawn + ".png");
	new_card.position = self.position;
	new_card.get_node("CardImage").texture = load(card_image_path);
	#new_card.get_node("AttackLabel").text = str(card_database_reference.CARDS[card_drawn][0]);
	#new_card.get_node("DefenseLabel").text = str(card_database_reference.CARDS[card_drawn][1]);
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED);
	new_card.get_node("AnimationPlayer").play("card_flip");

func draw_card_to_room_pos(index: int):
	if deck.size() == 0:
		return false;
	
	var card_drawn = deck[0];
	deck.erase(card_drawn);
	
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true;
		$Sprite2D.visible = false;
		$RichTextLabel.visible = false;
	
	update_deck_size_label();
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate();
	$"../CardManager".add_child(new_card)
	new_card.name = "Card";
	new_card.card_pile = Card.CARD_PILE.ROOM;
	var database_card = null;
	for i in range(len(card_database)):
		if (card_database[i].nice_name == card_drawn):
			database_card = card_database[i];
			break;
			
	var card_image_path = str(database_card.texture_path if database_card else "res://assets/card_empty.png");
	new_card.card_name = database_card.nice_name;
	new_card.value = database_card.value;
	new_card.suit = Card.SUIT_MAP[database_card.suit];
	new_card.position = self.position;
	new_card.get_node("CardImage").texture = load(card_image_path);
	#new_card.get_node("AttackLabel").text = str(card_database_reference.CARDS[card_drawn][0]);
	#new_card.get_node("DefenseLabel").text = str(card_database_reference.CARDS[card_drawn][1]);
	$"../Room".add_card_to_room_index(new_card, index, CARD_DRAW_SPEED);
	new_card.get_node("AnimationPlayer").play("card_flip");
	#$AudioStreamPlayer.play(0.1);
	return true;

func update_deck_size_label():
	$RichTextLabel.text = str(deck.size());

func add_card_to_bottom(card_name: String):
	deck.push_back(card_name);
	update_deck_size_label();
