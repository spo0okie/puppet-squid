class squid {
	include repos::squid
	package {['squid', 'squid-helpers']:
	 	ensure => installed
	} ->
	file {'/etc/squid/squid.conf':
		ensure	=> file,
		mode	=> '0755',
		source	=> 'puppet:///modules/squid/squid.conf',
	} ->
	file {'/etc/squid/squidCA.pem':
		ensure	=> file,
		mode	=> '0755',
		source	=> 'puppet:///modules/squid/squidCA.pem',
	} ->
	file {'/etc/squid/url-list':
		ensure	=> directory,
		mode	=> '0755',
		source	=> 'puppet:///modules/squid/url-list',
		recurse	=> true
	} ->
	service {
		'squid':	ensure => running
	}
	mc_conf::hotlist {
		'/etc/squid': ;
	}
}

