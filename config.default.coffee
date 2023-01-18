webpath = 'web'

exports.cfg =
  dest_path:
    debug: 'dist'
    release: 'out'
    github: 'docs'
  web:
    html:
      src: ("#{webpath}/#{file}" for file in ['index.pug'])
      out: 'index.html'
    path: webpath
    sass:
      src: "#{webpath}/style.sass"
      out: 'style.css'
    live:
      src: "#{webpath}/app.ls"
      out: 'app.js'
