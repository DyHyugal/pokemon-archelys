'use strict';
// Research only. Does not modify or replace the game's battle engine.
const path = require('node:path');
const assert = require('node:assert/strict');
const root = process.env.ARCHELYS_SHOWDOWN_ROOT;
if (!root) throw new Error('Set ARCHELYS_SHOWDOWN_ROOT to the pinned, built Showdown checkout');
const {Battle, BattleStream, Dex, getPlayerStreams} = require(path.join(root, 'dist/sim'));
const seed = [1,2,3,4];
function format(gameType='singles') {
 const id='archelysresearch'+gameType;
 if(Dex.formats.rulesetCache.has(id))return Dex.formats.rulesetCache.get(id);
 const f={...Dex.formats.get('gen9customgame'),id,name:'Archélys research '+gameType,mod:'gen9',gameType,playerCount:2,
  ruleset:['+Past','Terastal Clause','Dynamax Clause','Z-Move Clause'],
  // Explicit research policy: the lab currently has no PP-Up system.
  battle:{calculatePP(move){return move.pp;}}};
 Dex.formats.rulesetCache.set(id,f);return f;
}
function set(species, moves, extra={}) {
 return {species,moves,level:50,nature:'Hardy',evs:{hp:0,atk:0,def:0,spa:0,spd:0,spe:0},
  ivs:{hp:15,atk:15,def:15,spa:15,spd:15,spe:15},...extra};
}
function create(p1,p2,gameType='singles') {
 return new Battle({format:format(gameType),seed,strictChoices:true,p1:{name:'Owner',team:p1},p2:{name:'Opponent',team:p2}});
}
function fixture() {
 return create([set('Blastoise',['surf','protect']),set('Venusaur',['helpinghand','protect'])],
  [set('Raticate',['splash']),set('Raichu',['splash'])],'doubles');
}
let checks=0;const evidence=[];
function check(label,fn) {fn();checks++;evidence.push(label);}
async function run() {
 let b=fixture();
 check('gen9 doubles creates four actors without a server',()=>assert.equal(b.getAllActive().length,4));
 check('battle format excludes Tera and Dynamax',()=>assert.ok(b.getAllPokemon().every(p=>!p.canTerastallize)&&b.sides.every(s=>s.dynamaxUsed)));
 b.makeChoices('move surf, move protect','move splash, move splash');
 check('Protect precedes Surf and shields the ally',()=>assert.equal(b.p1.active[1].hp,b.p1.active[1].maxhp));
 check('Surf damages both opponents, not the caster',()=>assert.ok(b.p2.active.every(p=>p.hp<p.maxhp)&&b.p1.active[0].hp===b.p1.active[0].maxhp));
 check('spread consumes one PP from a no-PP-Up moveset',()=>assert.equal(b.p1.active[0].moveSlots[0].pp,14));b.destroy();
 b=fixture();b.makeChoices('move surf, move helpinghand -1','move splash, move splash');
 check('Surf really damages its unprotected ally',()=>assert.ok(b.p1.active[1].hp<b.p1.active[1].maxhp));
 check('Helping Hand is resolved before the damage',()=>assert.ok(b.log.findIndex(l=>l.includes('|Helping Hand|'))<b.log.findIndex(l=>l.includes('|Surf|'))));b.destroy();
 b=create([set('Charizard',['flamethrower'],{item:'Charizardite Y'}),set('Charizard',['flamethrower'],{item:'Charizardite X'})],[set('Blissey',['splash'])]);
 check('historical Mega is available under gen9 rules',()=>assert.equal(b.p1.active[0].canMegaEvo,'Charizard-Mega-Y'));
 b.makeChoices('move flamethrower mega','move splash');
 check('Mega Y transforms and creates sun',()=>assert.equal(b.field.weather,'sunnyday'));
 b.makeChoices('switch 2','move splash');
 check('second compatible Pokémon cannot Mega again',()=>assert.equal(b.p1.active[0].canMegaEvo,false));b.destroy();
 b=create([set('Alakazam',['hiddenpower'],{ivs:{hp:31,atk:30,def:31,spa:30,spd:31,spe:30}})],[set('Blissey',['splash'])]);
 b.makeChoices('move hiddenpower','move splash');
 check('removed Hidden Power executes in gen9 custom format',()=>assert.ok(b.p2.active[0].hp<b.p2.active[0].maxhp));b.destroy();
 b=create([set('Ninetales',['splash'],{ability:'Drought'})],[set('Blissey',['splash'])]);
 check('entry ability sets weather without scripted duplication',()=>assert.equal(b.field.weatherState.duration,5));
 for(let i=0;i<5;i++)b.makeChoices('move splash','move splash');
 check('weather expires after five actual turns',()=>assert.equal(b.field.weather,''));b.destroy();
 b=create([set('Pincurchin',['splash'],{ability:'Electric Surge'})],[set('Blissey',['spore'])]);b.makeChoices('move splash','move spore');
 check('Electric Terrain prevents sleep for grounded targets',()=>assert.equal(b.p1.active[0].status,''));b.destroy();
 b=create([set('Clefable',['followme']),set('Blastoise',['splash'])],[set('Raichu',['thunderbolt']),set('Magikarp',['splash'])],'doubles');
 b.makeChoices('move followme, move splash','move thunderbolt 2, move splash');
 check('Follow Me redirects an attack away from the intended ally',()=>assert.ok(b.p1.active[0].hp<b.p1.active[0].maxhp&&b.p1.active[1].hp===b.p1.active[1].maxhp));b.destroy();
 b=create([set('Raichu',['splash']),set('Pikachu',['splash'],{ability:'Lightning Rod'})],[set('Raichu',['thunderbolt']),set('Magikarp',['splash'])],'doubles');
 b.makeChoices('move splash, move splash','move thunderbolt 1, move splash');
 check('Lightning Rod redirects and raises the correct actor stat',()=>assert.equal(b.p1.active[1].boosts.spa,1));b.destroy();
 b=create([set('Eevee',['protect'])],[set('Ninjask',['protect'])]);b.makeChoices('move protect','move protect');
 check('Protect fails for last actor, even on first use',()=>assert.ok(b.log.some(l=>l.startsWith('|-fail|p1a:'))));b.destroy();
 b=fixture();b.p1.active[0].hp=70;b.p1.active[0].status='psn';b.p1.active[0].moveSlots[0].pp=3;
 const encoded=b.toJSON();const restored=Battle.fromJSON(JSON.stringify(encoded));
 check('serialization retains damaged HP, status and depleted PP',()=>assert.equal(restored.p1.active[0].hp,70));
 check('serialization retains status and PP specifically',()=>assert.ok(restored.p1.active[0].status==='psn'&&restored.p1.active[0].moveSlots[0].pp===3));
 b.makeChoices('move protect, move helpinghand -1','move splash, move splash');restored.makeChoices('move protect, move helpinghand -1','move splash, move splash');
 check('restoring state preserves deterministic continuation',()=>assert.deepEqual(b.p1.pokemon.map(p=>[p.hp,p.status]),restored.p1.pokemon.map(p=>[p.hp,p.status])));b.destroy();restored.destroy();
 b=fixture();const before=b.turn;
 check('illegal command is rejected without resolving a turn',()=>{assert.throws(()=>b.choose('p1','move 99, move protect'),/Invalid choice/);assert.equal(b.turn,before);});b.destroy();
 b=create([set('Eevee',['splash']),set('Pikachu',['splash']),set('Squirtle',['splash'])],[set('Eevee',['splash']),set('Pikachu',['splash']),set('Squirtle',['splash'])],'triples');
 check('six-actor technical format is supported with gen9 mechanics',()=>assert.equal(b.getAllActive().length,6));b.makeChoices('move splash, move splash, move splash','move splash, move splash, move splash');
 check('six actors share a single turn resolution',()=>assert.equal(b.turn,2));b.destroy();
 const stream=new BattleStream();const views=getPlayerStreams(stream);let own='';let foe='';
 const reader1=(async()=>{for await(const chunk of views.p1)own+=chunk+'\n';})();
 const reader2=(async()=>{for await(const chunk of views.p2)foe+=chunk+'\n';})();
 await stream.write(`>start ${JSON.stringify({formatid:'gen9customgame',seed})}\n>player p1 ${JSON.stringify({name:'Owner',team:[set('Blastoise',['surf'])]})}\n>player p2 ${JSON.stringify({name:'Opponent',team:[set('Eevee',['splash'])]})}`);
 await stream.write('>p1 team 1\n>p2 team 1');await stream.write('>forcewin p1');await Promise.all([reader1,reader2]);
 check('official stream exposes own private move requests',()=>assert.ok(own.includes('"id":"surf"')));
 check('opponent stream does not reveal unrevealed Surf',()=>assert.ok(!foe.includes('"id":"surf"')&&!foe.includes('|Surf|')));
 console.log(JSON.stringify({checks,passed:checks,node:process.version,upstream:'942cda71d14bf0618bd57991708a2e2734b6daba',evidence},null,2));
}
// Blocking pipe only in the headless research test; live UI must use asynchronous I/O.
async function bridge() {
 const rl=require('node:readline').createInterface({input:process.stdin,crlfDelay:Infinity});let b;
 for await(const line of rl) {
  try {
   const req=JSON.parse(line);
   if(req.op==='start'){b?.destroy();b=fixture();}
   else if(req.op==='choose'){if(!b)throw new Error('no battle');b.makeChoices(req.p1,req.p2);}
   else if(req.op==='quit'){b?.destroy();console.log(JSON.stringify({ok:true,closed:true}));rl.close();return;}
   else throw new Error('unknown operation');
   console.log(JSON.stringify({ok:true,turn:b.turn,actors:b.getAllActive().length,hp:b.p1.active.map(p=>p.hp),maxhp:b.p1.active.map(p=>p.maxhp),pp:b.p1.active[0].moveSlots[0].pp,log:b.log.slice(-12)}));
  }catch(e){console.log(JSON.stringify({ok:false,error:e.message}));}
 }
 b?.destroy();
}
if(process.argv.includes('--bridge'))bridge().catch(e=>{console.error(e);process.exit(1);});
else run().catch(e=>{console.error(e);process.exit(1);});
