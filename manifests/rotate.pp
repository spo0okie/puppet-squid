class squid::rotate {
	cron {'logfile rotate':
		command			=> '/var/www/lightsquid/lightparser.pl && /sbin/squid -k rotate',
		user			=> root,
		hour			=> '2',
		minute			=> '0',
	} 
}

