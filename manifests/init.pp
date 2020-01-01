class squid {
	include squid::install5
	include squid::conf
	mc_conf::hotlist {
		'/etc/squid': ;
	}
}