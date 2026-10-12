#!/usr/bin/env python3
"""Exercise refusal of actual content mistakes, not a copy of the validator."""
import copy,json
from check_demo_content import ROOT,audit
catalog=json.loads((ROOT/'game/data/pokemon/laboratory.json').read_text())
content=json.loads((ROOT/'game/data/demo/content.json').read_text())
assert not audit(catalog,content)
for mutation in ('unknown','underlevel','overlevel','duplicate','unusable','cycle','missing-machine','missing-name'):
    data,selection=copy.deepcopy(catalog),copy.deepcopy(content)
    if mutation=='unknown':selection['wild']=['future-fakemon']
    elif mutation=='underlevel':selection['trainer']=[{'species':'charizard','level':6}]
    elif mutation=='overlevel':selection['wild']=['magikarp'];selection['wild_level']=50
    elif mutation=='duplicate':selection['starters']=['bulbasaur','bulbasaur']
    elif mutation=='unusable':selection['starters']=['kabuto'];selection['starter_level']=1
    elif mutation=='cycle':data['species']['bulbasaur']['evolution']['target']='bulbasaur'
    elif mutation=='missing-machine':data['species']['bulbasaur']['machines'].append('typo-move')
    elif mutation=='missing-name':del data['species']['bulbasaur']['names']['fr']
    assert audit(data,selection),mutation+' mistakenly accepted'
print('DEMO CONTENT CONTRACTS: 8 real metadata/selection errors refused')
