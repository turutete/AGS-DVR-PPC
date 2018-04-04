import os
import sys

# Selecciona directorio build en funcion de la plataforma
def SelectBuildDir(build_dir, platform=None): 
    # if no platform is specified, then default to sys.platform 
    if not(platform): 
        platform = sys.platform

    print "Looking for build directory for platform '%s'" % platform 
    # setup where we start looking at first 
    test_dir = build_dir + os.sep + platform 
    default_dir = build_dir + os.sep + 'default' 
    # we look for a directory named exactly after the 
    # platform so that very specific builds can be done 
    if os.path.exists(test_dir): 
        # make sure it is a directory 
        target_dir = test_dir 
    else: 
        print "Exact match not found, finding closest guess" 
        
        # looks like there isn't an exact match 
        # find the closest matching directory 
        dirs = os.listdir(build_dir) 
        found_match = 0 
        for dir in dirs: 
            if platform.find(dir) != -1: 
                # found a match (hopefully the right one) 
                target_dir = build_dir + os.sep + dir 
                found_match = 1 
                break 
        if not(found_match): 
            print "No match found, looking for 'default' directory" 
            # looks like this platform isn't available 
            # try the default target 
            if os.path.exists(default_dir): 
                target_dir = default_dir 
            else: 
                # bad, nothing is available, tell the user 
                print "No build directories found for your platform '%s'" % platform 
                return None 
    print "Found directory %s, will build there" % target_dir 
    return target_dir

### funciones usadas por el Builder para manejar .gob ###
def gob_action( target, source, env ):
    target_dir  = os.path.dirname( str(target[0]) )
    source_dir  = os.path.dirname( str(source[0]) )
    source_file =  str(source[0])
    
    cwd = os.getcwd()
    source_file = cwd + os.sep + source_file

    #print('cwd='+cwd+' target_dir='+target_dir+' source_file='+source_file)
    
    os.chdir( target_dir )
    #os.chdir( source_dir ) # los ficheros generados van en el mismo directorio de fuentes
    gob_cmd="gob2 --no-gnu --no-self-alias --no-private-header "
    if(sys.platform=="win32"):
        gob_cmd+=" --no-lines "
    r=os.system( gob_cmd + source_file )
    os.chdir( cwd )
    return r

def gob_emitter(target, source, env):
    base = stripext(str(target[0]))
    #base = stripext(str(source[0])) # ficheros generados en directorio de fuentes
    return([base+'.c', base+'.h'], source)
    #return(target, source)

### funciones usadas por el Builder para manejar .lh ###
def lh_action( target, source, env ):
    target_dir  = os.path.dirname( str(target[0]) )
    target_file = str(target[0])
    module_name = os.path.basename( stripext(target_file) )
    source_dir  = os.path.dirname( str(source[0]) )
    source_file = str(source[0])
    
    cwd = os.getcwd()
    source_file = cwd + os.sep + source_file
    target_file = cwd + os.sep + target_file

    os.chdir( target_dir )
    os.system( "tolua -n "+module_name+" -o "+target_file+" "+source_file )
    os.chdir( cwd )

### utilidades ###

def strip_action( target, source, env ):
    target_file = str(target[0])
    os.system( "strip " + target_file )

def slibs_action( target, source, env ):
    if(env.has_key('SLIBS')):
        env.Replace(_SLIBFLAGS="${_stripixes(LIBLINKPREFIX, SLIBS, LIBLINKSUFFIX, LIBPREFIX, LIBSUFFIX, __env__)}")
        env.Replace(_LIBFLAGS="-Wl,--whole-archive -Bstatic $_SLIBFLAGS -Bdynamic -Wl,--no-whole-archive "+env['_LIBFLAGS'])

# XXX
def get_dirname ( all_modules, name ):
    for k,v in all_modules.iteritems():
        mods=v['modules']
        for modname,mod in mods.iteritems():
            if modname==name:
                return k
# XXX
def collect_list( all_modules, k, list ):
    s=''
    d=get_dirname(all_modules, k)
    if not d:
        print(k,d)
    prefix='#src/'+d
    m=all_modules[d]['modules'][k]
    if(m.has_key(list)):
        s=setpath(m[list], prefix)
        if(m.has_key('slibs')):
            for slib in m['slibs']:
                s+=collect_list( all_modules, slib, list )
    return s

# elimina la extension de un nombre de fichero
def stripext(fn):
    if fn.rfind(".") != -1:
        return fn[:fn.rfind(".")]
    return fn

def setpath(filenames, prefix):
    new_filenames = []
    for x in filenames:
        new_filenames.append(os.path.join(prefix, x))
    return new_filenames

def getbyext(filenames, extensions):
    new_filenames = []
    for x in filenames:
        if os.path.splitext(x)[1] in extensions:
            new_filenames.append(x)
    return(new_filenames)

class MemoizeFunction:
    hashfunc = hash
    def __init__(self, function):
        self.function = function
        self.memo = {}
    def __call__(self, *args):
        h = self.hashfunc(args)
        if h not in self.memo:            
            self.memo[h] = self.function(*args)
        return self.memo[h]

def digraph(all_modules, profile):
    d='digraph "'+profile+'" {'
    for k,v in all_modules.iteritems():
        for k2,v2 in v['modules'].iteritems():
            l=''

            # definimos nodo
            l+='"'+k2+'"'
            if(v2.has_key('do_static') and v2['do_static']):
                l+=' [ shape=box,color=red ] '
            if(v2.has_key('do_shared') and v2['do_shared']):
                l+=' [ shape=ellipse ] '
            if(v2.has_key('do_bin') and v2['do_bin']):
                l+=' [ shape=trapezium,color=blue ] '
            l+=' ;\n'
            d+=l

            l=''
            if(v2.has_key('libs')):
                l+='edge [style=solid,color=green];\n'
                l+='"'+k2+'"'
                l+=' -> {'
                for k3 in v2['libs']:
                    l+=' '+k3+' '
                l+='}'
            #        l+=' [fontname="Courier"] '

            if(v2.has_key('slibs')):
                l+='edge [style=dashed,color=red];\n'
                l+='"'+k2+'"'
                l+=' -> {'
                for k3 in v2['slibs']:
                    l+=' '+k3+' '
                l+='}'
            if(l):
                l+=';'
            d+=l
    d+='}'
    return d

def print_config(msg, two_dee_iterable):
    # this function is handy and can be used for other configuration-printing tasks
    print
    print msg
    print
    for key, val in two_dee_iterable:
        print "    %-20s %s" % (key, val)
    print

def config_h_build(target, source, env):
    for a_target, a_source in zip(target, source):
        print_config("Generating "+str(a_target)+" with the following settings:",
                     env['defines'].items())

        config_h = file(str(a_target), "w")
        config_h_in = file(str(a_source), "r")
        config_h.write(config_h_in.read() % env['defines'])
        config_h_in.close()
        config_h.close()

def escape_backslash(s):
	return '\\\\'.join( s.split('\\') )

def concat(target, source, env):
    srcs=''
    for s in source:
        srcs=srcs + ' ' + str(s)
        os.system("cat "+srcs+" > "+str(target[0]))
