extends RefCounted
## Read-only GARC v6 (7G) reader. Independently implemented from the binary layout.
## Extraction preserves bytes; this is not a GFModel/AMX converter or a ROM decryptor.
const MAX_METADATA = 16 * 1024 * 1024
const MAX_MEMBER = 256 * 1024 * 1024

static func inspect(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": "Archive illisible"}
	var length := file.get_length()
	var head := file.get_buffer(36)
	if head.size() != 36 or head.slice(0, 4).get_string_from_ascii() != "CRAG": return {"error": "GARC absent : fournir une archive extraite, pas une ROM chiffrée"}
	if head.decode_u32(4) != 36 or head.decode_u16(8) != 0xfeff or head.decode_u16(10) != 0x600 or head.decode_u32(12) != 4: return {"error": "Profil GARC non pris en charge (v6 little-endian requis)"}
	var start := head.decode_u32(16)
	if start < 72 or start > MAX_METADATA or start > length or head.decode_u32(20) != length: return {"error": "Taille GARC incohérente"}
	file.seek(0)
	var table := file.get_buffer(start)
	if table.size() != start: return {"error": "Métadonnées tronquées"}
	if table.slice(36, 40).get_string_from_ascii() != "OTAF": return {"error": "Table FATO absente"}
	var count := table.decode_u16(44)
	var fato_size := table.decode_u32(40)
	if fato_size != 12 + count * 4: return {"error": "FATO invalide"}
	var fatb := 36 + fato_size
	if fatb + 12 > start or table.slice(fatb, fatb + 4).get_string_from_ascii() != "BTAF": return {"error": "FATB absente"}
	var fimb := fatb + table.decode_u32(fatb + 4)
	if fimb < fatb + 12 or fimb + 12 != start or table.slice(fimb, fimb + 4).get_string_from_ascii() != "BMIF": return {"error": "FIMB invalide"}
	if table.decode_u32(fimb + 4) != 12 or table.decode_u32(fimb + 8) != length - start: return {"error": "Bloc de données invalide"}
	var rows: Array = []
	var ranges: Array = []
	for member in count:
		var offset := fatb + 12 + table.decode_u32(48 + member * 4)
		if offset < fatb + 12 or offset + 4 > fimb: return {"error": "Entrée FATB hors limites"}
		var mask := table.decode_u32(offset); offset += 4
		if mask == 0: return {"error": "Masque de sous-fichiers vide"}
		for sub in 32:
			if mask & (1 << sub) == 0: continue
			if offset + 12 > fimb: return {"error": "Sous-fichier tronqué"}
			var begin := table.decode_u32(offset)
			var end := table.decode_u32(offset + 4)
			var size := table.decode_u32(offset + 8); offset += 12
			if end < begin or size > end - begin or end > length - start: return {"error": "Membre GARC hors limites"}
			if end > begin: ranges.append([begin, end])
			file.seek(start + begin)
			var signature := file.get_buffer(mini(size, 8))
			rows.append({"member": member, "sub": sub, "offset": start + begin, "bytes": size, "kind": classify(signature)})
	ranges.sort_custom(func(a, b): return a[0] < b[0] or a[0] == b[0] and a[1] < b[1])
	for i in range(1, ranges.size()):
		if ranges[i] != ranges[i - 1] and ranges[i][0] < ranges[i - 1][1]: return {"error": "Membres qui se chevauchent"}
	if rows.size() != table.decode_u32(fatb + 8): return {"error": "Nombre de sous-fichiers incohérent"}
	var digest := HashingContext.new(); digest.start(HashingContext.HASH_SHA256); digest.update(table)
	return {"schema": 1, "profile": "usul-garc-v6", "path": path, "bytes": length, "members": count, "rows": rows, "metadata_sha256": digest.finish().hex_encode()}

static func classify(bytes: PackedByteArray) -> String:
	if bytes.is_empty(): return "empty"
	if bytes[0] in [0x10, 0x11]: return "LZ-compressed (conversion requise)"
	if bytes.size() >= 6 and bytes.decode_u16(4) == 0xf1e0: return "AMX (non exécuté)"
	var magic := ""
	for byte in bytes.slice(0, mini(4, bytes.size())):
		magic += char(byte) if byte >= 32 and byte <= 126 else "?"
	if bytes.size() >= 4 and bytes.slice(0, 3) == PackedByteArray([66, 67, 72]) and bytes[3] == 0: return "BCH (conversion requise)"
	if magic.begins_with("glTF"): return "GLB"
	return "binary (non converti)"

static func extract(path: String, member: int, sub: int, directory: String) -> Dictionary:
	# Reparse every time: stale inspector offsets never authorize an unchecked read.
	var report := inspect(path)
	if report.has("error"): return report
	for row: Dictionary in report.rows:
		if row.member != member or row.sub != sub: continue
		if row.bytes > MAX_MEMBER: return {"error": "Membre trop volumineux (256 Mio maximum)"}
		if DirAccess.make_dir_recursive_absolute(directory) != OK: return {"error": "Dossier de sortie inaccessible"}
		var target := directory.path_join("%05d-%02d.bin" % [member, sub])
		if FileAccess.file_exists(target): return {"error": "Fichier existant préservé : " + target}
		var file := FileAccess.open(path, FileAccess.READ); file.seek(row.offset)
		var payload := file.get_buffer(row.bytes)
		if payload.size() != row.bytes: return {"error": "Source modifiée ou tronquée"}
		var output := FileAccess.open(target, FileAccess.WRITE)
		if output == null: return {"error": "Écriture impossible"}
		output.store_buffer(payload); output.close()
		var digest := HashingContext.new(); digest.start(HashingContext.HASH_SHA256); digest.update(payload)
		var manifest := {"schema": 1, "source_archive_sha256": FileAccess.get_sha256(path), "member": member, "sub": sub, "bytes": payload.size(), "sha256": digest.finish().hex_encode(), "conversion": "raw-only", "redistribution": "not-authorized-by-tool"}
		var metadata := FileAccess.open(target + ".json", FileAccess.WRITE)
		if metadata == null:
			DirAccess.remove_absolute(target)
			return {"error": "Manifest impossible : extraction annulée"}
		metadata.store_string(JSON.stringify(manifest, "\t"))
		return {"path": target, "manifest": manifest}
	return {"error": "Membre introuvable"}
