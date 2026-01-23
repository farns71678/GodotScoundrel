extends Node2D

const CARD_WIDTH = 180;
const ROOM_Y_POSITION = 180;
const ROOM_X_POSITION = 400;
const CARD_DEFAULT_SPEED = 0.1;
const WEAPON_STACK_Y_POSITION = 550;
const WEAPON_CARD_SIZE = 180;

enum ROOM_STATE {
	NORMAL,
	DEFEND	
};

var room: Array[Card] = [null, null, null, null];
var equiped_weapon: Card = null;
var weapon_stack: Array[Card] = [];
var discard_reference;
var deck_reference;
var instruction_label;
var face_btn;
var skip_btn;
var room_state: ROOM_STATE = ROOM_STATE.NORMAL;
var selected_card: int = -1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	discard_reference = $"../Discard";
	deck_reference = $"../Deck";
	face_btn = $"../FaceRoomBtn";
	skip_btn = $"../SkipRoomBtn";
	instruction_label = $"../InstuctionsLabel";
	set_instruction("Face or Skip the room");
	advance_room();
	pass # Replace with function body.

func set_instruction(label: String):
	instruction_label.text = label;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func advance_room(can_skip: bool = true):
	skip_btn.disabled = !can_skip;
	if (can_skip):
		face_btn.disabled = false;
		set_instruction("Face or Skip room");
	else:
		face_btn.disabled = true;
		set_instruction("Face 3 out of the 4 cards");
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
	set_instruction("Face 3 out of the 4 cards");
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
			return fight_monster(card);
		Card.SUIT.HEART:
			return take_potion(card);
		Card.SUIT.CLUB:
			return fight_monster(card);
		Card.SUIT.DIAMOND:
			return equip_weapon(card);
		_:
			print("other");
	return true; # should never get to this

func fight_monster(card: Card):
	if (equiped_weapon && (!len(weapon_stack) || weapon_stack[len(weapon_stack) - 1].value > card.value)):
		set_instruction("Block with weapon or take damage");
		room_state = ROOM_STATE.DEFEND;
		return false;
		#var glow: WorldEnvironment = equiped_weapon.get_node("WorldEnvironment");
		#glow.environment.glow_intensity = 2;
	else:
		take_damage(card.value);
		discard_reference.add_card_to_discard_pile(card);
		return true;
	#set_instruction("Block with weapon or take damage");
	#print("Fought", card.card_name, ".", "New Health:\t", health);

func take_damage(damage: int):
	var health_label = $"../Health".get_node("HealthLabel");
	var health: int = int(health_label.text);
	health = max(0, health - damage);
	health_label.text = str(health);

func take_potion(card: Card):
	var health_label = $"../Health".get_node("HealthLabel");
	var health: int = int(health_label.text);
	health = min(20, health + card.value);
	health_label.text = str(health);
	discard_reference.add_card_to_discard_pile(card);
	print("Healed to ", health, " health");
	return true;

func equip_weapon(card: Card):
	if (equiped_weapon != null):
		for i in range(len(weapon_stack)):
			discard_reference.add_card_to_discard_pile(weapon_stack[i]);
		weapon_stack = [];
		discard_reference.add_card_to_discard_pile(equiped_weapon);
	
	equiped_weapon = card;
	shift_weapon_stack();
	return true;

func shift_weapon_stack():
	var center_screen = get_viewport().size.x / 2;
	const offset = -110;
	#var weapon_num = len(weapon_stack) + 1;
	#for i in range(weapon_num):
		#var weapon: Card = equiped_weapon if i == 0 else weapon_stack[i - 1];
		#weapon.z_index = -1 * i + 1;
		#var pos = Vector2(center_screen - (WEAPON_CARD_SIZE + offset * i) / 2, WEAPON_STACK_Y_POSITION);
		#animate_card_to_position(weapon, pos);
	@warning_ignore("integer_division")
	var pos = Vector2(center_screen, WEAPON_STACK_Y_POSITION);
	animate_card_to_position(equiped_weapon, pos);
	
	var defeated_num = len(weapon_stack);
	for i in range(defeated_num):
		var weapon = weapon_stack[i];
		weapon.z_index = -1 * i + 1;
		@warning_ignore("integer_division")
		pos = Vector2(center_screen - (WEAPON_CARD_SIZE - offset * i) / 2 - WEAPON_CARD_SIZE / 2, WEAPON_STACK_Y_POSITION);
		animate_card_to_position(weapon, pos);

func unselect_card():
	selected_card = -1;

func get_selected_card():
	return room[selected_card] if selected_card > -1 else null;

func _on_card_left_click_released(card: Card):
	if (!card):
		return;
	
	var card_is_in_room = false;
	for i in range (len(room)):
		if (room[i] == card):
			if (room_state == ROOM_STATE.DEFEND):
				if (get_selected_card() == card):
					unselect_card();
					room_state = ROOM_STATE.NORMAL;
					set_instruction("Face " + str(3 - room.count(null)) + " out of the 4 cards");
			else:
				card_is_in_room = true;
				if (!face_btn.disabled || !skip_btn.disabled && room.count(null) == 0):
					face_btn.disabled = true;
					skip_btn.disabled = true;
				selected_card = i;
				var finished_play = play_card_effect(room[i]);
				# do -v in play_card_effect functions
				#discard_reference.add_card_to_discard_pile(room[i]);
				
				if (finished_play):
					room[i] = null;
					unselect_card();
				
					if (room.count(null) == 3):
						if (room_state != ROOM_STATE.DEFEND):
							advance_room();
					else:
						set_instruction("Face " + str(3 - room.count(null)) + " out of the 4 cards");
			break;
	
	if (!card_is_in_room):
		if (card == equiped_weapon && room_state == ROOM_STATE.DEFEND):
			var reduced_damage = max(0, get_selected_card().value - equiped_weapon.value);
			take_damage(reduced_damage);
			weapon_stack.push_back(get_selected_card());
			shift_weapon_stack();
			room[selected_card] = null;
			unselect_card();
			room_state = ROOM_STATE.NORMAL;
			if (room.count(null) == 3):
				advance_room();
			else:
				set_instruction("Face " + str(3 - room.count(null)) + " out of the 4 cards");
			# defend weapon stuff

func _on_skip_room_btn_pressed() -> void:
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
	advance_room(false);

func _on_discard_pile_clicked():
	if (room_state == ROOM_STATE.DEFEND):
		take_damage(get_selected_card().value);
		discard_reference.add_card_to_discard_pile(get_selected_card());
		room[selected_card] = null;
		unselect_card();
		room_state = ROOM_STATE.NORMAL;
		if (room.count(null) == 3):
			advance_room();
