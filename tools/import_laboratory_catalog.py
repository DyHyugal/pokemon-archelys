import csv,pathlib,json,hashlib
import argparse,urllib.request
parser=argparse.ArgumentParser(description="Rebuild the bounded test catalogue from pinned PokéAPI CSVs")
parser.add_argument('--source-dir',type=pathlib.Path,default=pathlib.Path('/tmp/archelys-pokeapi-catalog'))
args=parser.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
src=args.source_dir;src.mkdir(parents=True,exist_ok=True)
reference=json.loads((root/'game/data/pokemon/reference.json').read_text())
for name,expected in reference['sha256'].items():
 p=src/name
 if not p.exists():
  p.write_bytes(urllib.request.urlopen(f"https://raw.githubusercontent.com/PokeAPI/pokeapi/{reference['commit']}/data/v2/csv/{name}",timeout=30).read())
 if hashlib.sha256(p.read_bytes()).hexdigest()!=expected:raise SystemExit('Source checksum mismatch: '+name)
def rows(n):return list(csv.DictReader((src/(n+'.csv')).open()))
def index(n,key='id'):return {r[key]:r for r in rows(n)}
sp=index('pokemon_species');pk=index('pokemon');types=index('types');mv=index('moves');abilities=index('abilities')
names=rows('pokemon_species_names');mnames=rows('move_names')
ids=['1','2','3','4','5','6','7','8','9','19','20','25','26','37','38','129','130','138','139','140','141','142']
allowed='tackle growl scratch ember smokescreen dragon-breath fire-fang flamethrower water-gun tail-whip withdraw bite water-pulse hydro-pump vine-whip growth poison-powder sleep-powder razor-leaf seed-bomb thunder-shock thunder-wave quick-attack double-team spark thunderbolt struggle splash sunny-day rain-dance electric-terrain grassy-terrain misty-terrain psychic-terrain solar-beam will-o-wisp sandstorm snowscape protect helping-hand surf rock-slide rollout'.split()
moveids={i for i,r in mv.items() if r['identifier'] in allowed}
levels=rows('pokemon_moves');stats=rows('pokemon_stats');ptype=rows('pokemon_types');pability=rows('pokemon_abilities')
data={'species':{},'moves':{},'items':{},'chart':{}}
for sid in ids:
 s=sp[sid];id=s['identifier'];v=27 if any(r['pokemon_id']==sid and r['version_group_id']=='27' for r in levels) else max(int(r['version_group_id']) for r in levels if r['pokemon_id']==sid and int(r['version_group_id'])<=20)
 learned=[{'level':int(r['level']),'move':mv[r['move_id']]['identifier']} for r in levels if r['pokemon_id']==sid and int(r['version_group_id'])==v and r['pokemon_move_method_id']=='1' and r['move_id'] in moveids and int(r['level'])>0]
 learned.sort(key=lambda r:r['level']);seen=set();learned=[r for r in learned if not (r['move'] in seen or seen.add(r['move']))]
 a=next(r for r in pability if r['pokemon_id']==sid and r['slot']=='1')
 data['species'][id]={'names':{lang:next(r['name'] for r in names if r['pokemon_species_id']==sid and r['local_language_id']==lid) for lang,lid in [('fr','5'),('en','9')]},'stats':[int(r['base_stat']) for r in stats if r['pokemon_id']==sid],'types':[types[r['type_id']]['identifier'] for r in ptype if r['pokemon_id']==sid],'growth':{'1':'slow','2':'medium','3':'fast','4':'medium-slow'}[s['growth_rate_id']],'catch_rate':int(s['capture_rate']),'base_exp':int(pk[sid]['base_experience']),'ability':abilities[a['ability_id']]['identifier'],'learnset':learned,'learnset_version_group':v}
for source,target,level in [('bulbasaur','ivysaur',16),('ivysaur','venusaur',32),('charmander','charmeleon',16),('charmeleon','charizard',36),('squirtle','wartortle',16),('wartortle','blastoise',36),('rattata','raticate',20),('omanyte','omastar',40),('kabuto','kabutops',40)]:
 data['species'][source]['evolution']={'target':target,'level':level};data['species'][target].update(previous=source,minimum_level=level)
data['species']['magikarp']['evolution']={'target':'gyarados','level':20}
data['species']['gyarados'].update(previous='magikarp',minimum_level=20)
data['species']['vulpix']['evolution']={'target':'ninetales','item':'fire-stone'}
data['species']['ninetales']['previous']='vulpix'
data['species']['pikachu']['evolution']={'target':'raichu','item':'thunder-stone'}
data['species']['raichu']['previous']='pikachu'
effects={'growl':{'stage':'attack','change':-1,'target':'opponents'},'tail-whip':{'stage':'defense','change':-1,'target':'opponents'},'withdraw':{'stage':'defense','change':1,'self':True},'smokescreen':{'stage':'accuracy','change':-1},'double-team':{'stage':'evasion','change':1,'self':True},'growth':{'growth':True,'self':True},'poison-powder':{'status':'poison','powder':True},'sleep-powder':{'status':'sleep','powder':True},'thunder-wave':{'status':'paralysis'},'ember':{'status':'burn','chance':10},'flamethrower':{'status':'burn','chance':10},'thunder-shock':{'status':'paralysis','chance':10},'thunderbolt':{'status':'paralysis','chance':10},'dragon-breath':{'status':'paralysis','chance':30},'spark':{'status':'paralysis','chance':30},'bite':{'flinch':30},'fire-fang':{'flinch':10,'status':'burn','chance':10},'water-pulse':{'confusion':20},'razor-leaf':{'crit_stage':1,'target':'opponents'},'struggle':{'struggle':True},'splash':{'self':True},'sunny-day':{'weather':'sun','self':True},'rain-dance':{'weather':'rain','self':True},'electric-terrain':{'terrain':'electric','self':True},'grassy-terrain':{'terrain':'grass','self':True},'misty-terrain':{'terrain':'misty','self':True},'psychic-terrain':{'terrain':'psychic','self':True},'sandstorm':{'weather':'sand','self':True},'snowscape':{'weather':'snow','self':True},'solar-beam':{'charge':True},'will-o-wisp':{'status':'burn'},'protect':{'protect':True,'self':True},'helping-hand':{'helping_hand':True,'target':'ally'},'surf':{'target':'all-adjacent'},'rock-slide':{'target':'opponents','flinch':30}}
contacts=set('tackle scratch vine-whip bite fire-fang quick-attack spark struggle'.split())
for i in moveids:
 r=mv[i];id=r['identifier'];data['moves'][id]={'names':{lang:next(n['name'] for n in mnames if n['move_id']==i and n['local_language_id']==lid) for lang,lid in [('fr','5'),('en','9')]},'type':types[r['type_id']]['identifier'],'power':int(r['power'] or 0),'pp':int(r['pp']),'accuracy':int(r['accuracy'] or 0),'priority':int(r['priority']),'category':{'1':'status','2':'physical','3':'special'}[r['damage_class_id']],'contact':id in contacts,**effects.get(id,{})}
for id,fr,en in [('poke-ball','Poké Ball','Poké Ball'),('great-ball','Super Ball','Great Ball'),('potion','Potion','Potion'),('antidote','Antidote','Antidote'),('paralyze-heal','Anti-Para','Paralyze Heal'),('oran-berry','Baie Oran','Oran Berry'),('leftovers','Restes','Leftovers'),('lucky-egg','Œuf Chance','Lucky Egg'),('thunder-stone','Pierre Foudre','Thunder Stone'),('fire-stone','Pierre Feu','Fire Stone'),('venusaurite','Florizarrite','Venusaurite'),('charizardite-x','Dracaufite X','Charizardite X'),('charizardite-y','Dracaufite Y','Charizardite Y'),('blastoisinite','Tortankite','Blastoisinite'),('helix-fossil','Fossile Nautile','Helix Fossil'),('dome-fossil','Fossile Dôme','Dome Fossil'),('old-amber','Vieil Ambre','Old Amber')]:data['items'][id]={'names':{'fr':fr,'en':en}}
# Official eighteen-type chart, sparse notation: > double, < half, = immune.
chart={'normal':('','rock steel','ghost'),'fire':('grass ice bug steel','fire water rock dragon',''),'water':('fire ground rock','water grass dragon',''),'electric':('water flying','electric grass dragon','ground'),'grass':('water ground rock','fire grass poison flying bug dragon steel',''),'ice':('grass ground flying dragon','fire water ice steel',''),'fighting':('normal ice rock dark steel','poison flying psychic bug fairy','ghost'),'poison':('grass fairy','poison ground rock ghost','steel'),'ground':('fire electric poison rock steel','grass bug','flying'),'flying':('grass fighting bug','electric rock steel',''),'psychic':('fighting poison','psychic steel','dark'),'bug':('grass psychic dark','fire fighting poison flying ghost steel fairy',''),'rock':('fire ice flying bug','fighting ground steel',''),'ghost':('psychic ghost','dark','normal'),'dragon':('dragon','steel','fairy'),'dark':('psychic ghost','fighting dark fairy',''),'steel':('ice rock fairy','fire water electric steel',''),'fairy':('fighting dragon dark','fire poison steel','')}
for t,(double,half,zero) in chart.items():data['chart'][t]={**{x:2 for x in double.split()},**{x:0.5 for x in half.split()},**{x:0 for x in zero.split()}}
for id,record in data['species'].items():
 pid=next(r['id'] for r in rows('pokemon') if r['identifier']==id)
 record['effort']=[int(r['effort']) for r in stats if r['pokemon_id']==pid]
for id,record in data['species'].items():
 pid=next(r['id'] for r in pk.values() if r['identifier']==id)
 record['abilities']=[abilities[r['ability_id']]['identifier'] for r in pability if r['pokemon_id']==pid]
 record['machines']=sorted({mv[r['move_id']]['identifier'] for r in levels if r['pokemon_id']==pid and int(r['version_group_id'])==record['learnset_version_group'] and r['pokemon_move_method_id']=='4' and r['move_id'] in moveids})
# Transient historical Mega forms: exact base statistics from the pinned CSV.
data['mega_forms']={}
for identifier,base,stone in [('venusaur-mega','venusaur','venusaurite'),('charizard-mega-x','charizard','charizardite-x'),('charizard-mega-y','charizard','charizardite-y'),('blastoise-mega','blastoise','blastoisinite')]:
 pid=next(r['id'] for r in pk.values() if r['identifier']==identifier)
 a=next(r for r in pability if r['pokemon_id']==pid and r['slot']=='1')
 data['mega_forms'][stone]={'base':base,'stats':[int(r['base_stat']) for r in stats if r['pokemon_id']==pid],'types':[types[r['type_id']]['identifier'] for r in ptype if r['pokemon_id']==pid],'ability':abilities[a['ability_id']]['identifier']}
for field,file,key in [('abilities','ability_names','ability_id'),('type_names','type_names','type_id')]:
 records=rows(file);lookup=rows('abilities' if field=='abilities' else 'types')
 data[field]={r['identifier']:{lang:next(n['name'] for n in records if n[key]==r['id'] and n['local_language_id']==lid) for lang,lid in [('fr','5'),('en','9')]} for r in lookup if (field=='abilities' and r['identifier'] in {a for s in data['species'].values() for a in s['abilities']} | {s['ability'] for s in data['mega_forms'].values()} or field=='type_names' and r['identifier'] in data['chart'])}
nature_names=['Hardi','Solo','Brave','Rigide','Mauvais','Assuré','Docile','Relax','Malin','Lâche','Timide','Pressé','Sérieux','Jovial','Naïf','Modeste','Doux','Discret','Pudique','Foufou','Calme','Gentil','Malpoli','Prudent','Bizarre']
nature_keys='hardy lonely brave adamant naughty bold docile relaxed impish lax timid hasty serious jolly naive modest mild quiet bashful rash calm gentle sassy careful quirky'.split()
data['natures']={k:{'fr':f,'en':k.title()} for k,f in zip(nature_keys,nature_names)}
data['stat_names']={'hp':{'fr':'PV','en':'HP'},'attack':{'fr':'Attaque','en':'Attack'},'defense':{'fr':'Défense','en':'Defense'},'special_attack':{'fr':'Attaque Spé.','en':'Sp. Attack'},'special_defense':{'fr':'Défense Spé.','en':'Sp. Defense'},'speed':{'fr':'Vitesse','en':'Speed'}}
data['status_names']={'burn':{'fr':'brûlure','en':'burn'},'poison':{'fr':'empoisonnement','en':'poison'},'paralysis':{'fr':'paralysie','en':'paralysis'},'sleep':{'fr':'sommeil','en':'sleep'},'freeze':{'fr':'gel','en':'freeze'}}
(root/'game/data/pokemon/laboratory.json').write_text(json.dumps(data,ensure_ascii=False,indent=2,sort_keys=True)+'\n')
print('Verified catalogue:',len(data['species']),'species;',len(data['moves']),'moves')
