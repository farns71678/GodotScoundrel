extends Node2D

var page_count: int;
var current_page = 0;

signal exit_btn_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	page_count = len($Pages.get_children());
	reset();

func reset():
	current_page = 0;
	shift_page();

func shift_page():
	for i in range (page_count):
		var page = $Pages.get_child(i);
		page.visible = false;
	
	set_page_label();
	
	$BackBtn.disabled = current_page == 0
	$NextBtn.disabled = current_page == page_count - 1;
	
	$Pages.get_child(current_page).visible = true;

func set_page_label():
	$PageLabel.text = str(current_page + 1) + " of " + str(page_count);

func _on_exit_btn_pressed() -> void:
	emit_signal("exit_btn_pressed");

func _on_back_btn_pressed() -> void:
	if (current_page > 0):
		current_page -= 1;
	shift_page();


func _on_next_btn_pressed() -> void:
	if (current_page < page_count - 1):
		current_page += 1;
	shift_page();
