class_name ItemInstance extends RefCounted

var item: Item
var item_data: ItemData

func _init(_item: Item, _item_data: ItemData) -> void:
    self.item = _item
    self.item_data = _item_data