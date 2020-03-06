class squid::lightsquid {
#	package {'perl-CGI':
#		ensure			=> installed,
#	} ->
	file {'/var/www/lightsquid':
#		require			=> Package['httpd','perl-CGI'],
		require			=> Package['httpd'],
		ensure			=> directory,
		mode			=> '0755',
		source			=> 'puppet:///modules/squid/lightsquid',
		recurse			=> true
	} ->
	cron {'lightsquid report generator':
		command			=> '/var/www/lightsquid/lightparser.pl',
		user			=> root,
		minute			=> '*/7'
	} ->
	apache::vhost { 'lightsquid.html':
		port			=> '3181',
		servername		=> "${::fqdn}",
		docroot			=> '/var/www/lightsquid',
		directories		=> [{
			path=> '/var/www/lightsquid',
			addhandlers		=> [{
				handler			=>	'cgi-script',
				extensions		=> ['.cgi']
			}],
			options			=>  ['+ExecCGI'],
		},],
		docroot_owner	=> 'apache',
		docroot_group	=> 'apache',
		override		=>  ['All'],
		directoryindex  => 'index.cgi',
	}
}

