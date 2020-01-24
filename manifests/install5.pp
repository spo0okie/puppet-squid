#устанавливает 5й сквид с сорцов
#сорцы взяты отсюда: https://github.com/measurement-factory/squid
#потомучто здесь [http://lists.squid-cache.org/pipermail/squid-users/2018-July/018636.html] люди пришли
#к выводу, что в ванильном сквиде сломана одновременная работа ssl-bump splice и delay_pool
#по сути фикс конкретно этой проблемы тут: https://github.com/measurement-factory/squid/commit/0f50bc82bae29a30f4dae79dad5426055178e231
#можно попробовать сделать патч на ванильный сквид. но это не оч быстро.
class squid::install5 {
	#папка в которой будем работать
	$tmpdir='/tmp/squid_inst'
	#куда распакуем сорцы
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

	#собственно только теперь мы наконец собираем и сразу ставим
	exec {'squid5_build_make_install':
		command => "make install || rm -rf $tmpdir",	#или у нас все круто собирается и инсталлируется или мы все удаляем, чтобы попробовать с чистого листа
		#command => "make install",	#ну это план Б для отладки, если мы хотим разбираться что конкретно там не собирается
		timeout	=> 3000,	#сборка быстро не делается
		cwd		=> $srcdir,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
		unless	=> "test -e /usr/sbin/squid",
	} ->

	#добавляем юнитфайл для systemd
	file {'/etc/systemd/system/squid.service': source=>'puppet:///modules/squid/squid.service'}

	#если по юнитфайлу есть изменения - говорим systemd перечитать его
	exec {'squid_unitfile_reload':
		command		=> 'systemctl daemon-reload',
		subscribe	=> File['/etc/systemd/system/squid.service'],
		refreshonly	=> true,
		path	=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
	}

}
