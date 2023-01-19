getId = (id) -> document.getElementById id

store =
  method: 'pre'
  risk: curr: '0'
  safe: curr: '0'
  flower: {}
  list: [
    'c0'
    'c1-0' 'c1-1' 'c1-2' 'c1-3' 'c1-4' 'c1-5'
    'c2-0' 'c2-1' 'c2-2' 'c2-3' 'c2-4' 'c2-5'
    'c3-0' 'c3-1' 'c3-2' 'c3-3' 'c3-4' 'c3-5'
  ]

calculate = !->
  #
  for i from 0 to store.risk.curr
    if i is 0
      for c in store.list then store.flower[c].risk = {old: 0, curr: 0}
      store.flower.c0.curr = 1
    else
      #
      #
      void
      #
    #
    console.log i
    #
  for i from 0 to store.safe.curr
    #
    #
    void
    #
  #
  for c in store.list
    #
    document.querySelector "##{c} text.up" .innerHTML = '??'
    #
    document.querySelector "##{c} text.dn" .innerHTML = '--'
    #

change-method = (chx) !->
  store.method = chx
  calculate!

check-move-input = (id) ->
  e = getId "#{id}-moves"
  store[id].curr = if /^[0-9]{0,1}$/ isnt e.value then store[id].curr else e.value
  e.value = store[id].curr

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
  for c in store.list then store.flower[c] = {safe: {}, risk: {}}
  calculate!

window.change-method = change-method
window.init = init
window.store = store
