class squid {
	#с 4 декабря 2019 основной репозиторий недоступен. используем копию
	include repos::squid_mirror
	package {['squid', 'squid-helpers']:
	 	ensure => "4.2-1.el${::operatingsystemmajrelease}"
		
	} ->
	file {'/etc/squid/squid.conf':
		ensure	=> file,
		mode	=> '0640',
		owner	=> 'squid',
		source	=> 'puppet:///modules/squid/squid.conf',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/pools.conf':
		ensure	=> file,
		mode	=> '0640',
		owner	=> 'squid',
		source	=> 'puppet:///modules/squid/pools.conf',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/squidCA.pem':
		ensure	=> file,
		mode	=> '0640',
		owner	=> 'squid',
		source	=> 'puppet:///modules/squid/squidCA.pem',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/url-list':
		ensure	=> directory,
		mode	=> '0755',
		source	=> 'puppet:///modules/squid/url-list',
		recurse	=> true,
		notify	=> Service['squid'],
	} ->
	exec {'init squid cert storage': 
		command => '/usr/lib64/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB',
		unless	=> 'test -d /var/lib/ssl_db',
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}->
	exec {'init squid swap storage': 
		command => 'squid -z',
		unless	=> 'test -d /var/spool/squid/00',
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}->
	service {'squid':
		ensure	=> running,
		enable	=> true
	}
	mc_conf::hotlist {
		'/etc/squid': ;
	}
}

