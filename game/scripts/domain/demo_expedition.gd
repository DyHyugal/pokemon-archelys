extends RefCounted
## Optional local expedition; every milestone is saved and rewards are atomic.
const ACTIONS={"cut":"brush-cleared","rock-smash":"rock-cleared","strength":"boulder-moved"}
const FLAGS=["brush-cleared","rock-cleared","boulder-moved","cache-opened","expedition-reward"]
static func unlocked(state: RefCounted,action: String) -> bool:
 return action in ACTIONS and state.flags.has("survey") and not state.campaign.adventure.in_battle
static func perform(state: RefCounted,action: String) -> bool:
 if not unlocked(state,action) or state.flags.has(ACTIONS[action]):return false
 state.flags[ACTIONS[action]]=true;return true
static func ready(state: RefCounted) -> bool:
 return ACTIONS.values().all(func(flag: String):return state.flags.has(flag))
static func open_cache(state: RefCounted) -> bool:
 if state.campaign.adventure.in_battle or not ready(state) or state.flags.has("cache-opened"):return false
 state.flags['cache-opened']=true;return true
static func reward(state: RefCounted) -> bool:
 var a: RefCounted=state.campaign.adventure
 if a.in_battle or not state.flags.has("cache-opened") or state.flags.has("expedition-reward") or int(a.bag.get("poke-ball",0))+5>999:return false
 a.bag['poke-ball']=int(a.bag.get('poke-ball',0))+5;state.flags['expedition-reward']=true;return true
static func can_fly(state: RefCounted,target: String) -> bool:
 return not state.campaign.adventure.in_battle and state.flags.has("complete") and target in ["town","trail"] and {"town":"isle-port","trail":"isle-jungle"}[target] in state.campaign.adventure.exploration.visited
