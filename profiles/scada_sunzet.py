build_base_dir   = 'build'
install_base_dir = 'install'
lmod_prefix      = 'lualib-'

all_modules = {
	'ui':		{
		'target_dir':		'/ui/',
		'lib_install_dir':	'/lib/',
		'mod_install_dir':	'/lib/ags/',
		'modules':	{
			'textbufferif': {
				'name':         'textbufferif',
				'do_sstatic':   True,
				'sources_fn':   [ 'textbufferif.c' ],
				'pc':           [ 'pkg-config --libs --cflags gobject-2.0' ],
			}
		},
	},
	
	'cm':		{
		'target_dir':		'/cm/',
		'lib_install_dir':	'/lib/',
		'mod_install_dir':	'/lib/ags/',
		'modules':	{
			'agscm':        {
				'name':         'agscm',
				'do_sstatic':   True,
				'gobs_fn':      [ 'ags-cm.gob' ],
				'sources_fn':   [ 'ags-cm.c', 'interpreterif.c' ],
				'pc':           [ 'pkg-config --libs --cflags gobject-2.0' ],
			},
			'cmscript':     {
				'name':         'cmscript',
				'do_sstatic':   True,
				'gobs_fn':      [ 'cm-script.gob' ],
				'sources_fn':   [ 'cm-script.c' ],
				'pc':           [ 'pkg-config --libs --cflags gobject-2.0' ],
			},
			'cmtextbuffer': {
				'name':         'cmtextbuffer',
				'do_sstatic':   True,
				'gobs_fn':      [ 'cm-textbuffer.gob' ],
				'sources_fn':   [ 'cm-textbuffer.c' ],
				'pc':           [ 'pkg-config --libs --cflags gobject-2.0' ],
			},
		},
	},
	'sds':		{
		'target_dir':		'/sds/',
		'lib_install_dir':	'/lib/',
		'mod_install_dir':	'/lib/ags/',
		'modules':	{
			'agssds':	{
				'name':		'agssds',
				'do_sstatic':	True,
				'gobs_fn':	[ 'ags-sds.gob' ],
				'sources_fn':	[ 'ags-sds.c', 'accessif.c' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0' ],
			},
			'agstype':	{
				'name':		'agstype',
				'do_sstatic':	True,
				'sources_fn':	[ 'ags-type.c', 'ags-valuetypes.c', 'ags-paramspecs.c', 'ags-valuetransform.c' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0' ],
			},
			'agssdsx':	{
				'name':		'agssdsx',
				'do_sstatic':	True,
				'gobs_fn':	[ 'ags-sdsx.gob' ],
				'sources_fn':	[ 'ags-sdsx.c', 'accessxif.c' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'net-snmp-config --libs --cflags' ],
			},
			'snmpcommon':	{
				'name':		'snmpcommon',
				'do_sstatic':	True,
				'sources_fn':	[ 'snmp-gvalue.c' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'net-snmp-config --libs --cflags' ],
			},
			'sdsxsnmp':		{
				'name':		'sdsxsnmp',
				'do_sstatic':	True,
				'gobs_fn':	[ 'sdsx-snmp.gob' ],
				'sources_fn':	[ 'sdsx-snmp.c' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'net-snmp-config --libs --cflags' ],
			},
			'agstype':      {
				'name':         'agstype',
				'do_sstatic':   True,
				'sources_fn':   [ 'ags-type.c', 'ags-valuetypes.c', 'ags-paramspecs.c', 'ags-valuetransform.c' ],
				'pc':           [ 'pkg-config --libs --cflags gobject-2.0' ],
			},
		},
	},
	'cf':		{
		'target_dir':		'/cf/',
		'lib_install_dir':	'/lib/',
		'mod_install_dir':	'/lib/ags/',
		'bin_install_dir':	'/bin/',
		'modules':	{
			'agscf':	{
				'name':		'agscf',
				'do_sstatic':	True,
				'gobs_fn':	[ 'ags-cf.gob' ],
				'sources_fn':	[ 'ags-cf.c', 'configif.c', 'lua-gvalue.c' ],				
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0' ],
			},
			'cflua':	{
				'name':		'cflua',
				'do_mod':	True,
				'gobs_fn':	[ 'cf-lua.gob' ],
				'sources_fn':	[ 'cf-lua.c', ],
				'libs':		[ 'scada_sunzetbase', ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'pkg-config --libs --cflags gmodule-2.0', 'pkg-config --cflags --libs lua' ],
			},
		},
	},
	'lualib':	{
		'target_dir':		'/lualib/',
		'lib_install_dir':	'/lib/',
		'mod_install_dir':	'/lib/lua/',
		'bin_install_dir':	'/bin/',
		'mod_prefix':		lmod_prefix,
		'modules':	{
			'config':	{
				'name':		'config',
				'do_mod':	True,
				'sources_fn':	[ 'lconfig.c' ],
				'libs':		[ 'scada_sunzetbase' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'pkg-config --libs --cflags lua' ],
			},
			'gobject':	{
				'name':		'gobject',
				'do_mod':	True,
				'sources_fn':	[ 'lgobject.c' ],
				'libs':		[ 'scada_sunzetbase' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'pkg-config --libs --cflags lua' ],
			},
			'access':	{
				'name':		'access',
				'do_mod':	True,
				'sources_fn':	[ 'laccess.c' ],
				'libs':		[ 'scada_sunzetbase' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'pkg-config --libs --cflags lua' ],
			},
			'accessx':	{
				'name':		'accessx',
				'do_mod':	True,
				'sources_fn':	[ 'laccessx.c' ],
				'libs':		[ 'scada_sunzetbase' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'pkg-config --libs --cflags lua' ],
			},
		},
		
	},
	'tests':	{
		'target_dir':		'/tests/',
		'lib_install_dir':	'/lib/',
		'mod_install_dir':	'/lib/ags/',
		'bin_install_dir':	'/bin/',
		'modules':	{
			'scada_sunzetserver': {
				'name':		'scada_sunzetserver',
				'do_mod':	True,
				'slibs':	[ 'cmscript', 'textbufferif', 'cmtextbuffer' ],
				'sources_fn':	[],
				'libs':		[ 'scada_sunzetbase' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', ],
			},
			'scada_sunzetcgi':	{
				'name':		'scada_sunzetcgi',
				'do_mod':	True,
				'slibs':	[ 'agssds', 'agssdsx', 'snmpcommon', 'sdsxsnmp', ],
				'sources_fn':	[],
				'libs':		[ 'scada_sunzetbase' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'net-snmp-config --libs --cflags' ],
			},
			'scada_sunzetbase':	{
				'name':		'scada_sunzetbase',
				'do_shared':	True,
				'slibs':	[ 'agscf', 'agstype', 'agscm', ],
				'sources_fn':	[],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'pkg-config --libs --cflags gmodule-2.0', 'pkg-config --cflags --libs lua' ],
			},
			'scada_sunzet':		{
				'name':		'scada_sunzet',
				'do_bin':	True,
				'sources_fn':	[ 'test-mods.c' ],
				'libs':		[ 'scada_sunzetbase' ],
				'pc':		[ 'pkg-config --libs --cflags gobject-2.0', 'pkg-config --libs --cflags gmodule-2.0' ],
			},
		},
	},
}

all_data = {
	'config':	{
		'config_install_dir':	'/share/config/',
		'data_fn':		[ 'functions.lua', 
					[ 'scada_sunzet-webserver.lua', 'config.lua','setup.lua','scada_sunzet-webserver.lua'], 
					[ 'htdocs/index.lua', 'scada_sunzet-cgi.lua'],
					[ 'htdocs/init.lua', 'config.lua','setup.lua'], ],
	},	
	'pixbufs':	{
		'config_install_dir':	'/share/config/htdocs',
		'data_fn':		['logo-zigor.jpg',],
	},
	'ui':	{
		'config_install_dir':	'/share/ui/',
		'data_fn':		[],
	},
}

def f(env):
	return
