class_name BaseTest extends RefCounted

# Base class for all test classes
# Test classes should extend this and implement test methods that start with "test_"

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
    if has_method(method_name):
        var result: Variant = call(method_name)
        return result if result is bool else false
    return false

# Helper assertion methods for tests
func assert_true(condition: bool, _message: String = "") -> bool:
    return condition

func assert_false(condition: bool, _message: String = "") -> bool:
    return not condition

func assert_equals(actual: Variant, expected: Variant, _message: String = "") -> bool:
    return actual == expected

func assert_not_null(value: Variant, _message: String = "") -> bool:
    return value != null

func assert_null(value: Variant, _message: String = "") -> bool:
    return value == null

func assert_resource_loads(path: String, _message: String = "") -> bool:
    var resource: Resource = load(path)
    return resource != null

func assert_has_method(object: Object, method_name: String, _message: String = "") -> bool:
    return object != null and object.has_method(method_name)

func assert_string_contains(text: String, substring: String, _message: String = "") -> bool:
    return text.contains(substring)