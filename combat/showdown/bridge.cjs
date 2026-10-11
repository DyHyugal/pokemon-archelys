'use strict';
// Archélys integration: upstream battle rules are never reimplemented here.
const path = require('node:path');
const readline = require('node:readline');
const {Battle, Dex} = require('./upstream/dist/sim');
const {choose} = require('./policy.cjs');
const catalog = require('./catalog.json');
const VERSION = 1;
const statKeys = ['hp','atk','def','spa','spd','spe'];
const statuses = {'':'',burn:'brn',poison:'psn',paralysis:'par',sleep:'slp',freeze:'frz'};
const reverseStatus = Object.fromEntries(Object.entries(statuses).map(([a,b])=>[b,a]));
const weatherIds = {sunnyday:'sun',raindance:'rain',sandstorm:'sand',snowscape:'snow'};
const terrainIds = {electricterrain:'electric',grassyterrain:'grass',mistyterrain:'misty',psychicterrain:'psychic'};
const id = x => Dex.toID(x);
const bounded = (x,a,b) => Number.isInteger(x) && x>=a && x<=b;
function checkedTeam(team) {
 if (!Array.isArray(team)||team.length<1||team.length>6) throw Error('Invalid team size');
 const seen = new Set();
 for (const p of team) {
  if (!bounded(p.uid,1,1000000)||seen.has(p.uid)) throw Error('Invalid identity');seen.add(p.uid);
  if (!catalog.species[p.species]||!Dex.species.get(p.species).exists||!bounded(p.level,1,100)) throw Error('Invalid species/level');
  if (!Array.isArray(p.moves)||!p.moves.length||p.moves.length>4) throw Error('Invalid moveset');
  for(const m of p.moves) if(!catalog.moves[m.id]||!Dex.moves.get(m.id).exists||!bounded(m.pp,0,catalog.moves[m.id].pp)) throw Error('Invalid move/PP');
  for(const [key,max] of [['iv',31],['ev',252]]) if(!Array.isArray(p[key])||p[key].length!==6||p[key].some(x=>!bounded(x,0,max))) throw Error('Invalid stats');
  if(p.ev.reduce((a,b)=>a+b,0)>510||!Dex.natures.get(p.nature).exists) throw Error('Invalid nature/EV');
  if(!catalog.species[p.species].abilities.includes(p.ability)||!Dex.abilities.get(p.ability).exists) throw Error('Invalid ability');
  if(p.item && (!catalog.items[p.item]||!Dex.items.get(p.item).exists)) throw Error('Invalid item');
  if(!(p.status in statuses)||!bounded(p.status_turns,0,3)||!bounded(p.hp,0,1000)) throw Error('Invalid condition');
 }
 return team;
}
function convert(p) {
 return {name:String(p.uid),species:p.species,level:p.level,nature:p.nature,ability:p.ability,item:p.item,
  ivs:Object.fromEntries(statKeys.map((k,i)=>[k,p.iv[i]])),evs:Object.fromEntries(statKeys.map((k,i)=>[k,p.ev[i]])),
  moves:p.moves.map(m=>m.id),shiny:!!p.shiny,archelys:p};
}
function format(mode) {
 const f={...Dex.formats.get('gen9customgame'),id:'archelys'+mode,name:'Archélys '+mode,mod:'gen9',gameType:mode,
  ruleset:['+Past','Terastal Clause','Dynamax Clause','Z-Move Clause'],
  battle:{calculatePP(move){return move.pp;}},
  onBegin(){
   for(const s of this.sides) for(const p of s.pokemon) {
    const src=p.set.archelys;
    if(src.hp>p.maxhp)throw Error('HP exceeds species stats');
    p.hp=src.hp;
    for(let i=0;i<p.moveSlots.length;i++)p.moveSlots[i].pp=src.moves[i].pp;
    if(!p.hp){p.fainted=true;s.pokemonLeft--;continue;}
    // Import already-existing conditions before entry abilities, without applying a new status.
    p.status=statuses[src.status];
    p.statusState={id:p.status,target:p};
    if(p.status==='slp')p.statusState.time=src.status_turns;
   }
  }};
 Dex.formats.rulesetCache.set(f.id,f);return f;
}
class Adapter {
 constructor(){this.b=null;this.cursor=0;this.sources=new Map();this.observed={};this.rewarded=new Set();this.difficulty='normal';}
 start(req){
  if(this.b)throw Error('Battle already running');
  if(!['singles','doubles'].includes(req.mode))throw Error('Invalid mode');
  const teams=[checkedTeam(req.player),checkedTeam(req.enemy)];
  const uids=teams.flat().map(p=>p.uid);if(new Set(uids).size!==uids.length)throw Error('Duplicate identity');
  const count=req.mode==='doubles'?2:1;
  for(const team of teams)if(team.filter(p=>p.hp>0).length<count)throw Error('Not enough healthy Pokémon');
  this.difficulty=req.difficulty||'normal';this.sources=new Map(teams.flat().map(p=>[p.uid,p]));
  const order=team=>[...team.filter(p=>p.hp>0),...team.filter(p=>p.hp===0)].map(convert);
  try{this.b=new Battle({format:format(req.mode),strictChoices:true,seed:req.seed,
    p1:{name:'Player',team:order(teams[0])},p2:{name:'Opponent',team:order(teams[1])}});}
  catch(e){this.b?.destroy();this.b=null;throw e;}
  return this.state();
 }
 // Build the AI's boundary explicitly. No opponent sets, IV/EV/items or queued choices.
 aiView(){
  const side=this.b.p2;
  return {difficulty:this.difficulty,request:JSON.parse(JSON.stringify(side.activeRequest)),
   own:side.pokemon.map(p=>({uid:Number(p.name),species:p.species.id,level:p.level,hp:p.hp,maxhp:p.maxhp,
    ability:p.ability,item:p.item,active:p.isActive,fainted:p.fainted,position:p.position,
    moves:p.moveSlots.map(m=>({id:m.id,pp:m.pp})),types:p.getTypes(),stats:p.storedStats})),
   enemies:this.b.p1.active.map(p=>p?{species:(p.illusion||p).species.id,level:(p.illusion||p).level,
    hpFraction:p.hp/p.maxhp,status:p.status,types:p.illusion?Dex.species.get(p.illusion.species.id).types:p.getTypes(),fainted:p.fainted,boosts:{...p.boosts},revealed:this.observed[p.name]||[]}:null),
   weather:this.b.field.weather,terrain:this.b.field.terrain};
 }
 enemyChoice(){return choose(this.aiView(),Dex);}
 autoplaySwitches(){
  for(let i=0;i<8&&!this.b.ended;i++){
   const r=this.b.p2.activeRequest;
   if(!r?.forceSwitch||(!this.b.p1.activeRequest?.wait && this.b.p1.activeRequest))break;
   this.b.choose('p2',this.enemyChoice());
  }
 }
 act(req){
  if(!this.b||this.b.ended)throw Error('No active battle');
  if(typeof req.choice!=='string'||req.choice.length>256)throw Error('Invalid choice');
  // Decide before accepting player choices; the pure policy never receives them.
  const enemy=this.enemyChoice();
  try{this.b.p1.choose(req.choice);}catch(e){this.b.p1.clearChoice();throw e;}
  if(!this.b.p1.isChoiceDone()){this.b.p1.clearChoice();throw Error('Incomplete choice');}
  if(!this.b.p2.activeRequest?.wait){
   try{this.b.p2.choose(enemy);}catch(e){this.b.p2.clearChoice();this.b.p2.autoChoose();}
  }
  this.b.commitChoices();this.autoplaySwitches();return this.state();
 }
 external(req){
  if(!this.b||this.b.ended||this.b.gameType!=='singles'||this.b.p1.activeRequest?.forceSwitch)throw Error('External action unavailable');
  const target=this.b.p1.pokemon.find(p=>Number(p.name)===req.uid);
  if(req.item){
   if(!target||target.fainted)throw Error('Invalid item target');
   if(req.item==='potion'&&target.hp<target.maxhp){target.heal(20);this.b.add('-heal',target,target.getHealth,'[from] item: Potion');}
   else if(req.item==='antidote'&&['psn','tox'].includes(target.status))target.cureStatus();
   else if(req.item==='paralyze-heal'&&target.status==='par')target.cureStatus();
   else throw Error('Item has no effect');
  }
  const enemy=this.enemyChoice();
  this.b.p1.autoChoose();
  // Adventure item/capture failure costs the player's action; Showdown still resolves the foe/residuals.
  this.b.p1.choice.actions=this.b.p1.choice.actions.map(a=>a.choice==='move'?{choice:'pass',pokemon:a.pokemon}:a);
  if(!this.b.p2.activeRequest?.wait){try{this.b.p2.choose(enemy);}catch(e){this.b.p2.clearChoice();this.b.p2.autoChoose();}}
  this.b.commitChoices();this.autoplaySwitches();return this.state();
 }
 state(){
  const b=this.b;const raw=b.log.slice(this.cursor);this.cursor=b.log.length;
  // Keep only the player's version of split protocol records.
  const logs=[];
  for(let i=0;i<raw.length;i++){
   if(raw[i].startsWith('|split|')){logs.push(raw[i+1+(raw[i]!=='|split|p1')]);i+=2;}
   else logs.push(raw[i]);
  }
  for(const line of logs){const a=line.split('|');if(a[1]==='move'&&a[2].startsWith('p1')){
   const uid=a[2].split(': ')[1];(this.observed[uid] ||= []).push(id(a[3]));}}
  const defeated=[];
  for(const p of b.p2.pokemon)if(p.fainted&&!this.rewarded.has(p.name)){this.rewarded.add(p.name);defeated.push(Number(p.name));}
  const party=s=>s.pokemon.map(p=>({uid:Number(p.name),hp:p.hp,maxhp:p.maxhp,
   status:reverseStatus[p.status]||(p.status==='tox'?'poison':''),status_turns:p.status==='slp'?Math.min(3,p.statusState.time||0):0,
   item:p.item?(Object.keys(catalog.items).find(k=>id(k)===p.item)||p.item):'',
   form:p.species.id,mega:p.species.isMega||false,
   // Transform's temporary moves must never replace permanent campaign moves or their PP.
   pp:(p.transformed?p.baseMoveSlots:p.moveSlots).map(m=>({id:m.id,pp:m.pp})),
   stages:{...p.boosts},ability:p.ability}));
  const request=b.p1.activeRequest?JSON.parse(JSON.stringify(b.p1.activeRequest)):{};
  return {protocol:VERSION,turn:Math.max(0,b.turn-1),request,player:party(b.p1),enemy:party(b.p2),
   playerActive:b.p1.active.map(p=>p?Number(p.name):0),enemyActive:b.p2.active.map(p=>p?Number(p.name):0),
   weather:weatherIds[b.field.weather]||'',weatherTurns:b.field.weatherState.duration||0,
   terrain:terrainIds[b.field.terrain]||'',terrainTurns:b.field.terrainState.duration||0,
   logs,defeated,ended:b.ended,winner:b.winner||'',megaUsed:b.sides.map(s=>s.pokemon.some(p=>p.species.isMega))};
 }
 close(){this.b?.destroy();this.b=null;return {closed:true};}
}
if(require.main===module){
 const adapter=new Adapter();const rl=readline.createInterface({input:process.stdin,crlfDelay:Infinity});
 rl.on('line',line=>{
  let req;
  try{
   if(Buffer.byteLength(line)>65536)throw Error('Message too large');req=JSON.parse(line);
   if(!bounded(req.id,1,1000000)||req.protocol!==VERSION)throw Error('Protocol mismatch');
   const ops={start:'start',act:'act',external:'external',close:'close'};
   if(!ops[req.op])throw Error('Unknown operation');
   const state=adapter[ops[req.op]](req);
   process.stdout.write(JSON.stringify({id:req.id,ok:true,...state})+'\n');
   if(req.op==='close')rl.close();
  }catch(e){process.stdout.write(JSON.stringify({id:req?.id||0,ok:false,error:e.message})+'\n');}
 });
 rl.on('close',()=>adapter.close());
}
module.exports={Adapter,VERSION};
