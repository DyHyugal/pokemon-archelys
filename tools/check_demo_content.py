#!/usr/bin/env python3
"""Preflight for local Pokemon metadata and future owner demo selection.
Reads only; never invents missing species or rewrites the owner's choices.
"""
import argparse, json, pathlib, sys
ROOT = pathlib.Path(__file__).resolve().parents[1]

def audit(catalog, content):
    from check_pokemon_catalog import audit_catalog
    errors = audit_catalog(catalog)
    species = catalog.get('species', {})
    moves = catalog.get('moves', {})
    def fail(condition, text):
        if not condition: errors.append(text)
    def integer(value, lo, hi):
        return type(value) is int and lo <= value <= hi
    def legal(name, level):
        visited = set()
        while name in species:
            if name in visited: return False
            visited.add(name)
            entry = species[name]
            if entry.get('previous') and level < entry.get('minimum_level', 1):
                return False
            evo = entry.get('evolution', {})
            if 'level' in evo and level >= evo['level']: return False
            return any(m.get('level', 101) <= level for m in entry.get('learnset', []))
        return False
    for name, entry in species.items():
        fail(all(entry.get('names', {}).get(lang) for lang in ('fr', 'en')), f'{name}: FR/EN name missing')
        stats = entry.get('stats', [])
        fail(len(stats) == 6 and all(integer(n, 1, 255) for n in stats), f'{name}: invalid six base stats')
        fail(entry.get('ability') in entry.get('abilities', []) and all(a in catalog.get('abilities', {}) for a in entry.get('abilities', [])), f'{name}: unknown ability')
        fail(bool(entry.get('types')) and all(t in catalog.get('type_names', {}) for t in entry.get('types', [])), f'{name}: unknown type')
        previous = entry.get('previous')
        if previous:
            fail(previous in species and integer(entry.get('minimum_level', 1), 1, 100), f'{name}: invalid previous stage')
        evolution = entry.get('evolution', {})
        if evolution:
            fail(evolution.get('target') in species, f'{name}: missing evolution target')
            if 'level' in evolution: fail(integer(evolution['level'], 1, 100), f'{name}: invalid evolution level')
        cursor, visited = name, set()
        while cursor in species:
            if cursor in visited:
                errors.append(f'{name}: evolution cycle'); break
            visited.add(cursor)
            cursor = species[cursor].get('evolution', {}).get('target')
        learnset = entry.get('learnset', [])
        fail(bool(learnset), f'{name}: empty learnset')
        for move in learnset:
            fail(move.get('move') in moves and integer(move.get('level'), 1, 100), f'{name}: illegal learnset entry {move}')
        for move in entry.get('machines', []): fail(move in moves, f'{name}: unknown machine {move}')
    fail(content.get('status') in ('temporary-demo-fixtures', 'owner-selection'), 'Content: status missing')
    for field, level_field in [('starters', 'starter_level'), ('wild', 'wild_level')]:
        level = content.get(level_field)
        fail(integer(level, 1, 100), f'Content: invalid {level_field}')
        values = content.get(field, [])
        fail(isinstance(values, list) and bool(values) and len(values) == len(set(values)), f'Content: empty/duplicate {field}')
        if isinstance(values, list) and integer(level, 1, 100):
            for name in values: fail(legal(name, level), f'Content: {field} {name} unavailable/illegal at {level}')
    level = content.get('fishing_level')
    fail(integer(level, 1, 100) and legal(content.get('fishing'), level), 'Content: fishing unavailable/illegal')
    fail(content.get('gift_egg') in ('bulbasaur','charmander','squirtle'), 'Content: gift not yet supported by incubator')
    team = content.get('trainer', [])
    fail(isinstance(team, list) and 1 <= len(team) <= 6, 'Content: trainer needs 1–6 members')
    for entry in team:
        fail(integer(entry.get('level'), 1, 100) and legal(entry.get('species'), entry.get('level')), f'Content: illegal trainer member {entry}')
    return errors

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--catalog', type=pathlib.Path, default=ROOT/'game/data/pokemon/laboratory.json')
    p.add_argument('--content', type=pathlib.Path, default=ROOT/'game/data/demo/content.json')
    args = p.parse_args()
    try:
        catalog, content = json.loads(args.catalog.read_text()), json.loads(args.content.read_text())
        errors = audit(catalog, content)
    except (OSError, ValueError, TypeError, KeyError, AttributeError) as exc:
        errors = [f'Malformed input: {exc}']
    for error in errors: print(error, file=sys.stderr)
    print(f'DEMO CONTENT: {len(catalog.get("species", {})) if "catalog" in locals() and isinstance(catalog,dict) else 0} species checked, {len(errors)} errors; final owner roster pending')
    return bool(errors)

if __name__ == '__main__': sys.exit(main())
