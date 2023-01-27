getId = (id) -> document.getElementById id

probs =
  2: 1/36
  3: 1/18
  4: 1/12
  5: 1/9
  6: 5/36
  7: 1/6
  8: 5/36
  9: 1/9
  10: 1/12
  11: 1/18
  12: 1/36

store =
  moves: 0
  flower:
    'c0': v: '10', m: ['c1-0' 'c1-1' 'c1-2' 'c1-3' 'c1-4' 'c1-5']
    'c1-0': v: '13', m: ['c3-0' 'c2-1' 'c1-1' 'c0' 'c1-5' 'c2-0']
    'c1-1': v: '11', m: ['c2-1' 'c3-1' 'c2-2' 'c1-2' 'c0' 'c1-0']
    'c1-2': v: '6', m: ['c1-1' 'c2-2' 'c3-2' 'c2-3' 'c1-3' 'c0']
    'c1-3': v: '5', m: ['c0' 'c1-2' 'c2-3' 'c3-3' 'c2-4' 'c1-4']
    'c1-4': v: '9', m: ['c1-5' 'c0' 'c1-3' 'c2-4' 'c3-4' 'c2-5']
    'c1-5': v: '', m: ['c2-0' 'c1-0' 'c0' 'c1-4' 'c2-5' 'c3-5']
    'c2-0': v: '16', m: ['c2-4' 'c3-0' 'c1-0' 'c1-5' 'c3-5' 'c2-2']
    'c2-1': v: '14', m: ['c2-3' 'c2-5' 'c3-1' 'c1-1' 'c1-0' 'c3-0']
    'c2-2': v: '7', m: ['c3-1' 'c2-4' 'c2-0' 'c3-2' 'c1-2' 'c1-1']
    'c2-3': v: '2', m: ['c1-2' 'c3-2' 'c2-5' 'c2-1' 'c3-3' 'c1-3']
    'c2-4': v: '4', m: ['c1-4' 'c1-3' 'c3-3' 'c2-0' 'c2-2' 'c3-4']
    'c2-5': v: '12', m: ['c3-5' 'c1-5' 'c1-4' 'c3-4' 'c2-1' 'c2-3']
    'c3-0': v: '17', m: ['c3-3' 'c3-5' 'c2-1' 'c1-0' 'c2-0' 'c3-1']
    'c3-1': v: '18-20', m: ['c3-2' 'c3-4' 'c3-0' 'c2-2' 'c1-1' 'c2-1']
    'c3-2': v: '3', m: ['c2-2' 'c3-3' 'c2-5' 'c3-1' 'c2-3' 'c1-2']
    'c3-3': v: '1', m: ['c1-3' 'c2-3' 'c3-4' 'c3-0' 'c3-2' 'c2-4']
    'c3-4': v: '8', m: ['c2-5' 'c1-4' 'c2-4' 'c3-5' 'c3-1' 'c3-3']
    'c3-5': v: '15', m: ['c3-4' 'c2-0' 'c1-5' 'c2-5' 'c3-0' 'c3-2']
  probs:
    probs.2+probs.3
    probs.12
    probs.10+probs.11
    probs.8+probs.9
    probs.6+probs.7
    probs.4+probs.5

calculate = !->
  down-value = !->
    for , v of store.flower
      v.old = v.curr
      v.curr = 0
  for _, v of store.flower then v <<< {old: 0, curr: 0, acc: 0}
  max = 0
  for wc, wv of store.flower
    for c,v of store.flower when c isnt wc then v <<< {old: 0, curr: 0}
    store.flower['c1-5'].curr = 1
    for til store.moves
      down-value!
      for c, v of store.flower when c isnt wc and v.old isnt 0
        for p, i in store.probs
          if v.m[i] is wc then wv.acc += (v.old * p)
          else store.flower[v.m[i]].curr += (v.old * p)
      max = max >? wv.acc
  for c, v of store.flower when c isnt 'c1-5'
    max = if max is 0 then 1 else max
    document.querySelector "##{c} text.dn" .innerHTML = get-percent v.acc
    document.querySelector "##{c} .base.dn" .style.fill = get-color v.acc, max

get-color = (val, max) ->
  c = (1 - val / max) * 255
  "rgb(255, #c, #c)"

get-percent = (v) -> ((Math.round v * 10000) / 100) + "%"

move = (dir) !->
  unless dir is 'dn' and store.moves is 0
    store.moves += (if dir is 'dn' then -1 else 1)
    getId 'moves-val' .innerText = store.moves
    calculate!

init = !->
  for c, v of store.flower then document.querySelector "##{c} text.up" .innerHTML = v.v
  calculate!

window.init = init
window.moveup = ~> move 'up'
window.movedn = ~> move 'dn'
window.store = store
