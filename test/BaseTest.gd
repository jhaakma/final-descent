class_name BaseTest extends RefCounted

# Base class for all test classes
# Test classes should extend this and implement test methods that start with "test_"

# Track if the current test has failed
var _test_failed: bool = false
var _failure_message: String = ""

# Virtual method that test classes can override to provide a test name
func get_test_category() -> String:
    var script: Script = get_script()
    if script and script.has_method("get_global_name"):
        return script.get_global_name().replace("Test", "")
    return "Unknown"

# Get all test methods from this test class
func get_test_methods() -> Array[String]:
    var methods: Array[String] = []
    var script: Script = get_script()

    if not script:
        return methods

    # Get all methods from the script
    for method: Dictionary in script.get_script_method_list():
        var method_name: String = method.get("name", "")
        if method_name.begins_with("test_") and method_name != "test_":
            methods.append(method_name)

    return methods

# Run a specific test method
func run_test(method_name: String) -> bool:
    # Reset failure state before each test
    _test_failed = false
    _failure_message = ""

    if has_method(method_name):
        # Test methods must return true on success
        var result: Variant = call(method_name)

        # If test method didn't return true, it failed
        if result != true:
            # Only set failure message if not already set by an assertion
            # (assertions set both _test_failed and _failure_message)
            if not _test_failed:
                _test_failed = true
                # GDScript returns false on runtime errors, null on missing return
                # Don't add extra message - test should print its own error context

        # Test fails if any assertion failed during execution OR method didn't return true
        return not _test_failed
    return false

# Get the failure message for the last test run
func get_failure_message() -> String:
    return _failure_message

# Helper assertion methods for tests
func assert_true(condition: bool, message: String = "") -> bool:
    if not condition:
        _test_failed = true
        if message.is_empty():
            _failure_message = "Expected true, got false"
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message
            print("ASSERTION FAILED: " + message)
    return condition

func assert_false(condition: bool, message: String = "") -> bool:
    var result: bool = not condition
    if not result:
        _test_failed = true
        if message.is_empty():
            _failure_message = "Expected false, got true"
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message
            print("ASSERTION FAILED: " + message)
    return result

func assert_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
    var result: bool = actual == expected
    if not result:
        _test_failed = true
        if message.is_empty():
            _failure_message = "Expected '" + str(expected) + "', got '" + str(actual) + "'"
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message + " (Expected: " + str(expected) + ", Got: " + str(actual) + ")"
            print("ASSERTION FAILED: " + _failure_message)
    return result

func assert_not_null(value: Variant, message: String = "") -> bool:
    var result: bool = value != null
    if not result:
        _test_failed = true
        if message.is_empty():
            _failure_message = "Expected non-null value, got null"
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message
            print("ASSERTION FAILED: " + message)
    return result

func assert_null(value: Variant, message: String = "") -> bool:
    var result: bool = value == null
    if not result:
        _test_failed = true
        if message.is_empty():
            _failure_message = "Expected null, got '" + str(value) + "'"
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message + " (Got: " + str(value) + ")"
            print("ASSERTION FAILED: " + _failure_message)
    return result

func assert_resource_loads(path: String, message: String = "") -> bool:
    var resource: Resource = load(path)
    var result: bool = resource != null
    if not result:
        _test_failed = true
        if message.is_empty():
            _failure_message = "Resource failed to load from path: " + path
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message + " (Path: " + path + ")"
            print("ASSERTION FAILED: " + _failure_message)
    return result

func assert_has_method(object: Object, method_name: String, message: String = "") -> bool:
    var result: bool = object != null and object.has_method(method_name)
    if not result:
        _test_failed = true
        if message.is_empty():
            if object == null:
                _failure_message = "Object is null, cannot check for method '" + method_name + "'"
            else:
                _failure_message = "Object does not have method '" + method_name + "'"
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message
            print("ASSERTION FAILED: " + message)
    return result

func assert_string_contains(text: String, substring: String, message: String = "") -> bool:
    var result: bool = text.contains(substring)
    if not result:
        _test_failed = true
        if message.is_empty():
            _failure_message = "String '" + text + "' does not contain '" + substring + "'"
            print("ASSERTION FAILED: " + _failure_message)
        else:
            _failure_message = message + " (Text: '" + text + "', Substring: '" + substring + "')"
            print("ASSERTION FAILED: " + _failure_message)
    return result