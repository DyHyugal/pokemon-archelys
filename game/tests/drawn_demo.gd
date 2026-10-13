extends SceneTree
const Layouts=preload("res://scripts/world/drawn_layouts.gd")
var checks:=0
var failures:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:run.call_deferred()
func finish_text(game: Node) -> void:
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 while game.scene.active:game.advance_scene()
func shot(id: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 for i: int in range(4):await process_frame
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Actual drawn-demo screenshot: "+id)
func wait_battle(game: Node) -> void:
 var deadline: int=Time.get_ticks_msec()+12000
 while game.battle.busy and Time.get_ticks_msec()<deadline:await create_timer(.01).timeout
 check(not game.battle.busy and game.battle.last_error.is_empty(),"Real offline Showdown response")
func reachability(game: Node) -> void:
 # Flood-fill actual collision checks. A visible door/service with no reachable
 # approach is a regression even when scripted travel itself works.
 var spawn: Vector3=Layouts.spawn(game.state.location)
 var seed:=Vector2i(roundi(spawn.x*4),roundi(spawn.z*4))
 var visited: Dictionary={seed:true};var queue: Array[Vector2i]=[seed];var head:=0
 while head<queue.size():
  var here: Vector2i=queue[head];head+=1
  for offset: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   var next: Vector2i=here+offset
   if visited.has(next) or abs(next.x)>56 or abs(next.y)>40:continue
   if game.world.can_walk(Vector3(next.x/4.0,0,next.y/4.0)):visited[next]=true;queue.append(next)
 for id: String in game.world.points:
  var point: Vector3=game.world.points[id]
  var reachable: bool=queue.any(func(p: Vector2i):return Vector3(p.x/4.0,0,p.y/4.0).distance_to(point)<1.7)
  check(reachable,"Reachable approach: "+game.state.location+"/"+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--drawn-proof="):folder=arg.trim_prefix("--drawn-proof=")
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://drawn_test_locale.json";owner.comfort=preload("res://scripts/services/comfort_store.gd").new("user://drawn_test_comfort.json");root.add_child(owner)
 await process_frame;await process_frame
 if not folder.is_empty():owner.comfort.set_option("resolution","1920x1080");owner._apply_comfort()
 var original: Dictionary=root.get_node("Session").campaign.snapshot()
 var game: Node=owner.demo_game;game.enable_drawn()
 check(game.save_path=="user://archelys_drawn_demo.json","Separate save namespace before test override")
 game.save_path="user://drawn_tests_demo.json"
 check(game.open(owner),"Drawn demo opens")
 game.new_demo();check(game.choose_starter("charmander"),"Real provisional starter selection");finish_text(game)
 await process_frame;await process_frame
 check(game.world.drawn and game.world.geometry.get_child_count()==0,"Drawn exploration has no live 3D scenery")
 check(game.hd2d_view.hero.texture.resource_path.begins_with(Layouts.ROOT),"Independent drawn hero texture")
 reachability(game);await shot("01-havre")
 var before: Vector3=game.state.position
 for i: int in range(5):game.world.move_hero(Vector2.DOWN,.04,game.state,true)
 await process_frame;await process_frame
 check(game.state.position.z>before.z and game.hd2d_view.hero.position.is_equal_approx(game.hd2d_view.project(game.state.position)),"Real movement drives separate 2D hero")
 check(not game.world.can_walk(Vector3(-4,0,-5)) and not game.world.can_walk(Vector3(0,0,10)),"Town building and waterfront block movement")
 for interior: String in ["home","center","shop"]:
  game.state.position=game.world.points['door-'+interior];game.world.hero.position=game.state.position
  check(game.world.nearest()=="door-"+interior,"Real nearest door: "+interior)
  game.interact();await process_frame
  check(game.state.location==interior and game.world.can_walk(game.state.position),"Actual door and safe spawn: "+interior)
  reachability(game);await shot("02-"+interior)
  if interior=="center":
   var mon: Dictionary=game.state.campaign.adventure.team[0];mon.hp=1;mon.moves[0].pp=0
   game.interact("nurse");finish_text(game)
   check(mon.hp>1 and mon.moves[0].pp>0,"Real clinic restores HP and PP")
   game.interact("pc");check(game.menu.visible,"Real PC opens");game.menu.close()
  elif interior=="shop":game.interact("merchant");check(game.menu.visible,"Real shop services open");game.menu.close()
  game.state.position=game.world.points.exit;game.world.hero.position=game.state.position;game.interact("exit");await process_frame
  check(game.state.location=="town" and game.state.position.distance_to(Layouts.vector(Layouts.layout("town").points['door-'+interior]))<.5,"Return to corresponding painted door: "+interior)
 game.open_menu("map");check(game.menu.visible,"Drawn local map opens");game.menu.close()
 game.open_menu("bag");await shot("03-sac");game.menu.close()
 game.save_game();var saved: Dictionary=game.state.snapshot();game.state.position=Vector3.ZERO;game.load_game()
 check(game.state.snapshot()==saved,"Save/load preserves drawn position, party and flags")
 game.state.position=game.world.points.gate;game.world.hero.position=game.state.position;game.interact("gate");await process_frame
 check(game.state.location=="trail","Actual town-to-route transition")
 reachability(game);await shot("04-sentier")
 game.interact("survey");finish_text(game);game.interact("cut");finish_text(game);await process_frame;await process_frame
 check(not game.world.points.has("cut") and game.world.can_walk(Vector3(-3,0,1.5)) and game.hd2d_view.stage.get_node_or_null("Obstacle_cut")==null,"Story field action removes both collider and visible marker")
 check(Layouts.in_grass("trail",Vector3(4,0,-1)) and not Layouts.in_grass("trail",Vector3(0,0,-1)),"Wild encounters match painted grass area")
 game.interact("go-canopy");check(game.state.location=="trail" and game.modal!=null,"Unpainted chapter has explicit slice boundary");finish_text(game)
 # Magikarp cannot paralyse or otherwise deny this first action. Pikachu's
 # Thunder Shock can legitimately prevent a turn, making a PP-spend assertion
 # invalid; test the command cost with an unimpeded opportunity to act.
 check(game.begin_battle([preload("res://scripts/domain/pokemon.gd").make("magikarp",5,900)]),"Real Showdown battle begins")
 await wait_battle(game)
 while game.battle_panel.event_index<game.battle.events.size():game.battle_panel.advance()
 await process_frame;await process_frame
 check(game.drawn_battle_view.visible and game.drawn_battle_view.enemy.texture!=null,"Drawn portraits follow real combat")
 var pp: int=game.state.campaign.adventure.team[0].moves[0].pp
 check(game.battle.execute({"kind":"move","slot":0}),"Real attack accepted");await wait_battle(game)
 check(game.state.campaign.adventure.team[0].moves[0].pp==pp-1,"Real attack consumes exactly one PP")
 while game.battle_panel.event_index<game.battle.events.size():game.battle_panel.advance()
 await shot("05-combat")
 check(game.battle.execute({"kind":"run"}),"Wild battle flee accepted")
 for i: int in range(20):
  if not game.battle_panel.visible:break
  game.battle_panel.advance();await process_frame
 await process_frame;await process_frame
 check(not game.drawn_battle_view.visible and game.hd2d_view.visible,"Combat returns to painted route")
 game.travel("town");finish_text(game);game.close();await process_frame
 check(root.get_node("Session").campaign.snapshot()==original,"Workshop campaign preserved")
 check(game.hd2d_view==null and game.drawn_battle_view==null,"Both 2D views cleaned up")
 print("DRAWN DEMO: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
