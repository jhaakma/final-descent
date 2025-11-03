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
func assert_true(condition: bool, message: String = "") -> bool:
    if not condition:
        if message.is_empty():
            print("ASSERTION FAILED: Expected true, got false")
        else:
            print("ASSERTION FAILED: " + message)
    return condition

func assert_false(condition: bool, message: String = "") -> bool:
    var result: bool = not condition
    if not result:
        if message.is_empty():
            print("ASSERTION FAILED: Expected false, got true")
        else:
            print("ASSERTION FAILED: " + message)
    return result

func assert_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
    var result: bool = actual == expected
    if not result:
        if message.is_empty():
            print("ASSERTION FAILED: Expected '" + str(expected) + "', got '" + str(actual) + "'")
        else:
            print("ASSERTION FAILED: " + message + " (Expected: " + str(expected) + ", Got: " + str(actual) + ")")
    return result

func assert_not_null(value: Variant, message: String = "") -> bool:
    var result: bool = value != null
    if not result:
        if message.is_empty():
            print("ASSERTION FAILED: Expected non-null value, got null")
        else:
            print("ASSERTION FAILED: " + message)
    return result

func assert_null(value: Variant, message: String = "") -> bool:
    var result: bool = value == null
    if not result:
        if message.is_empty():
            print("ASSERTION FAILED: Expected null, got '" + str(value) + "'")
        else:
            print("ASSERTION FAILED: " + message + " (Got: " + str(value) + ")")
    return result

func assert_resource_loads(path: String, message: String = "") -> bool:
    var resource: Resource = load(path)
    var result: bool = resource != null
    if not result:
        if message.is_empty():
            print("ASSERTION FAILED: Resource failed to load from path: " + path)
        else:
            print("ASSERTION FAILED: " + message + " (Path: " + path + ")")
    return result

func assert_has_method(object: Object, method_name: String, message: String = "") -> bool:
    var result: bool = object != null and object.has_method(method_name)
    if not result:
        if message.is_empty():
            if object == null:
                print("ASSERTION FAILED: Object is null, cannot check for method '" + method_name + "'")
            else:
                print("ASSERTION FAILED: Object does not have method '" + method_name + "'")
        else:
            print("ASSERTION FAILED: " + message)
    return result

func assert_string_contains(text: String, substring: String, message: String = "") -> bool:
    var result: bool = text.contains(substring)
    if not result:
        if message.is_empty():
            print("ASSERTION FAILED: String '" + text + "' does not contain '" + substring + "'")
        else:
            print("ASSERTION FAILED: " + message + " (Text: '" + text + "', Substring: '" + substring + "')")
    return result