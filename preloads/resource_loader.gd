extends RefCounted
class_name GGResourceFinder


## Iterates over files in a directory
## making it easy to load contents from disk at run-time.
##
## This finder helps find resources that are remapped for Android
## and Web exports

#func _load_content_scenes():
	#if content_directory.is_empty(): return
	#var files = GGResourceFinder.find(content_directory, ".tscn")
	#for filename in files:
		#var scene = ResourceLoader.load(filename)
		#if scene is PackedScene:
			#content_scenes.append(scene)

static func find(directory: String, suffix: String) -> Array[String]:
	var files: Array[String] = _dir_contents(directory, suffix)
	files.sort()
	return files

static func find_file(path:String):
	if not FileAccess.file_exists(path) and not FileAccess.file_exists(path+'.remap'):
		print("No such file: ",path)
		return
	path = path.replace('.remap', '') 
	var file = ResourceLoader.load(path)
	return file

## Recursively find files from a directory
static func _dir_contents(path, suffix) -> Array[String]:
	var dir = DirAccess.open(path)
	if !dir:
		print("GGResourceFinder: An error occurred when trying to access path: %s" % [path])
		return []

	var files: Array[String]
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		file_name = file_name.replace('.remap', '') 
		if dir.current_is_dir():
			files.append_array(_dir_contents("%s/%s" % [path, file_name], suffix))
		elif file_name.ends_with(suffix):
			files.append("%s/%s" % [path, file_name])
		file_name = dir.get_next()
		
	return files
