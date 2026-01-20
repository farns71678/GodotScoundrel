extends Node2D

const CARD_WIDTH = 180;
const ROOM_Y_POSITION = 180;
const ROOM_X_POSITION = 400;
const CARD_DEFAULT_SPEED = 0.1;
const WEAPON_STACK_Y_POSITION = 550;
const WEAPON_CARD_SIZE = 180;

var room: Array[Card] = [null, null, null, null];
var equiped_weapon: Card = null;
var weapon_stack: Array[Card] = [];
var discard_reference;
var deck_reference;
var face_btn;
var skip_btn;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	discard_reference = $"../Discard";
	deck_reference = $"../Deck";
	face_btn = $"../FaceRoomBtn";
	skip_btn = $"../SkipRoomBtn";
	advance_room();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func advance_room():
	for i in range (len(room)):
		if (room[i] == null):
			var drawn = $"../Deck".draw_card_to_room_pos(i);
			if (!drawn):
				print("Game over! You Won!");
				return;


func animate_card_to_position(card: Card, new_position: Vector2, speed = CARD_DEFAULT_SPEED):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed);

func add_card_to_room_index(card, index: int, speed = CARD_DEFAULT_SPEED):
	room[index] = card;
	var pos = Vector2(ROOM_X_POSITION + CARD_WIDTH * index, ROOM_Y_POSITION)
	animate_card_to_position(card, pos, speed);
	card.source_position = pos;
	


func _on_face_room_btn_pressed() -> void:
	skip_btn.disabled = true;
	face_btn.disabled = true;
	''' Random Face room for testing
	var kept_index = randi_range(0, 3);
	for i in range(len(room)):
		if (i != kept_index && room[i] != null):
			play_card_effect(room[i]);
			discard_reference.add_card_to_discard_pile(room[i]);
			room[i] = null;
	'''

func play_card_effect(card: Card):
	match (card.suit):
		Card.SUIT.SPADE:
			fight_monster(card);
		Card.SUIT.HEART:
			take_potion(card);
		Card.SUIT.CLUB:
			fight_monster(card);
		Card.SUIT.DIAMOND:
			equip_weapon(card);
		_:
			print("other");
	
func fight_monster(card: Card):
	var health_label = $"../Health".get_node("HealthLabel");
	var health: int = int(health_label.text);
	health = max(0, health - card.value);
	health_label.text = str(health);
	discard_reference.add_card_to_discard_pile(card);
	print("Fought", card.card_name, ".", "New Health:\t", health);

func take_potion(card: Card):
	var health_label = $"../Health".get_node("HealthLabel");
	var health: int = int(health_label.text);
	health = min(20, health + card.value);
	health_label.text = str(health);
	discard_reference.add_card_to_discard_pile(card);
	print("Healed to", health, "health");

func equip_weapon(card: Card):
	if (equiped_weapon != null):
		for i in range(len(weapon_stack)):
			discard_reference.add_card_to_discard_pile(weapon_stack[i]);
		weapon_stack = [];
		discard_reference.add_card_to_discard_pile(equiped_weapon);
	
	equiped_weapon = card;
	shift_weapon_stack();

func shift_weapon_stack():
	var center_screen = get_viewport().size.x / 2;
	const offset = -60;
	var weapon_num = len(weapon_stack) + 1;
	for i in range(weapon_num):
		var weapon: Card = equiped_weapon if i == 0 else weapon_stack[i];
		var pos = Vector2(center_screen - (WEAPON_CARD_SIZE + offset * weapon_num) / 2, WEAPON_STACK_Y_POSITION);
		animate_card_to_position(weapon, pos, 0.3);
			
			

func _on_card_left_click_released(card: Card):
	if (!card):
		return;
	
	if (!face_btn.disabled || !skip_btn.disabled):
		face_btn.disabled = true;
		skip_btn.disabled = true;
	
	for i in range (len(room)):
		if (room[i] == card):
			play_card_effect(room[i]);
			# do -v in play_card_effect functions
			#discard_reference.add_card_to_discard_pile(room[i]);
			room[i] = null;
			
			if (room.count(null) == 3):
				face_btn.disabled = false;
				skip_btn.disabled = false;
				advance_room();
			
			break;

func _on_skip_room_btn_pressed() -> void:
	skip_btn.disabled = true;
	face_btn.disabled = true;
	for i in range(len(room)):
		if (room[i] != null):
			var card = room[i];
			#new_card.get_node("AnimationPlayer").play("card_flip");
			card.z_index = -3;
			animate_card_to_position(card, deck_reference.position);
			deck_reference.add_card_to_bottom(card.card_name);
			room[i] = null;
			
			var timer = Timer.new();
			timer.timeout.connect(func(): 
				card.queue_free();
			);
			timer.wait_time = CARD_DEFAULT_SPEED;
			timer.one_shot = true;
			timer.autostart = true;
			add_child(timer);
	advance_room();
