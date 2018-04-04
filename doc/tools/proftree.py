import os
import sys 

sys.path.append("profiles")

# Opciones
profile=sys.argv[1]

# carga profile
p=__import__(profile)
for name in dir(p):
    if not globals().has_key(name):
        globals()[name]=getattr(p,name)


def digraph(profile):
    print 'digraph "'+profile+'" {'
    print ' compound=true ;'
    for k,v in all_modules.iteritems():
        subgraph='subgraph "cluster'+k+'" {\n'
        subgraph+=' label="'+k+'" rank=max ;\n'
        subgraph+=' fontname="courier" ;\n'
        for k2,v2 in v['modules'].iteritems():
            l=''

            # definimos nodo
            if(v2.has_key('do_static') and v2['do_static']):
                l+=' [ shape=box,color=red,style=dotted ] '
            if(v2.has_key('do_sstatic') and v2['do_sstatic']):
                l+=' [ shape=box,color=red,style=dotted ] '
            if(v2.has_key('do_bin') and v2['do_bin']):
                l+=' [ shape=trapezium,color=blue ] '
            if(v2.has_key('do_mod') and v2['do_mod']):
                l+=' [ shape=hexagon,color=burlywood ] '
            if(v2.has_key('do_shared') and v2['do_shared']):
                l+=' [ shape=ellipse ] '
            if(l==''):
                continue
            subgraph+='"'+k2+'"'+l+' ;\n'

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
            print(l)
        subgraph+='}'
        print(subgraph)
    print '}'

digraph(profile)
