extends SceneTree
const Campaign=preload("res://scripts/domain/campaign.gd")
const Battle=preload("res://scripts/domain/battle.gd")
const Store=preload("res://scripts/services/save_store.gd")
const World=preload("res://scripts/domain/world_rules.gd")
var checks:int=0
var failures:int=0
func check(condition:bool,label:String)->void:
	checks+=1
	if not condition:
		failures+=1;push_error(label)
func _initialize()->void:
	var c:=Campaign.new();c.configure(3)
	c.add_player(1,"A");c.add_player(2,"B")
	for p:Dictionary in c.players.values():p.position=[0.0,0.0,-8.0]
	check(not c.advance(),"Story gate must wait for absent third player")
	c.add_player(3,"C")
	check(not c.advance(),"Present but distant participant cannot advance story")
	c.players[3].position=[0.0,0.0,-8.0]
	check(c.advance() and c.progress==1 and c.level_cap==12,"All present at gate advances and raises cap")
	check(not c.add_player(4,"D"),"Campaign size rejects extra participant")
	var saved:=c.snapshot();saved.level_cap=1
	check(not c.restore(saved) and c.level_cap==12,"Invalid cap restore leaves campaign unchanged")
	var path:="user://tests_campaign.json"
	DirAccess.remove_absolute(path);DirAccess.remove_absolute(path+".backup")
	check(Store.write_snapshot(path,c.snapshot())==OK,"Valid campaign is written")
	c.advance()
	check(Store.write_snapshot(path,c.snapshot())==OK,"Second write succeeds")
	check(int(Store.read_snapshot(path+".backup").progress)==1,"Backup preserves previous version")
	check(int(Store.read_snapshot(path).progress)==2,"Live save contains new version")
	var damaged:=FileAccess.open(path,FileAccess.WRITE);damaged.store_string("{damaged");damaged.close()
	check(Store.read_snapshot(path).is_empty(),"Corrupt save rejected")
	check(Store.write_snapshot(path,c.snapshot())==OK and int(Store.read_snapshot(path+".backup").progress)==1,"Repair does not overwrite last valid backup with corrupt file")
	var invalid:=c.snapshot();invalid.players[1].position=[INF,0.0,0.0]
	check(not Campaign.validate(invalid),"Non-finite network positions rejected")
	invalid=c.snapshot();invalid.players["invalid"] = invalid.players[1];invalid.players.erase(1)
	check(not Campaign.validate(invalid),"Invalid player identities rejected")
	check(not World.walkable(Vector2(-8,0)),"Building blocks authoritative movement")
	check(World.walkable(Vector2.ZERO),"Path remains walkable")
	var b:=Battle.new()
	b.begin({"slow":{"side":0,"hp":40,"speed":10,"power":30,"priority":1},
		"fast":{"side":1,"hp":20,"speed":90,"power":40}},true)
	var log:=b.resolve([{"actor":"fast","target":"slow"},{"actor":"slow","target":"fast"}])
	check(log.size()==1 and b.units.slow.hp==40 and b.units.fast.hp==0,"Priority precedes speed; KO cancels victim action")
	b.abandon();check(b.units.fast.hp==20 and b.turn_index==0,"Abandon restores complete precombat state")
	b.begin({"a":{"side":0,"hp":30,"speed":10},"b":{"side":0,"hp":30,"speed":20}},true)
	check(b.resolve([{"actor":"a","target":"b"}]).is_empty() and b.units.b.hp==30,"Raid blocks friendly damage")
	b.begin({"a":{"side":0,"hp":30,"speed":10,"power":5},"b":{"side":1,"hp":30,"speed":20}},true)
	b.resolve([{"actor":"a","target":"b"},{"actor":"a","target":"b"}])
	check(b.units.b.hp==25,"Duplicate command cannot grant extra action")
	print("ARCHÉLYS TESTS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
