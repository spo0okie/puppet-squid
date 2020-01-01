class squid::sqstat {
	file {'/var/www/sqstat':
		require		=> Package['httpd'],
		ensure		=> directory,
		mode		=> '0755',
		source		=> 'puppet:///modules/squid/sqstat',
		recurse		=> true
	} ->
	apache::vhost { 'sqstat.html':
		port			=> '3180',
		servername		=> "${::fqdn}",
		docroot			=> '/var/www/sqstat',
		docroot_owner	=> 'apache',
		docroot_group	=> 'apache',
		docroot_mode	=> '0770',
		override		=>  ['All'],
		directoryindex  => 'index.php',
	}
}

