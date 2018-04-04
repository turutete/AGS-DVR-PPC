import os
import sys 

sys.path.append("profiles")

# carga support
from support import *

# Opciones
opts = Options()
opts.AddOptions(
    ('profile', 'Perfil de compilacion a emplear.', 'test-mod'),
    ('debug',   'Nivel de depuracion', 0),
    ('prefix',  'Directorio prefijo.', ''),
    ('destdir', 'Directorio destino.', ''),
    ('ccache',  'Activar ccache.', False),
    ('gprof',   'Activar profiling.', False),
    )

### Inicializacion environment
# XXX "SConf"
env = Environment(options=opts, ENV=os.environ)
env.Append(CPPPATH=[ '#' ])
Help(opts.GenerateHelpText(env))

# carga profile
p=__import__(env['profile'])
for name in dir(p):
    if not globals().has_key(name):
        globals()[name]=getattr(p,name)
f(env)

Import('*')

# directorio build
target_dir = '#' + SelectBuildDir(build_base_dir) + '/' + env['profile']
# directorio install (prefix)
if env['prefix']:
    install_dir = env['prefix']
else:
    install_dir = Dir(install_base_dir + '/' + env['profile']).abspath + '/'
# directorio destino por prioridad: 1) opcion destdir 2) variable de entorno DESTDIR 3) directorio de SConstruct
if env['destdir']:
    dest_dir = Dir(env['destdir']).abspath + '/'
else:
    if os.environ.has_key('DESTDIR') and os.environ['DESTDIR']:
        dest_dir = Dir(os.environ['DESTDIR']).abspath + '/'
    else:
        dest_dir = ''

##
# debug:
#    0 : Ni 'debug information' ni 'debug messages'.
#    1 : 'debug information' sin 'debug messages'.
#   >1 : 'debug information' y 'debug messages'
if env['debug']:
    env.Append(CCFLAGS='-g')
    env.Append(CCFLAGS='-DAGS_DEBUG='+env['debug'])
    target_dir = target_dir + 'dbg'
    install_dir = install_dir + '/' + 'dbg'

if env['ccache']:
    env.Replace(CC='ccache '+env['CC'])
    env.Append(CCACHE_DIR=target_dir+'/.ccache')

if env['gprof']:
    env.Append(CCFLAGS='-pg')
    env.Append(LINKFLAGS='-pg')
    env.Append(CCFLAGS='-fprofile-arcs')
if sys.platform == "win32":
    env.Append(CCFLAGS='-mms-bitfields')
    #env.Append(LINKFLAGS='-Wl,-no-keep-memory')
    #env.Append(LINKFLAGS='-Wl,--enable-runtime-pseudo-reloc')
    #env.Append(LINKFLAGS='-Wl,--warn-unresolved-symbols')
    env.Append(CPPPATH='C:\\msys\\1.0\\local\\include') # XXX
    env.Append(LIBPATH='C:\\msys\\1.0\\local\\lib') # XXX
    f=os.popen('pkg-config --variable=prefix gtk+-2.0', 'r')
    s=f.read()
    f.close()        
    env.Append(CCFLAGS='-I'+os.path.join(s.strip( ),'include'))

# Constructor para generar fuentes C mediante GOB
gob_bld = Builder(action = gob_action,
                  suffix = '.c',
                  src_suffix = '.gob',
                  emitter = gob_emitter)
env.Append(BUILDERS = {'Gob' : gob_bld})

lh_bld = Builder(action = lh_action,
                 suffix = '.c',
                 src_suffix = '.lh')
env.Append(BUILDERS = {'Lh' : lh_bld})

# Command para generar documentacion de los fuentes (doxygen)
env.Command('.doc', '', "doxygen doc/tools/doxygen.conf")
Alias('doc', '.doc')

# Recogida de basura
env.Command('.trash','',
            'mkdir -p trash;find . -name "*~" -exec "mv" "{}" "trash" \;')
Alias('trash', '.trash')

# Strip
env.Command('.strip','',
            'find '+Dir(dest_dir + install_dir).abspath+' -type f -perm +111 -exec "strip" "{}" \;')
Alias('strip', '.strip')

# Compilar Lua
env.Command('.luac','',
            'find '+Dir(dest_dir + install_dir).abspath+" -type f '(' -name '*.lua' -or -name '*.lxml' ')' -exec luac -s -o '{}' '{}' \;")
Alias('luac', '.luac')

### Build
# Variables a exportar a los SConscripts
Export('env', 'all_modules', 'all_data', 'target_dir', 'install_dir', 'dest_dir', 'strip_action', 'slibs_action', 'collect_list', 'concat' )

# SConscripts
SConscript('src/SConscript')
defines=SConscript('data/SConscript')

# Lista de directorios fuente
source_dirs=[]
for k,v in all_modules.iteritems():
    source_dirs = source_dirs + [ '#src/'+k ]

# Alias
Alias('generate', source_dirs)
Alias('compile', target_dir)
Alias('build', ['generate', 'compile'])
Alias('install', [ 'build', dest_dir + install_dir ] )
if(not env['debug']):
    Alias('install', 'strip')
    #Alias('install', 'luac')

# PATH para el cargador de modulos
mod_path=''
for p in env['RPATH']:
    mod_path = mod_path + p + os.pathsep
defines['AGS_MOD_PATH'] = mod_path

all_paths=''
for k,v in defines.iteritems():
    # escapamos '\' en win32
    if sys.platform == "win32":
        defines[k]=escape_backslash(v)
    all_paths += defines[k] + os.pathsep

defines['AGS_ALL_PATHS'] = all_paths
defines['AGS_MOD_PREFIX']  = (globals().has_key('mod_prefix')  and mod_prefix)  or ''
defines['AGS_LMOD_PREFIX'] = (globals().has_key('lmod_prefix') and lmod_prefix) or ''

env.Command('config.h', 'config.h.in', config_h_build, defines=defines)
env.Command('data/config/config.lua', 'data/config/config.lua.in', config_h_build, defines=defines)
env.AlwaysBuild('config.h')
env.AlwaysBuild('data/config/config.lua')

# Target por defecto
Default('build')

# Almacena todas las "firmas" de fichero (.sconsign) en un mismo fichero en
# el directorio "top-level". Esto evita generar .sconsign en cada directorio.
SConsignFile()
