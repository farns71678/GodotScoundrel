extends Camera2D

@export var decay = 0.6;
@export var max_offset = Vector2(50, 35);
@export var max_roll = 0.1;

var trauma = 0.0;
var trauma_power = 1;

@onready var noise = FastNoiseLite.new();
var noise_y  = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize();
	noise.seed = randi();
	#noise.period = 4;
	noise.fractal_octaves = 2;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (trauma):
		trauma = max(trauma - decay * delta, 0);
		shake();

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0);

func shake():
	var amount = pow(trauma, trauma_power);
	rotation = max_roll * amount * randf_range(-1, 1);
	offset.x = max_offset.x * amount * randf_range(-1, 1);
	offset.y = max_offset.y * amount * randf_range(-1, 1);
	#noise_y += 1
	#rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	#offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	#offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)
