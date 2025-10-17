class_name TestRunner extends Node2D

# Reusable test framework that automatically discovers and runs test classes
# Test classes should extend BaseTest and be placed in the test directory

@export var test_classes: Array[Script] = []
var test_results: Array[TestResult] = []

class TestResult:
    var test_name: String
    var passed: bool
    var message: String

    func _init(name: String, success: bool, msg: String = "") -> void:
        test_name = name
        passed = success
        message = msg

func _ready() -> void:
    print("=== Test Runner Started ===")
    discover_tests()
    run_all_tests()
    print_results()
    get_tree().quit()

func discover_tests() -> void:
    print("Discovering test classes...")

    # Option 1: Use the exported array if it's populated
    if test_classes.size() > 0:
        print("Using exported test classes: %d found" % test_classes.size())
        return

    # Option 2: Auto-discover test files in the test directory
    var test_files := get_test_files_in_directory("res://test/")
    print("Auto-discovered test files: %d found" % test_files.size())

    for file_path in test_files:
        var script := load(file_path) as GDScript
        if script:
            test_classes.append(script)

func get_test_files_in_directory(directory_path: String) -> Array[String]:
    var test_files: Array[String] = []
    var dir := DirAccess.open(directory_path)

    if not dir:
        print("Warning: Could not access test directory: %s" % directory_path)
        return test_files

    dir.list_dir_begin()
    var file_name := dir.get_next()

    while file_name != "":
        if file_name.ends_with("Test.gd") and file_name != "BaseTest.gd":
            test_files.append(directory_path + file_name)
        file_name = dir.get_next()

    return test_files

func is_test_class(script: Script) -> bool:
    # Check if the script extends BaseTest
    var base_script := script.get_base_script()
    while base_script:
        if base_script.has_method("get_test_methods"):
            return true
        base_script = base_script.get_base_script()
    return false

func run_all_tests() -> void:
    if test_classes.size() == 0:
        print("No test classes found!")
        return

    print("Running %d test classes..." % test_classes.size())

    for test_script in test_classes:
        run_test_class(test_script)

func run_test_class(test_script: Script) -> void:
    # Create instance - suppress unsafe access warning
    @warning_ignore("unsafe_method_access")
    var test_instance: BaseTest = test_script.new()
    var category := test_instance.get_test_category()
    var test_methods := test_instance.get_test_methods()

    print("\n--- Testing %s (%d tests) ---" % [category, test_methods.size()])

    for method_name in test_methods:
        run_single_test(test_instance, method_name, category)

func run_single_test(test_instance: BaseTest, method_name: String, category: String) -> void:
    var test_name := "%s::%s" % [category, method_name.replace("test_", "")]
    print("  Running: %s" % test_name)

    var success := test_instance.run_test(method_name)
    var error_message := "" if success else "Test assertion failed"

    if success:
        print("    ✓ PASSED")
    else:
        print("    ✗ FAILED: %s" % error_message)

    var result := TestResult.new(test_name, success, error_message)
    test_results.append(result)

func print_results() -> void:
    print("\n=== Test Results ===")

    var passed_count := 0
    var failed_count := 0

    for result in test_results:
        if result.passed:
            passed_count += 1
            print("✓ %s" % result.test_name)
        else:
            failed_count += 1
            print("✗ %s - %s" % [result.test_name, result.message])

    print("\n--- Summary ---")
    print("Total tests: %d" % test_results.size())
    print("Passed: %d" % passed_count)
    print("Failed: %d" % failed_count)

    if failed_count == 0:
        print("🎉 All tests passed!")
    else:
        print("❌ %d test(s) failed" % failed_count)