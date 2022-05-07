#Просто ставим сквид из пакетов
class squid::install {
	package {'squid':ensure => 'latest'}
}