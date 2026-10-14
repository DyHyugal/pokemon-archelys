extends RefCounted
## Recognizes a local extracted dump; does not infer game version from filenames.
static func inspect(directory: String) -> Dictionary:
	var romfs := directory.path_join("romfs")
	if not DirAccess.dir_exists_absolute(romfs): romfs = directory.path_join("RomFS")
	if directory.get_file().to_lower() == "romfs": romfs = directory
	if not DirAccess.dir_exists_absolute(romfs): return {"error": "Choisir le dossier du dump contenant romfs/, ou romfs/ lui-même"}
	var game := "USUL non identifié (en-tête absent)"
	for name in ["HeaderNCCH0.bin", "HeaderNCCH.bin"]:
		var path := directory.path_join(name)
		if not FileAccess.file_exists(path): continue
		var file := FileAccess.open(path, FileAccess.READ)
		var bytes := file.get_buffer(512)
		if bytes.size() < 512 or bytes.slice(256, 260).get_string_from_ascii() != "NCCH": continue
		var code := bytes.slice(336, 345).get_string_from_ascii()
		if code == "CTR-P-A2A": game = "Pokémon Ultra-Soleil"
		elif code == "CTR-P-A2B": game = "Pokémon Ultra-Lune"
		else: return {"error": "Jeu hors profil USUL : " + code}
	var resources: Array = []
	for entry in [["a/0/1/7", "Données personnelles Pokémon"], ["a/0/8/2", "Champs / zones (Ultra-Soleil)"], ["a/0/8/3", "Champs / zones (Ultra-Lune)"], ["a/0/4/3", "Dialogues français"], ["a/1/0/6", "Paramètres des dresseurs"], ["a/1/0/7", "Équipes des dresseurs"]]:
		var path: String = romfs.path_join(entry[0])
		if not FileAccess.file_exists(path): continue
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null: continue
		resources.append({"path": path, "label": entry[1], "bytes": file.get_length(), "garc": file.get_buffer(4) == PackedByteArray([67, 82, 65, 71])})
	return {"schema": 1, "game": game, "revision": "non déterminée", "romfs": romfs, "resources": resources}
