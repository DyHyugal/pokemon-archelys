'use strict';
const assert=require('node:assert/strict');
const path=require('node:path');
const root=path.resolve(__dirname,'../../builds/showdown');
const {Adapter}=require(path.join(root,'bridge.cjs'));
const {Dex}=require(path.join(root,'upstream/dist/sim'));
const {choose}=require(path.join(root,'policy.cjs'));
const catalog=require(path.join(root,'catalog.json'));
let checks=0;
function check(value,label){assert(value,label);checks++;}
function mon(species,uid,moves,extra={}){
 const record=catalog.species[species];const level=50;
 return {uid,species,level,iv:[15,15,15,15,15,15],ev:[0,0,0,0,0,0],nature:'hardy',ability:record.ability,item:'',status:'',status_turns:0,
 hp:Math.floor((2*record.stats[0]+15)*level/100)+level+10,moves:moves.map(id=>({id,pp:catalog.moves[id].pp})),...extra};
}
function start(player,enemy,mode='singles',extra={}){const a=new Adapter();const s=a.start({player,enemy,mode,seed:[1,2,3,4],...extra});return {a,s};}
{
 const {a,s}=start([mon('blastoise',1,['surf'],{item:'lucky-egg'})],[mon('magikarp',9,['splash'])]);
 check(s.player[0].item==='lucky-egg','Lucky Egg imports as a real held item');
 const next=a.act({choice:'move 1'});check(next.player[0].item==='lucky-egg','Lucky Egg remains held across turns');
 check(a.b.p1.pokemon[0].getItem().exists,'Upstream item mechanics see Lucky Egg');
 check(a.b.p1.pokemon[0].takeItem().id==='luckyegg' && a.state().player[0].item==='', 'Lucky Egg is removable by upstream item mechanics and removal exports');a.close();
}

{
 const p=mon('blastoise',1,['surf','protect'],{hp:70,status:'poison',moves:[{id:'surf',pp:3},{id:'protect',pp:10}]});
 const {a,s}=start([p],[mon('raticate',9,['tackle'])]);
 check(s.player[0].hp===70&&s.player[0].status==='poison','Initial condition preserved');
 check(s.player[0].pp[0].pp===3&&s.request.active[0].moves[0].maxpp===15,'Actual depleted PP and no PP Ups');
 const t=a.act({choice:'move 1'});check(t.turn===1&&t.player[0].pp[0].pp===2,'Real turn decrements existing PP once');
 check(t.player[0].hp<70,'Poison and enemy action resolved by Showdown');
 assert.throws(()=>a.act({choice:'move 99'}));checks++;check(a.b.turn===2,'Invalid choice does not advance turn');
 a.close();
}
{
 const {a,s}=start([mon('blastoise',1,['surf']),mon('venusaur',2,['protect'])],[mon('raticate',9,['tackle']),mon('raichu',10,['growl'])],'doubles');
 const t=a.act({choice:'move 1, move 1'});
 check(t.player[1].hp===s.player[1].hp,'Protect shields Surf ally');
 check(t.enemy.every((p,i)=>p.hp<s.enemy[i].hp),'Surf damages both opponents');
 check(t.player[0].pp[0].pp===14,'Spread costs exactly one PP');
 check(t.logs.some(l=>l.includes('|-activate|')&&l.includes('Protect')),'Protection event comes from upstream');a.close();
}
{
 const {a,s}=start([mon('blastoise',1,['surf']),mon('venusaur',2,['helping-hand'])],[mon('raticate',9,['tackle']),mon('raichu',10,['growl'])],'doubles');
 const t=a.act({choice:'move 1, move 1 -1'});
 check(t.player[1].hp<s.player[1].hp,'Unprotected ally actually receives Surf');
 check(t.logs.some(l=>l.includes('Helping Hand')),'Helping Hand resolves upstream');a.close();
}
{
 const {a,s}=start([mon('charizard',1,['flamethrower'],{item:'charizardite-y'}),mon('charizard',2,['flamethrower'],{item:'charizardite-x'})],[mon('blastoise',9,['protect'])]);
 check(!!s.request.active[0].canMegaEvo,'Mega available');
 const t=a.act({choice:'move 1 mega'});check(t.player[0].mega&&t.weather==='sun','Mega and Drought upstream');
 const u=a.act({choice:'switch 2'});check(!u.request.active[0].canMegaEvo,'Mega budget persists after switch');a.close();
}

{
 const {a,s}=start([mon('blastoise',1,['protect'],{hp:50}),mon('venusaur',2,['tackle'],{hp:20})],[mon('raticate',9,['growl'])]);
 const t=a.external({item:'potion',uid:2});check(t.player[1].hp===40,'Potion heals bench inside simulator');
 check(t.player[0].pp[0].pp===10&&t.turn===1,'Item costs action without spending move PP');
 check(t.logs.some(l=>l.includes('|move|p2')),'Opponent plays during item turn');
 assert.throws(()=>a.external({item:'potion',uid:999}));checks++;a.close();
}
{
 const {a,s}=start([mon('blastoise',1,['surf'],{hp:1}),mon('venusaur',2,['tackle'])],[mon('raichu',9,['thunderbolt'])]);
 const t=a.act({choice:'move 1'});check(t.request.forceSwitch?.[0],'Fainted player requires replacement');
 const u=a.act({choice:'switch 2'});check(u.playerActive[0]===2&&u.turn===1,'Forced replacement preserves global turn');a.close();
}
{
 const {a}=start([mon('blastoise',1,['protect'])],[mon('vulpix',9,['sunny-day'],{ability:'drought'}),mon('venusaur',10,['tackle'],{ability:'chlorophyll'}),mon('vulpix',11,['sunny-day'],{ability:'drought'})],'singles',{difficulty:'hard'});
 const view=a.aiView();check(!('choice' in view)&&!('iv' in view.enemies[0])&&!('moves' in view.enemies[0])&&!('item' in view.enemies[0]),'AI boundary excludes player builds/choices');
 check(choose(view,Dex)==='switch 2','Setter hands field to beneficiary');
 a.b.p1.active[0].illusion=a.b.p2.pokemon[1];const apparent=a.aiView().enemies[0];
 check(apparent.species==='venusaur'&&apparent.types.includes('Grass')&&!apparent.types.includes('Water'),'AI sees apparent Illusion species and types only');a.b.p1.active[0].illusion=null;
 view.weather='';view.request.active[0].moves=[{id:'tackle',pp:35,target:'normal',disabled:false}];view.own[1].position=0;view.own[0].active=false;view.own[1].active=true;view.own[0].hp=0;view.own[0].fainted=true;
 check(choose(view,Dex)==='switch 3','Renewal sends backup setter, not DPS');a.close();
}
{
 const {a}=start([mon('blastoise',1,['surf'],{hp:0}),mon('venusaur',2,['tackle'])],[mon('raticate',9,['tackle'])]);
 const s=a.state();check(s.playerActive[0]===2&&s.player.find(p=>p.uid===1).hp===0,'Fainted bench preserved, ready lead selected');
 const battle=a.b;check(battle.gen===9&&!battle.p1.active[0].canTerastallize,'Generation and disabled Tera');a.close();
}
{
 const a=new Adapter();assert.throws(()=>a.start({player:[mon('blastoise',1,['surf'])],enemy:[mon('raticate',1,['tackle'])],mode:'singles'}));checks++;
 const b=new Adapter();assert.throws(()=>b.start({player:[mon('blastoise',1,['surf'],{hp:999})],enemy:[mon('raticate',9,['tackle'])],mode:'singles'}));checks++;
}
{
 const {a}=start([mon('blastoise',1,['withdraw'],{hp:1}),mon('venusaur',2,['growth'],{hp:1}),mon('charizard',3,['flamethrower'])],[mon('raichu',9,['thunderbolt']),mon('raticate',10,['quick-attack'])],'doubles');
 const t=a.act({choice:'move 1, move 1'});check(t.request.forceSwitch.every(Boolean),'Both slots require replacements');
 const u=a.act({choice:'switch 3, pass'});check(u.playerActive.includes(3)&&!u.request.forceSwitch,'One reserve and forced pass accepted');a.close();
}
{
 const {a,s}=start([mon('blastoise',1,['surf'],{moves:[{id:'surf',pp:0}]})],[mon('raticate',9,['tackle'])]);
 check(s.request.active[0].moves[0].id==='struggle','Zero PP requests Struggle');
 const t=a.act({choice:'move 1'});check(t.player[0].pp[0].pp===0&&t.logs.some(l=>l.includes('Struggle')),'Struggle executes without inventing PP');a.close();
}
{
 const {a}=start([mon('blastoise',1,['protect'])],[mon('raichu',9,['electric-terrain','thunderbolt']),mon('raichu',10,['thunderbolt']),mon('raichu',11,['electric-terrain','thunderbolt'])],'singles',{difficulty:'hard'});
 check(choose(a.aiView(),Dex)==='move 1','Manual setter establishes missing Electric Terrain');
 a.act({choice:'move 1'});check(choose(a.aiView(),Dex)==='switch 2','Electric DPS receives terrain without requiring Surge Surfer');
 a.act({choice:'move 1'});const view=a.aiView();view.terrain='';view.own.find(p=>p.uid===9).fainted=true;view.own.find(p=>p.uid===9).hp=0;
 check(choose(view,Dex)==='switch 3','Expired terrain renews through backup setter instead of another DPS');a.close();
}

{
 const {a}=start([mon('raticate',1,['tackle']),mon('raticate',2,['tackle'])],[mon('raichu',9,['electric-terrain','thunderbolt']),mon('raichu',10,['electric-terrain','thunderbolt'])],'doubles',{difficulty:'hard'});
 const choice=choose(a.aiView(),Dex);
 check(choice.split(', ').filter(c=>c==='move 1').length===1,'Doubles coordinate one setter instead of repeating identical terrain');
 a.close();
}
{
 const {a}=start([mon('raticate',1,['tackle']),mon('raticate',2,['tackle'])],[mon('blastoise',9,['surf','water-pulse']),mon('charizard',10,['flamethrower'],{hp:1})],'doubles',{difficulty:'hard'});
 check(choose(a.aiView(),Dex).startsWith('move 2'),'Hard AI avoids Surf into critically wounded vulnerable ally');
 a.close();
}
{
 const {a}=start([mon('raticate',1,['tackle']),mon('raticate',2,['tackle'])],[mon('blastoise',9,['surf']),mon('venusaur',10,['protect','tackle'])],'doubles',{difficulty:'hard'});
 check(choose(a.aiView(),Dex).includes(', move 1'),'Own planned Surf coordinates ally Protect without reading player choices');
 const view=a.aiView();check(!('stats' in view.enemies[0])&&!('ability' in view.enemies[0]),'Stronger policy keeps hidden enemy stats and ability outside boundary');
 a.close();
}
{
 const {a}=start([mon('raticate',1,['tackle'])],[mon('omanyte',9,['rollout','withdraw'])]);
 const s=a.act({choice:'move 1'});
 check(s.logs.some(l=>l.includes('Rollout')),'Imported fossil Rollout resolves in real simulator');a.close();
}
{
 const player=[mon('blastoise',1,['surf']),mon('vulpix',2,['protect'],{ability:'drought'})];
 const enemy=[mon('rattata',9,['tail-whip'],{hp:1}),mon('magikarp',10,['splash'])];
 const {a}=start(player,enemy,'singles',{battleStyle:'shift',trainerBattle:true});
 let s=a.act({choice:'move 1'});
 check(s.shift?.species==='magikarp'&&s.enemyActive[0]===9,'Shift stops before announced enemy enters');
 check(!s.logs.some(l=>l.startsWith('|switch|p2a: 10')),'Upcoming switch remains pending');
 const before=JSON.stringify(s.player);const turn=s.turn;
 assert.throws(()=>a.act({choice:'move 1'}));checks++;
 assert.throws(()=>a.shift({uid:1}));checks++;
 assert.throws(()=>a.shift({uid:999}));checks++;
 check(JSON.stringify(a.state().player)===before,'Invalid shift targets are atomic');
 s=a.shift({uid:2});
 check(!s.shift&&s.playerActive[0]===2&&s.enemyActive[0]===10&&s.turn===turn,'Free switch and announced enemy enter without advancing a turn');
 check(s.weather==='sun'&&s.logs.some(l=>l.includes('Drought')),'Upstream entry ability resolves on free switch');
 check(s.player.find(p=>p.uid===1).pp[0].pp===14&&s.player.find(p=>p.uid===2).pp[0].pp===10,'Free switch spends no additional PP');
 assert.throws(()=>a.shift({uid:0}));checks++;a.close();
 const decline=start(player,enemy,'singles',{battleStyle:'shift',trainerBattle:true}).a;
 s=decline.act({choice:'move 1'});s=decline.shift({uid:0});
 check(!s.shift&&s.playerActive[0]===1&&s.enemyActive[0]===10&&s.turn===1,'Declining sends fixed announced enemy without action cost');decline.close();
 for(const options of [{battleStyle:'set',trainerBattle:true},{battleStyle:'shift',trainerBattle:false}]){
  const adapter=start(player,enemy,'singles',options).a;s=adapter.act({choice:'move 1'});
  check(!s.shift&&s.enemyActive[0]===10,'Set style and wild battles do not offer free shifts');adapter.close();
 }
 const healer=start([mon('blastoise',1,['protect'],{hp:50})],[mon('magikarp',9,['splash'])],'singles',{bagHealing:false}).a;
 const hp=healer.b.p1.active[0].hp;const round=healer.b.turn;
 assert.throws(()=>healer.external({item:'potion',uid:1}));checks++;
 check(healer.b.p1.active[0].hp===hp&&healer.b.turn===round,'Disabled healing has no effect or turn cost');
 check(healer.external({}).turn===1,'Capture failure remains a permitted external action');healer.close();
 const hazards=start(player,enemy,'singles',{battleStyle:'shift',trainerBattle:true}).a;
 hazards.b.p1.addSideCondition('stealthrock',hazards.b.p2.active[0],Dex.moves.get('stealthrock'));hazards.b.p1.active[0].boosts.spa=2;
 s=hazards.act({choice:'move 1'});s=hazards.shift({uid:2});
 check(s.player.find(p=>p.uid===2).hp<player[1].hp,'Free switch takes upstream entry hazard damage');
 check(s.player.find(p=>p.uid===1).stages.spa===0,'Free switch clears outgoing volatile stat stages natively');hazards.close();
 const entryKO=start([player[0],{...player[1],hp:1}],enemy,'singles',{battleStyle:'shift',trainerBattle:true}).a;
 entryKO.b.p1.addSideCondition('stealthrock',entryKO.b.p2.active[0],Dex.moves.get('stealthrock'));entryKO.act({choice:'move 1'});s=entryKO.shift({uid:2});
 check(s.request.forceSwitch?.[0]&&s.player.find(p=>p.uid===2).hp===0&&!s.shift,'Entry hazard KO yields native replacement rather than another free shift');entryKO.close();
 for(const [p,e,mode] of [[[player[0]],enemy,'singles'],[player,[enemy[0]],'singles'],[player,enemy,'doubles']]){
  const adapter=start(p,e,mode,{battleStyle:'shift',trainerBattle:true}).a;
  s=adapter.act({choice:mode==='doubles'?'move 1, move 1':'move 1'});
  check(!s.shift,'No free shift without reserves, after last foe or in doubles');adapter.close();
 }
 const doubleKO=start([{...player[0],hp:1,status:'poison'},player[1]],enemy,'singles',{battleStyle:'shift',trainerBattle:true}).a;
 s=doubleKO.act({choice:'move 1'});
 check(s.request.forceSwitch?.[0]&&!s.shift,'Simultaneous residual KO forces replacement without bonus offer');doubleKO.close();
 const weather=start(player,enemy,'singles',{battleStyle:'shift',trainerBattle:true}).a;
 weather.b.field.setWeather('raindance',weather.b.p1.active[0]);s=weather.act({choice:'move 1'});
 const duration=s.weatherTurns;s=weather.shift({uid:0});
 check(s.weatherTurns===duration,'Declining a shift does not consume an additional weather duration tick');weather.close();
 weather.start({player,enemy,mode:'singles',seed:[1,2,3,4],battleStyle:'shift',trainerBattle:true});
 weather.act({choice:'move 1'});check(!!weather.pendingShift,'Restart fixture actually pauses at a free shift');weather.close();
 weather.start({player,enemy,mode:'singles',seed:[1,2,3,4]});
 check(!weather.pendingShift&&weather.state().request.active?.length===1,'Same adapter can restart without stale pending choices');weather.close();
 const forms=start(player,[enemy[0],mon('charizard',10,['flamethrower'],{item:'charizardite-x'})],'singles',{battleStyle:'shift',trainerBattle:true}).a;
 forms.b.p2.pokemon[1].formeChange('Charizard-Mega-X',Dex.items.get('charizarditex'),true);
 s=forms.act({choice:'move 1'});check(s.shift?.species==='charizard','Previously Mega-evolved reserve announced with readable base catalogue identity');forms.close();
 const held=start([mon('blastoise',1,['protect'],{hp:50,item:'leftovers'})],[mon('magikarp',9,['splash'])],'singles',{bagHealing:false}).a;
 s=held.act({choice:'move 1'});check(s.player[0].hp>50,'Disabling bag healing does not disable held item recovery');held.close();
 assert.throws(()=>start(player,enemy,'singles',{battleStyle:'wrong'}));checks++;
}
console.log(`SHOWDOWN ADAPTER: ${checks} checks, 0 failures`);
