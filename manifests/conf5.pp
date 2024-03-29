class squid::conf5 {
	include common::usr
	#$owner="${::common::usr::nobody}:${::common::usr::nogroup}"
	$owner=$::common::usr::nobody
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
		mode	=> '0775',
		owner	=> $owner,
		source	=> 'puppet:///modules/squid/url-list',
		recurse	=> true,
		notify	=> Service['squid'],
	} ->
	file {['/var/spool/squid','/var/log/squid','/var/lib/ssl_db']:
		ensure	=> directory,
		mode	=> '0775',
		notify	=> Service['squid'],
	} ->
	exec {'init squid cert storage': 
		command => '/usr/libexec/security_file_certgen -c -s /var/lib/ssl_db -M 4MB',
		unless	=> 'test -f /var/lib/ssl_db/index.txt',
		path	=> '/bin:/sbin:/usr/bin:/usr/sbin',
	}->
	exec {'squld logs chown':
		command	=> "chown -R ${common::usr::nobody}:${common::usr::nogroup} /var/log/squid",
		require	=> File['/var/log/squid'],
		unless	=> "ls -ld /var/log/squid/ |grep '${common::usr::nobody} ${common::usr::nogroup}'",
		path	=> '/bin:/sbin:/usr/bin:/usr/sbin',
	} ->
	exec {'squld ssl_db chown':
		command	=> "chown -R ${common::usr::nobody}:${common::usr::nogroup} /var/lib/ssl_db",
		require	=> File['/var/lib/ssl_db'],
		unless	=> "ls -ld /var/lib/ssl_db |grep '${common::usr::nobody} ${common::usr::nogroup}'",
		path	=> '/bin:/sbin:/usr/bin:/usr/sbin',
	} ->
	exec {'squld spool chown':
		command	=> "chown -R ${common::usr::nobody}:${common::usr::nogroup} /var/spool/squid",
		require	=> File['/var/spool/squid'],
		unless	=> "ls -ld /var/spool/squid/ |grep '${common::usr::nobody} ${common::usr::nogroup}'",
		path	=> '/bin:/sbin:/usr/bin:/usr/sbin',
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