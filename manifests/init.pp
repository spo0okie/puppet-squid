class squid {
	include squid::install
	#include squid::conf
	mc_conf::hotlist {
		'/etc/squid': ;
	}
}