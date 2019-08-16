define squid::iptables(
	$if	= 'eth0',		#по умолчанию интерфейс eth0
) {
	file {'/etc/init.d/squid.iptables':
		ensure		=> file,
		mode		=> '0777',
		content		=> "#!/bin/sh
		/sbin/iptables -t nat -A PREROUTING -i $if -p tcp --dport 80 -j DNAT --to $title:3129
		/sbin/iptables -t nat -A PREROUTING -i $if -p tcp --dport 443 -j DNAT --to $title:3130
		",
	} ->
	exec {'run DNAT for Squid':
		command		=> '/etc/init.d/squid.iptables',
		unless		=> "iptables11 -nL -t nat | grep 'to:$title:3130'",
		path		=> '/bin:/sbin:/usr/bin:/usr/sbin'
	}
}

