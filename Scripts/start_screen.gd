extends Node2D


var rules_screen;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rules_screen = $".".get_node("Rules");
	rules_screen.get_node("ExitBtn").connect("pressed", _on_rules_exit_btn_pressed);
	



func _on_start_game_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn");


func _on_rules_btn_pressed() -> void:
	rules_screen.visible = true;
	

func _on_rules_exit_btn_pressed() -> void:
	rules_screen.visible = false;
