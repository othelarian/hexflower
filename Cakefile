bach = require 'bach'
chokidar = require 'chokidar'
connect = require 'connect'
fse = require 'fs-extra'
http = require 'http'
livescript = require 'livescript'
{ extname } = require 'path'
pug = require 'pug'
{ rollup, watch } = require 'rollup'
sass = require 'sass'
serveStatic = require 'serve-static'
{ terser } = require 'rollup-terser'

# OPTIONS #############################

option '-r', '--release', 'set compilation mode to release'

# GLOBAL VARS #########################

cfg = require('./config.default').cfg

# ROLLUP PLUGINS ######################

rollLive = (opts = {}) =>
  name: 'rolling-live'
  transform: (code, id) ->
    if extname(id) != '.ls' then return null
    out = livescript.compile code, opts
    #
    console.log "out: #{out}"
    console.log typeof out
    #
    code: out

# COMMON FUNS #########################

timeDiff = (gen_file, src_file) ->
  getTime = (path) ->
    try
      (await fse.stat path).mtimeMs
    catch
      0
  gen_time = await getTime gen_file
  src_time = await getTime src_file
  gen_time > src_time

doExec = (in_files, out_file, selected) ->
  try
    rendered = switch selected
      when 'pug', 'icon' then pug.renderFile in_files[0], cfg
      when 'sass'
        style = if cfg.envRelease then 'compressed' else 'expanded'
        (sass.compile in_files, {style}).css
    fse.writeFileSync out_file, rendered
    traceExec selected
  catch e
    console.error "doExec '#{selected}' => Something went wrong!!!!\n\n\n#{e}"

traceExec = (name) ->
  stmp = new Date().toLocaleString()
  console.log "#{stmp} => #{name} compilation done"

runExec = (selected, cb) ->
  [in_files, out_file] = switch selected
    when 'pug' then [cfg.web.html.src, cfg.web.html.out]
    when 'icon' then [cfg.icon.src, cfg.icon.out]
    when 'sass' then [cfg.web.sass.src, cfg.web.sass.out]
  doExec in_files, out_file, selected
  if cfg.watching then watchExec in_files, out_file, selected
  cb null, 11

watchExec = (to_watch, out_file, selected) ->
  watcher = chokidar.watch to_watch
  watcher.on 'change', => doExec(to_watch, out_file, selected)
  watcher.on 'error', (err) => console.log "CHOKIDAR ERROR:\n#{err}"

# ACTION FUNS #########################

checkEnv = (options) ->
  cfgpath = './config.coffee'
  try
    fse.accessSync cfgpath
    cfgov = require(cfgpath).cfg
    cfg[key] = value for key, value of cfgov
  cfg.envRelease = if options.release? then true else false
  cfg.watching = false
  cfg.dest = cfg.dest_path[if cfg.envRelease then 'release' else 'debug']
  if options.publish then cfg.dest = cfg.dest_path.github
  outUpdate = (path) ->
    curr = if path.length is 0 then cfg else
      tmp = cfg
      tmp = tmp[p] for p in path
      tmp
    for own key, value of curr
      if typeof curr[key] is 'object' and not Array.isArray curr[key]
        npath = Array.from path
        npath.push key
        outUpdate npath
      else if key is 'out' or key is 'dir' then curr[key] = "#{cfg.dest}/#{curr[key]}"
  outUpdate []
  cfg.force = options.force?

compileJs = (cb) ->
  in_opts = input: cfg.web.live.src, plugins: [rollLive({bare: true})]
  out_opts =
    file: cfg.web.live.out
    format: 'iife'
    plugins: (if cfg.envRelease then [terser()] else [])
  if cfg.watching
    watcher = watch {in_opts..., output: out_opts}
    watcher.on 'event', (event) ->
      if event.code is 'ERROR' then console.log event.error
      else if event.code is 'END' then traceExec 'livescript'
  else
    bundle = await rollup in_opts
    await bundle.write out_opts
    traceExec 'livescript'
  cb null, 0

compilePug = (cb) -> runExec 'pug', cb

compileSass = (cb) -> runExec 'sass', cb

createDir = (cb) ->
  try
    await fse.mkdirs "./#{cfg.dest}/#{cfg.static}"
    await fse.copy "./#{cfg.static}", "./#{cfg.dest}/#{cfg.static}"
    cb null, 0
  catch e
    if e.code = 'EEXIST'
      if not cfg.envRelease
        console.warn 'Warning: \'dist\' already exists'
      cb null, 1
    else cb e, null

launchServer = ->
  console.log 'launching server...'
  app = connect()
  app.use(serveStatic "./#{cfg.dest}")
  http.createServer(app).listen 5000
  console.log 'dev server launched'

building = bach.series createDir, compileSass, compilePug, compileJs

# TASKS ###############################

task 'build', 'build the app (core + static + wasm)', (options) ->
  checkEnv options
  console.log 'building...'
  building (e, _) ->
    if e?
      console.log 'Something went wrong'
      console.log e
    else console.log 'building => done'

task_cleandesc =
  "rm ./#{cfg.dest_path.debug} or ./#{cfg.dest_path.release} (debug or release)"
task 'clean', task_cleandesc, (options) ->
  checkEnv options
  console.log "cleaning `#{cfg.dest}`..."
  fse.remove "./#{cfg.dest}", (e) ->
    if e? then console.log e
    else console.log "`#{cfg.dest}` removed successfully"

task 'github', 'populate `docs` dir for github page', (options) ->
  checkEnv {release: true, publish: true}
  fse.remove "./#{cfg.dest}", (e) ->
    if e? then console.log e
    else
      building (e, _) ->
        if e? then console.log e
        else console.log 'publishing DONE'

task 'serve', 'launch a micro server and watch files', (options) ->
  checkEnv options
  if cfg.envRelease
    console.error 'Impossible to use `serve` in `release` mode!'
  else
    cfg.watching = true
    serving = bach.series createDir,
      (bach.parallel compileSass, compilePug, compileJs, launchServer)
    serving (e, _) -> if e? then console.log e

