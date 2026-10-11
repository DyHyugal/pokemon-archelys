'use strict';
// This pure policy receives only own-team information and public active opponents.
const supportAbilities={drought:'sunnyday',drizzle:'raindance',sandstream:'sandstorm',snowwarning:'snowscape',electricsurge:'electricterrain',grassysurge:'grassyterrain',psychicsurge:'psychicterrain',mistysurge:'mistyterrain'};
const beneficiaries={chlorophyll:'sunnyday',solarpower:'sunnyday',swiftswim:'raindance',raindish:'raindance',surgesurfer:'electricterrain',sandrush:'sandstorm',slushrush:'snowscape'};
const setters=new Set(Object.values(supportAbilities));
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
 return r.active.map((request,index)=>{
  const p=active[index];if(!p||p.fainted)return 'pass';
  const options=request.moves.map((m,i)=>({...m,slot:i+1})).filter(m=>!m.disabled&&m.pp!==0);
  const canSwitch=!request.trapped;
  // Preserve setter -> beneficiary -> renewal, using no hidden player build.
  if(view.difficulty==='hard'&&desired){
   if(!running){const set=options.find(m=>m.id===desired);if(set)return 'move '+set.slot;
    const reserve=bench.find(q=>!used.has(q.uid)&&isSetter(q));if(reserve&&canSwitch){used.add(reserve.uid);return 'switch '+(own.indexOf(reserve)+1);}}
   else if(isSetter(p)&&active.length===1){const receiver=bench.find(q=>!used.has(q.uid)&&beneficiaries[q.ability]===desired);
    if(receiver&&canSwitch){used.add(receiver.uid);return 'switch '+(own.indexOf(receiver)+1);}}
  }
  let best=null;
  for(const m of options){const move=Dex.moves.get(m.id);
   let targets=['normal','any','adjacentFoe'].includes(m.target)?view.enemies.map((q,i)=>({q,target:i+1})).filter(x=>x.q&&!x.q.fainted):[{q:view.enemies.find(q=>q&&!q.fainted),target:0}];
   if(['adjacentAlly','adjacentAllyOrSelf'].includes(m.target)){if(active.length<2)continue;targets=[{q:null,target:-(1-index+1)}];}
   for(const {q,target} of targets){
    let score=move.basePower||0;
    if(q){score*=q.types.reduce((v,t)=>v*(Dex.getImmunity(move.type,t)?Math.pow(2,Dex.getEffectiveness(move.type,t)):0),1);
     if(p.types.includes(move.type))score*=1.5;}
    if(move.category==='Status')score=move.id==='helpinghand'&&active.length>1?30:(!q?.status&&move.status?25:8);
    if(setters.has(move.id))score=running?0:35;
    if(view.difficulty==='chill')score=Math.random()*100;
    if(!best||score>best.score)best={m,target,score};
   }
  }
  if(!best)return 'move 1';
  const suffix=request.canMegaEvo&&!mega&&view.difficulty==='hard'?' mega':'';if(suffix)mega=true;
  return 'move '+best.m.slot+(best.target&&active.length>1?' '+best.target:'')+suffix;
 }).join(', ');
}
module.exports={choose};
