#!/usr/bin/env python3
"""Read-only catalogue preflight. No species selection or automatic corrections."""
import argparse,json,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
GROWTH={'slow','fast','medium-slow','medium-fast','medium','erratic','fluctuating'}
def audit_catalog(data):
 errors=[]
 def fail(test,path,why):
  if not test:errors.append(f'{path}: {why}')
 def integer(v,low,high):return type(v) is int and low<=v<=high
 if not isinstance(data,dict):return ['catalog: expected an object']
 for group in ['species','moves','items','abilities','type_names','status_names','chart']:
  if not isinstance(data.get(group),dict):return [f'{group}: expected an object']
 species,moves=data['species'],data['moves']
 for group in ['moves','items','abilities','type_names','status_names']:
  for key,entry in data[group].items():
   if not isinstance(entry,dict):errors.append(f'{group}.{key}: expected an object');continue
   names=entry.get('names',entry)
   fail(isinstance(names,dict) and all(isinstance(names.get(lang),str) and names[lang].strip() for lang in ['fr','en']),f'{group}.{key}.names','FR/EN names required')
 for key,m in moves.items():
  if not isinstance(m,dict):continue
  fail(integer(m.get('pp'),1,64),f'moves.{key}.pp','integer 1..64 required')
  fail(m.get('type') in data['type_names'],f'moves.{key}.type','unknown type')
  fail(m.get('category') in ['physical','special','status'],f'moves.{key}.category','unknown category')
 for key,s in species.items():
  prefix=f'species.{key}'
  if not isinstance(s,dict):errors.append(prefix+': expected an object');continue
  names=s.get('names',{})
  fail(isinstance(names,dict) and all(isinstance(names.get(lang),str) and names[lang].strip() for lang in ['fr','en']),prefix+'.names','FR/EN names required')
  fail(s.get('growth') in GROWTH,prefix+'.growth','unsupported growth curve')
  for field,high in [('stats',255),('effort',3)]:
   values=s.get(field)
   fail(isinstance(values,list) and len(values)==6 and all(integer(v,0 if field=='effort' else 1,high) for v in values),prefix+'.'+field,'six bounded integer values required')
  for field,low,high in [('base_exp',0,1000),('catch_rate',0,255)]:fail(integer(s.get(field),low,high),prefix+'.'+field,'invalid integer')
  types=s.get('types',[])
  fail(isinstance(types,list) and 1<=len(types)<=2 and all(isinstance(t,str) and t in data['type_names'] for t in types) and len(set(types))==len(types),prefix+'.types','one or two distinct known types required')
  abilities=s.get('abilities',[])
  fail(isinstance(abilities,list) and bool(abilities) and all(isinstance(a,str) and a in data['abilities'] for a in abilities) and s.get('ability') in abilities,prefix+'.abilities','default and slots must exist')
  previous=s.get('previous')
  if previous is not None:fail(isinstance(previous,str) and previous in species,prefix+'.previous','missing previous stage')
  fail(integer(s.get('minimum_level',1),1,100),prefix+'.minimum_level','invalid stage threshold')
  evolution=s.get('evolution',{})
  if not isinstance(evolution,dict):errors.append(prefix+'.evolution: expected an object')
  elif evolution:
   target=evolution.get('target')
   fail(isinstance(target,str) and target in species,prefix+'.evolution.target','missing target')
   fail(('level' in evolution) != ('item' in evolution),prefix+'.evolution','one level or item method required by current schema')
   if 'level' in evolution:fail(integer(evolution['level'],1,100),prefix+'.evolution.level','invalid evolution level')
   if 'item' in evolution:fail(isinstance(evolution['item'],str) and evolution['item'] in data['items'],prefix+'.evolution.item','unknown evolution item')
   if isinstance(target,str) and isinstance(species.get(target),dict):
    child=species[target]
    fail(({'medium':'medium-fast'}.get(child.get('growth'),child.get('growth')))==({'medium':'medium-fast'}.get(s.get('growth'),s.get('growth'))),prefix+'.evolution','family growth curves must match')
    fail(child.get('previous')==key,prefix+'.evolution','target must reference its previous stage')
    if 'level' in evolution:fail(child.get('minimum_level')==evolution['level'],prefix+'.evolution','target minimum level must match threshold')
  learnset=s.get('learnset')
  if not isinstance(learnset,list) or not learnset:errors.append(prefix+'.learnset: nonempty list required')
  else:
   for i,row in enumerate(learnset):fail(isinstance(row,dict) and isinstance(row.get('move'),str) and row['move'] in moves and integer(row.get('level'),1,100),prefix+f'.learnset[{i}]','known move and level 1..100 required')
  machines=s.get('machines',[])
  fail(isinstance(machines,list) and all(isinstance(m,str) and m in moves for m in machines),prefix+'.machines','unknown machine move')
  for direction in ['previous','evolution']:
   cursor=key;seen=set()
   while isinstance(cursor,str) and isinstance(species.get(cursor),dict):
    if cursor in seen:errors.append(prefix+f'.{direction}: cycle');break
    seen.add(cursor);row=species[cursor]
    cursor=row.get('previous') if direction=='previous' else (row.get('evolution',{}).get('target') if isinstance(row.get('evolution',{}),dict) else None)
 for attack,targets in data['chart'].items():
  fail(attack in data['type_names'] and isinstance(targets,dict),'chart.'+attack,'unknown type or malformed row')
  if isinstance(targets,dict):
   for target,value in targets.items():fail(target in data['type_names'] and type(value) in [int,float] and value in [0,.5,1,2],f'chart.{attack}.{target}','invalid single-type effectiveness')
 return errors

def main():
 p=argparse.ArgumentParser();p.add_argument('--catalog',type=pathlib.Path,default=ROOT/'game/data/pokemon/laboratory.json');p.add_argument('--report',type=pathlib.Path);args=p.parse_args()
 try:data=json.loads(args.catalog.read_text());errors=audit_catalog(data)
 except (OSError,ValueError,TypeError,AttributeError) as e:errors=[f'catalog: malformed input ({e})']
 if args.report:args.report.write_text(json.dumps({'errors':errors,'selection_changed':False},ensure_ascii=False,indent=2)+'\n')
 for error in errors:print(error,file=sys.stderr)
 print(f'POKEMON CATALOG: {len(errors)} errors; no data changed');return bool(errors)
if __name__=='__main__':sys.exit(main())
