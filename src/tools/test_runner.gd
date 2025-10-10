extends Node

# Simple test runner to verify our priority selection
func _ready():
    TestPrioritySelection.test_priority_selection()
    get_tree().quit()
