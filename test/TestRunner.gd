class_name TestRunner extends Node2D

# Reusable test framework that automatically discovers and runs test classes
# Test classes should extend BaseTest and be placed in the test directory

@export var test_classes: Array[Script] = []
var test_results: Array[TestResult] = []
var filter_pattern: String = ""  # Filter pattern from command line
var failed_only: bool = false  # Run only previously failed tests
var failed_tests_file: String = "user://failed_tests.txt"  # File to store failed test names

class TestResult:
    var test_name: String
    var passed: bool
    var message: String

    func _init(name: String, success: bool, msg: String = "") -> void:
        test_name = name
        passed = success
        message = msg

func parse_command_line_args() -> void:
    var args := OS.get_cmdline_user_args()  # Get user args after --
    var filter_next := false

    for arg in args:
        if filter_next:
            filter_pattern = arg
            print("Filter pattern: '%s'" % filter_pattern)
            filter_next = false
        elif arg == "filter":
            filter_next = true
        elif arg == "failed_only":
            failed_only = true
            print("Running only previously failed tests")

    if filter_next and filter_pattern == "":
        print("Warning: -- filter specified but no pattern provided")

func apply_filter_to_test_classes() -> void:
    if filter_pattern == "":
        return  # No filter, keep all tests

    print("Applying filter: '%s'" % filter_pattern)
    # Don't filter classes here anymore - we'll filter at the method level
    # This allows filtering on method names across all classes

func load_failed_tests() -> Array[String]:
    var failed_tests: Array[String] = []

    if not FileAccess.file_exists(failed_tests_file):
        return failed_tests

    var file := FileAccess.open(failed_tests_file, FileAccess.READ)
    if not file:
        push_error("Failed to open failed tests file: %s" % failed_tests_file)
        return failed_tests

    while not file.eof_reached():
        var line := file.get_line().strip_edges()
        if line != "":
            failed_tests.append(line)

    file.close()
    return failed_tests

func save_failed_tests() -> void:
    var failed_test_names: Array[String] = []

    for result in test_results:
        if not result.passed:
            failed_test_names.append(result.test_name)

    var file := FileAccess.open(failed_tests_file, FileAccess.WRITE)
    if not file:
        push_error("Failed to open failed tests file for writing: %s" % failed_tests_file)
        return

    for test_name in failed_test_names:
        file.store_line(test_name)

    file.close()

    if failed_test_names.size() > 0:
        print("Saved %d failed test(s) to: %s" % [failed_test_names.size(), failed_tests_file])

func _ready() -> void:
    print("=== Test Runner Started ===")

    # Parse command line arguments for filter
    parse_command_line_args()

    # Use call_deferred to ensure we're in the main thread properly
    call_deferred("run_tests_deferred")

func run_tests_deferred() -> void:
    print("Discovering tests...")
    discover_tests()
    print("Tests to run: ", test_classes.size())

    print("Running tests...")
    run_all_tests()
    print("Tests completed.")

    print_results()
    save_failed_tests()
    print("=== Test Runner Finished ===")

    # Force exit after a short delay
    await get_tree().create_timer(0.1).timeout
    get_tree().quit(0)

func discover_tests() -> void:
    print("Discovering test classes...")

    # Option 1: Use the exported array if it's populated
    if test_classes.size() > 0:
        print("Using exported test classes: %d found" % test_classes.size())
        apply_filter_to_test_classes()
        return

    # Option 2: Auto-discover test files in the test directory
    var test_files := get_test_files_in_directory("res://test/")
    print("Auto-discovered test files: %d found" % test_files.size())

    for file_path in test_files:
        var script := load(file_path) as GDScript
        if script:
            test_classes.append(script)

    apply_filter_to_test_classes()

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

    # Apply failed_only filter first if enabled
    if failed_only:
        var failed_test_names := load_failed_tests()
        var filtered_methods: Array[String] = []

        for method_name in test_methods:
            var method_name_clean := method_name.replace("test_", "")
            var full_test_name := "%s::%s" % [category, method_name_clean]

            if full_test_name in failed_test_names:
                filtered_methods.append(method_name)

        test_methods = filtered_methods

    # Apply method-level filtering if pattern is set
    if filter_pattern != "":
        var filtered_methods: Array[String] = []
        var test_class_name := test_script.resource_path.get_file().get_basename()

        for method_name in test_methods:
            # Check if the filter matches:
            # 1. The test class name
            # 2. The method name (with or without "test_" prefix)
            # 3. The full test name format "ClassName::method_name"
            var method_name_clean := method_name.replace("test_", "")
            var full_test_name := "%s::%s" % [category, method_name_clean]

            if (test_class_name.to_lower().contains(filter_pattern.to_lower()) or
                method_name.to_lower().contains(filter_pattern.to_lower()) or
                method_name_clean.to_lower().contains(filter_pattern.to_lower()) or
                full_test_name.to_lower().contains(filter_pattern.to_lower()) or
                category.to_lower().contains(filter_pattern.to_lower())):
                filtered_methods.append(method_name)

        test_methods = filtered_methods

    if test_methods.size() == 0:
        return  # No matching methods to run

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
