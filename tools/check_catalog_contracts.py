#!/usr/bin/env python3
import copy,json,hashlib
from check_pokemon_catalog import ROOT,audit_catalog
path=ROOT/'game/data/pokemon/laboratory.json';original=path.read_bytes();catalog=json.loads(original)
assert not audit_catalog(catalog)
mutations={
 'growth':lambda j:j['species']['pikachu'].update(growth='typo'),
 'fractional-stat':lambda j:j['species']['pikachu']['stats'].__setitem__(0,35.5),
 'negative-effort':lambda j:j['species']['pikachu']['effort'].__setitem__(0,-1),
 'ability':lambda j:j['species']['pikachu'].update(ability='future-unknown'),
 'missing-name':lambda j:j['species']['pikachu']['names'].pop('fr'),
 'missing-target':lambda j:j['species']['pikachu']['evolution'].update(target='future-unknown'),
 'missing-item':lambda j:j['species']['pikachu']['evolution'].update(item='future-unknown'),
 'method-conflict':lambda j:j['species']['pikachu']['evolution'].update(level=20),
 'reverse-cycle':lambda j:j['species']['pikachu'].update(previous='raichu'),
 'forward-cycle':lambda j:j['species']['bulbasaur']['evolution'].update(target='bulbasaur'),
 'growth-mismatch':lambda j:j['species']['ivysaur'].update(growth='slow'),
 'threshold-mismatch':lambda j:j['species']['ivysaur'].update(minimum_level=17),
 'invalid-pp':lambda j:j['moves']['ember'].update(pp=0),
 'move-type':lambda j:j['moves']['ember'].update(type='future-type'),
 'invalid-chart':lambda j:j['chart']['fire'].update(grass=3),
 'malformed-entry':lambda j:j['species'].update(pikachu=[]),
 'malformed-learnset':lambda j:j['species']['pikachu'].update(learnset=[None]),
}
for name,mutate in mutations.items():
 data=copy.deepcopy(catalog);mutate(data);assert audit_catalog(data),name+' was incorrectly accepted'
assert hashlib.sha256(path.read_bytes()).digest()==hashlib.sha256(original).digest()
print(f'CATALOG CONTRACTS: {len(mutations)} actual metadata errors rejected; original unchanged')
