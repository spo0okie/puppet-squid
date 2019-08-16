class squid {
	include repos::squid
	package {['squid', 'squid-helpers']:
	 	ensure => installed
	} ->
	file {'/etc/squid/squid.conf':
		ensure	=> file,
		mode	=> '0640',
		owner	=> 'squid',
		source	=> 'puppet:///modules/squid/squid.conf',
	} ->
	file {'/etc/squid/squidCA.pem':
		ensure	=> file,
		mode	=> '0640',
		owner	=> 'squid',
		source	=> 'puppet:///modules/squid/squidCA.pem',
	} ->
	file {'/etc/squid/url-list':
		ensure	=> directory,
		mode	=> '0755',
		source	=> 'puppet:///modules/squid/url-list',
		recurse	=> true
	} ->
	exec {'init squid cert storage': 
		command => '/usr/lib64/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB',
		unless	=> 'test -d /var/lib/ssl_db',
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}->
	service {'squid':
		ensure	=> running
	}
	mc_conf::hotlist {
		'/etc/squid': ;
	}
}

