class_name StringTableLoader
extends Node

const _STRING_TABLE_DIRECTORY = "res://resources/string_tables/"
const _ERROR_STRING_NO_TABLE = "NO TABLE"
const _ERROR_STRING_NO_TRANSLATION = "NO TRANSLATION"

var _table_dict: Dictionary[String, StringTable]

func _ready() -> void:

	# Load string tables from directory
	var resource_loader = ResourceBatchLoader.new()
	resource_loader.resource_type = ResourceBatchLoader.ResourceType.TEXT_GENERIC
	var r := resource_loader.fetch_resources_from_path(_STRING_TABLE_DIRECTORY, true)

	for res in r:
		if res is StringTable:
			var st = res as StringTable
			_table_dict[st.resource_name] = st


func get_string(string_table_id: String, string_key: String) -> String:
	if not _table_dict.keys().has(string_table_id):
		return _ERROR_STRING_NO_TABLE
	var table := _table_dict[string_table_id] as StringTable
	if not table.table.keys().has(string_key):
		return _ERROR_STRING_NO_TRANSLATION
	return table.table[string_key]
