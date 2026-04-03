extends Resource

enum StorageVersion {
	Version_Alpha = 0
}

#@export var decal_registry: Array = []
@export var decal_settings: Dictionary = {}
@export var plugin_settings: Dictionary = {}
@export var version: StorageVersion = StorageVersion.Version_Alpha
