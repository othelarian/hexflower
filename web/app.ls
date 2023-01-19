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
  method: 'v12'
  risk: curr: '0'
  safe: curr: '0'
  flower:
    'c0': v: no, m: ['c1-0' 'c1-1' 'c1-2' 'c1-3' 'c1-4' 'c1-5']
    'c1-0': v: no, m: ['c3-0' 'c2-1' 'c1-1' 'c0' 'c1-5' 'c2-0']
    'c1-1': v: no, m: ['c2-1' 'c3-1' 'c2-2' 'c1-2' 'c0' 'c1-0']
    'c1-2': v: no, m: ['c1-1' 'c2-2' 'c3-2' 'c2-3' 'c1-3' 'c0']
    'c1-3': v: no, m: ['c0' 'c1-2' 'c2-3' 'c3-3' 'c2-4' 'c1-4']
    'c1-4': v: no, m: ['c1-5' 'c0' 'c1-3' 'c2-4' 'c3-4' 'c2-5']
    'c1-5': v: no, m: ['c2-0' 'c1-0' 'c0' 'c1-4' 'c2-5' 'c3-5']
    'c2-0': v: no, m: ['c2-4' 'c3-0' 'c1-0' 'c1-5' 'c3-5' 'c2-2']
    'c2-1':
      v: yes, v4: no
      m: ['c2-3' 'c2-5' 'c3-1' 'c1-1' 'c1-0' 'c3-0']
    'c2-2':
      v: yes, v4: no
      m: ['c3-1' 'c2-4' 'c2-0' 'c3-2' 'c1-2' 'c1-1']
    'c2-3': v: no, m: ['c1-2' 'c3-2' 'c2-5' 'c2-1' 'c3-3' 'c1-3']
    'c2-4':
      v: yes, v4: no
      m: ['c1-4' 'c1-3' 'c3-3' 'c2-0' 'c2-2' 'c3-4']
    'c2-5':
      v: yes, v4: no
      m: ['c3-5' 'c1-5' 'c1-4' 'c3-4' 'c2-1' 'c2-3']
    'c3-0': v: no, m: ['c3-3' 'c3-5' 'c2-1' 'c1-0' 'c2-0' 'c3-1']
    'c3-1':
      v: yes, v4: yes
      m: ['c3-2' 'c3-4' 'c3-0' 'c2-2' 'c1-1' 'c2-1']
    'c3-2': v: no, m: ['c2-2' 'c3-3' 'c2-5' 'c3-1' 'c2-3' 'c1-2']
    'c3-3': v: no, m: ['c1-3' 'c2-3' 'c3-4' 'c3-0' 'c3-2' 'c2-4']
    'c3-4':
      v: yes, v4: yes
      m: ['c2-5' 'c1-4' 'c2-4' 'c3-5' 'c3-1' 'c3-3']
    'c3-5': v: no, m: ['c3-4' 'c2-0' 'c1-5' 'c2-5' 'c3-0' 'c3-2']
  probs:
    risk:
      probs.8+probs.9
      probs.6+probs.7
      probs.4+probs.5
      probs.2+probs.3
      probs.12
      probs.10+probs.11
    safe:
      probs.2+probs.3
      probs.12
      probs.10+probs.11
      probs.8+probs.9
      probs.6+probs.7
      probs.4+probs.5

calculate = !->
  apply-hex = (v,dom,m) ->
    for i til 6
      np = v[dom].old * store.probs[dom][i]
      store.flower[m[i]][dom].curr += np
  calc = (dom, max) ->
    strt = if dom is 'risk' then 'c1-1' else 'c1-4'
    for i to max
      if i is 0 then store.flower[strt][dom].curr = 1
      else
        move-value dom
        for c,v of store.flower when store.flower[c][dom].old isnt 0
          m = get-move v
          apply-hex v, dom, m
  curate-v = (m,r) -> [(if i is 1 then "c1-#r" else x) for x,i in m]
  get-move = (v) ->
    switch store.method
      when 'v3'
        if v.v then curate-v v.m, 1 else v.m
      when 'v4'
        if v.v and v.v4 then curate-v v.m, 1 else v.m
      when 'v12' then v.m
  update = (dom) ->
    s = if dom is 'risk' then 'up' else 'dn'
    document.querySelector "##c text.#s" .innerHTML = get-percent dom, c
    base = document.querySelector "##c .base.#s"
    base.style.fill = get-color dom, c
    base.style.stroke-width = (if v[dom].curr is 0 then 0 else 1) + 'px'
  # compute
  init-calc!
  calc 'risk', (store.risk.curr <? 10)
  calc 'safe', (store.safe.curr <? 10)
  for c,v of store.flower
    update 'risk'
    update 'safe'

change-method = (chx) !->
  store.method = chx
  calculate!

check-move-input = (id) ->
  e = getId "#{id}-moves"
  store[id].curr = if /^[0-9]{0,2}$/ isnt e.value then store[id].curr else e.value
  e.value = store[id].curr

get-color = (domain, key) ->
  v = store.flower[key][domain].curr
  vc = if v < 0.5 then 255 else Math.round (1 - v) * 255
  vo = if v >= 0.5 then 0 else Math.round (1 - v * 2) * 255
  if domain is 'risk' then "rgb(#vc,#vo,#vo)" else "rgb(#vo,#vc,#vo)"

get-percent = (domain, key) ->
  ((Math.round store.flower[key][domain].curr * 10000) / 100) + "%"

init-calc = ->
  for c of store.flower then store.flower[c] <<< {risk: {old: 0, curr: 0}, safe: {old: 0, curr: 0}}

move-value = (domain) ->
  for c of store.flower
    store.flower[c][domain].old = store.flower[c][domain].curr
    store.flower[c][domain].curr = 0

risk-move = (_) !->
  c = check-move-input 'risk'
  calculate!

safe-move = (_) !->
  c = check-move-input 'safe'
  calculate!

init = !->
  getId \risk-moves .addEventListener 'change' risk-move
  getId \risk-moves .addEventListener 'keyup', (evt) ~> evt.target.value = store.risk.curr
  #getId \risk-moves .addEventListener 'keyup', (evt) ~> console.log evt
  getId \safe-moves .addEventListener 'change' safe-move
  getId \safe-moves .addEventListener 'keyup', (evt) ~> evt.target.value = store.safe.curr
  calculate!

window.change-method = change-method
window.init = init
window.store = store
