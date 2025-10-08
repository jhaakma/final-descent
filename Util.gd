extends Node

func instantiate(path: String) -> Object:
    var packed_scene: PackedScene = load(path)
    return packed_scene.instantiate()