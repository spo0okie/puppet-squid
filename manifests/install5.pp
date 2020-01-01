#устанавливает 5й сквид с сорцов
class squid::install5 {
	$tmpdir='/tmp/squid_inst'
	$srcdir="$tmpdir/squid"

	#сносим все что стоит из пакетов
	package {'squid-helpers':ensure => 'absent'} ->
	package {'squid':ensure => 'absent'} ->

	#создаем рабочие папки и скачиваем сорцы
	file {$tmpdir: ensure=>directory} ->
	file {$srcdir: ensure=>directory} ->
	file {"$tmpdir/squid-5.0.0.tar.gz": source=>'puppet:///modules/squid/squid-5.0.0.tar.gz'}

	#распаковываем
	exec {'squid5_extract':
		command	=> "tar -zxvf ./squid-5.0.0.tar.gz",
		cwd		=> $tmpdir,
		unless	=> "test -f $srcdir/INSTALL",
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
	} ->

	#собираем
	exec {'squid5_build_libtoolize':
		command => 'libtoolize --force',
		require => Package['libtool-ltdl-devel','autoconf','automake'],
		unless	=> "test -e $srcdir/cfgaux/ltmain.sh",
		cwd		=> $srcdir,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
		
	} ->
	exec {'squid5_build_aclocal':
		command => 'aclocal',
		require => Package['libtool-ltdl-devel','autoconf','automake'],
		cwd		=> $srcdir,
		unless	=> "test -e $srcdir/aclocal.m4",
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
	} ->
	exec {'squid5_build_autoheader':
		command => 'autoheader',
		require => Package['libtool-ltdl-devel','autoconf','automake'],
		unless	=> "test -e $srcdir/include/autoconf.h.in",
		cwd		=> $srcdir,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
	} ->
	exec {'squid5_build_automake':
		command => 'automake --add-missing',
		require => Package['libtool-ltdl-devel','autoconf','automake'],
		cwd		=> $srcdir,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
		unless	=> "test -e $srcdir/Makefile.in",
	} ->
	exec {'squid5_build_autoconf':
		command => 'autoconf',
		require => Package['libtool-ltdl-devel','autoconf','automake'],
		cwd		=> $srcdir,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
		unless	=> "test -e $srcdir/configure",
	} ->
	exec {'squid5_build_configure':
		command => "$srcdir/configure --enable-ssl --enable-ssl-crtd --with-openssl --prefix= --exec-prefix=/usr --sysconfdir=/etc/squid --enable-delay-pools",
		cwd		=> $srcdir,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
		unless	=> "test -e $srcdir/Makefile",
	} ->
	exec {'squid5_build_make_install':
		command => 'make install',
		timeout	=> 3000,	#сборка быстро не делается
		cwd		=> $srcdir,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
		unless	=> "test -e /usr/sbin/squid",
	} ->
	file {'/etc/systemd/system/squid.service': source=>'puppet:///modules/squid/squid.service'}
}
