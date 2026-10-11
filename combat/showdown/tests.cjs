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
console.log(`SHOWDOWN ADAPTER: ${checks} checks, 0 failures`);
