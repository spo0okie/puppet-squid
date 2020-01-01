class squid::conf {
	$owner='nobody'
	file {'/etc/squid/squid.conf':
		require => File['/etc/systemd/system/squid.service'],
		ensure	=> file,
		mode	=> '0640',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/squid.conf',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/pools2.conf':
		ensure	=> file,
		mode	=> '0640',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/pools2.conf',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/mime.conf':
		ensure	=> file,
		mode	=> '0640',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/mime.conf',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/cachemgr.conf':
		ensure	=> file,
		mode	=> '0640',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/cachemgr.conf',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/errorpage.css':
		ensure	=> file,
		mode	=> '0640',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/errorpage.css',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/squidCA.pem':
		ensure	=> file,
		mode	=> '0640',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/squidCA.pem',
		notify	=> Service['squid'],
	} ->
	file {'/etc/squid/url-list':
		ensure	=> directory,
		mode	=> '0755',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/url-list',
		recurse	=> true,
		notify	=> Service['squid'],
	} ->
	exec {'init squid cert storage': 
		command => '/usr/libexec/security_file_certgen -c -s /var/lib/ssl_db -M 4MB',
		unless	=> 'test -d /var/lib/ssl_db',
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}->
	file {'/var/spool/squid':
		ensure	=> directory,
		mode	=> '0755',
		owner	=> $owner,
		notify	=> Service['squid'],
	} ->
	file {'/var/log/squid':
		ensure	=> directory,
		mode	=> '0755',
		owner	=> $owner,
		notify	=> Service['squid'],
	} ->
	file {
		[
			'/var/log/squid/access.log',
			'/var/log/squid/cache.log',
			'/var/log/squid/swap.state'
		]:
		ensure	=> file,
		mode	=> '0644',
		owner	=> $owner,
		notify	=> Service['squid'],
	} ->
	exec {'init squid swap storage': 
		command => 'squid -z > /var/log/squid/init.log 2>&1',
		unless	=> 'test -d /var/spool/squid/00',
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}->
	service {'squid':
		enable	=> true,
		ensure	=> running,
	}
}