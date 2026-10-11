'use strict';
// This pure policy receives only own-team information and public active opponents.
const supportAbilities={drought:'sunnyday',drizzle:'raindance',sandstream:'sandstorm',snowwarning:'snowscape',electricsurge:'electricterrain',grassysurge:'grassyterrain',psychicsurge:'psychicterrain',mistysurge:'mistyterrain'};
const beneficiaries={chlorophyll:'sunnyday',solarpower:'sunnyday',swiftswim:'raindance',raindish:'raindance',surgesurfer:'electricterrain',sandrush:'sandstorm',slushrush:'snowscape'};
const setters=new Set(Object.values(supportAbilities));
function benefits(p,field){
 if(beneficiaries[p.ability]===field)return true;
 const type={sunnyday:'Fire',raindance:'Water',electricterrain:'Electric',grassyterrain:'Grass',psychicterrain:'Psychic'}[field];
 if(!type||!p.types.includes(type))return false;
 return !field.endsWith('terrain')||(!p.types.includes('Flying')&&p.ability!=='levitate');
}
function choose(view,Dex){
 const r=view.request;if(!r||r.wait)return '';
 const own=view.own;const used=new Set();let mega=false;
 const active=own.filter(p=>p.active).sort((a,b)=>a.position-b.position);
 const bench=own.filter(p=>!p.active&&!p.fainted&&p.hp>0);
 const pickSwitch=()=>bench.find(p=>!used.has(p.uid));
 if(r.forceSwitch)return r.forceSwitch.map(force=>{if(!force)return 'pass';const p=pickSwitch();if(!p)return 'pass';used.add(p.uid);return 'switch '+(own.indexOf(p)+1);}).join(', ');
 let desired=own.filter(p=>!p.fainted).map(p=>beneficiaries[p.ability]).find(Boolean);
 if(!desired)desired=own.filter(p=>!p.fainted).flatMap(p=>p.moves.map(m=>m.pp>0&&setters.has(m.id)?m.id:'')).find(Boolean);
 const isSetter=p=>supportAbilities[p.ability]===desired||p.moves.some(m=>m.pp>0&&m.id===desired);
 const running=desired&&(view.weather===desired||view.terrain===desired);
 let plannedField=false;let allySpread=false;
 const effectiveness=(type,q)=>q.types.reduce((v,t)=>v*(Dex.getImmunity(type,t)?Math.pow(2,Dex.getEffectiveness(type,t)):0),1);
 return r.active.map((request,index)=>{
  const p=active[index];if(!p||p.fainted)return 'pass';
  const options=request.moves.map((m,i)=>({...m,slot:i+1})).filter(m=>!m.disabled&&m.pp!==0);
  const canSwitch=!request.trapped;
  // Preserve setter -> beneficiary -> renewal, using no hidden player build.
  if(view.difficulty==='hard'&&desired){
   if(!running&&!plannedField){const set=options.find(m=>m.id===desired);if(set){plannedField=true;return 'move '+set.slot;}
    const reserve=bench.find(q=>!used.has(q.uid)&&isSetter(q));if(reserve&&canSwitch){used.add(reserve.uid);plannedField=true;return 'switch '+(own.indexOf(reserve)+1);}}
   else if(running&&isSetter(p)){const receiver=bench.find(q=>!used.has(q.uid)&&!isSetter(q)&&benefits(q,desired));
    if(receiver&&canSwitch){used.add(receiver.uid);return 'switch '+(own.indexOf(receiver)+1);}}
  }
  let best=null;
  for(const m of options){const move=Dex.moves.get(m.id);
   let targets=['normal','any','adjacentFoe'].includes(m.target)?view.enemies.map((q,i)=>({q,target:i+1})).filter(x=>x.q&&!x.q.fainted):[{q:view.enemies.find(q=>q&&!q.fainted),target:0}];
   if(['adjacentAlly','adjacentAllyOrSelf'].includes(m.target)){if(active.length<2||!active[1-index]||active[1-index].fainted)continue;targets=[{q:null,target:-(1-index+1)}];}
   for(const {q,target} of targets){
    let score=move.basePower||0;
    if(move.category!=='Status'){
     if(view.difficulty==='hard'){score*=typeof move.accuracy==='number'?move.accuracy/100:1;
      score*=Math.min(1.5,Math.max(0.6,(move.category==='Physical'?p.stats?.atk:p.stats?.spa)/100||1));}
    }
    if(q){score*=effectiveness(move.type,q);
     if(p.types.includes(move.type))score*=1.5;}
    if(['allAdjacent','allAdjacentFoes'].includes(m.target)&&move.category!=='Status'){
     score=(move.basePower||0)*(p.types.includes(move.type)?1.5:1)*view.enemies.filter(q=>q&&!q.fainted).reduce((sum,q)=>sum+effectiveness(move.type,q),0)*0.75;
     if(m.target==='allAdjacent'&&view.difficulty==='hard'){
      const ally=active[1-index];if(ally&&!ally.fainted)score-=(move.basePower||0)*effectiveness(move.type,ally)*(ally.hp/ally.maxhp<0.4?2:0.7);
     }
    }
    if(move.category==='Status')score=move.id==='helpinghand'&&active.length>1&&active[1-index]?.moves.some(m=>m.pp>0&&Dex.moves.get(m.id).category!=='Status')?38:(!q?.status&&move.status?25:8);
    if(view.difficulty==='hard'&&move.id==='protect')score=allySpread?100:0;
    if(view.difficulty==='hard'&&move.priority>0&&q?.hpFraction<0.2&&score>0)score*=1.4;
    if(setters.has(move.id))score=running||plannedField?0:35;
    if(view.difficulty==='chill')score=Math.random()*100;
    if(!best||score>best.score)best={m,target,score};
   }
  }
  if(!best)return 'move 1';
  if(best.m.target==='allAdjacent')allySpread=true;
  const suffix=request.canMegaEvo&&!mega&&view.difficulty==='hard'?' mega':'';if(suffix)mega=true;
  return 'move '+best.m.slot+(best.target&&active.length>1?' '+best.target:'')+suffix;
 }).join(', ');
}
module.exports={choose};
