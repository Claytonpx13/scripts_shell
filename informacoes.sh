#!/usr/bin/env bash 
#### Script para coletar informacoes da maquina

# Autor: Clayton Pereira 
# Contato:    Email:      claytonp_13@hotmail.com 
#             Telegram:   @Clayton_Pereira ou https://telegram.me/Clayton_Pereira
# Data da criacao:        28/10/2016
# Ultima atualizacao:     27/07/2023

HARDWARE(){
	# Coleta info de memoria
	MEM=$(grep "MemTotal:" /proc/meminfo | sed 's/MemTotal:       //' | sed 's/ kB//' | sed 's/.*/echo "& \/ 1024" | bc/' | bash | sed 's/.*/& MB/')

	# Coleta info processador - quantidade
	NPROC=$(grep -c "processor" /proc/cpuinfo)

	# Coleta info processador - modelo
	PROC=$(grep "\model name" /proc/cpuinfo | tail -1 | cut -d':' -f2-)

	# Coleta info discos
	DISK=
	echo
	echo -e '\033[32;1m ==== Informacoes hardware ==== \033[m'
	
	echo " Memoria ............: ${MEM}
 Memoria Swap .......: $(grep SwapTotal /proc/meminfo | awk '{print $2}' | sed 's/.*/& KB/')
 Processador ........: [ ${NPROC} ] ${PROC}
 Disco(s) ...........: $DISK
"
}

REDE(){
	# Este trecho foi inspirado no código da comunidade Viva o Linux
	## Referencia:
	# http://www.vivaolinux.com.br/script/Script-simples-para-pegar-informacoes-sobre-placa-de-rede
	#Publicado por Fernando R. Durso

	echo
	echo -e '\033[32;1m ==== Informacoes rede ==== \033[m'

	# Coleta informacoes sobre rede
	NIC=$(ip addr list | grep BROADCAST | awk -F ':' '{print $2}'| tr '\n' ' ')

	# Gateway
	for i in $NIC; do
		IP=$(ifconfig "$i" | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | tail -3 | head -1)
		BCAST=$(ifconfig "$i" | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | tail -2 | head -1)
		MASK=$(ifconfig "$i" | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | tail -1 | head -1)
		REDE=$(ip ro | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[1-3]{1,2}.*$i.*$IP" | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2}")
		MAC_ADDR=$(ifconfig | grep HWaddr | cut -d' ' -f9)

		if ip ro | grep -o "default equalize" > /dev/null; then
			GW=$(ip ro | grep -E ".*nexthop.*$i" | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")
		else
			GW=$(ip ro | grep -E ".*default.*$i" | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")   
		fi

		echo " Interface .........: $i
 Endereco IP .......: $IP
 Endereco Fisico ...: $MAC_ADDR
 Mascara ...........: $BCAST
 Broadcast .........: $MASK
 Rede ..............: $REDE
 Gateway ...........: $GW
"
	done

	DNS=$(awk '/nameserver/ {print $2}' /etc/resolv.conf | tr -s '\n' ' ')
	echo " DNS Servers........: $DNS
"
}

KERNEL(){
	echo -e "\033[32;1m ==== Informacoes do Kernel ==== \033[m
 Kernel-name .......: $(uname -s -o)
 Kernel-release ....: $(uname -r)
 Kernel-version ....: $(uname -v)
"
}

SISTEMA(){
	echo -e '\033[32;1m ==== Informacoes do Sistema ==== \033[m'
	DISTRIB_DESCRIPTION=$(grep PRETTY_NAME /etc/*-release | cut -d'"' -f2)
	HOME_URL=$(grep HOME_URL /etc/*-release | cut -d'"' -f2)
	SUPPORT_URL=$(grep SUPPORT_URL /etc/*-release | cut -d'"' -f2)

	echo " Nome da maquina ...: $(hostname)
 Nome do SO ........: $DISTRIB_DESCRIPTION
 Site Oficial ......: $HOME_URL
 URL para suporte ..: $SUPPORT_URL
"
}

AJUDA(){
	echo -e "\033[32;1m  ==== Tela de Ajuda ==== \033[m
  Este script foi criado para colotar e imprimir na tela
 as informacoes mais importantes do sistema operacional como
 tambem informacoes de hardware.

  Este script nao funciona sem um parametro!
 USE: $(basename "$0") <<PARAMETRO>>

\033[32;1m PARAMETROS \033[m
  \033[37;1m-a\033[m ou \033[37;1m--all\033[m
    Para exibir todas as informacoes, os dados seram mostradas na seguinte ordem:
      Campos Hardware... Sistema... Kernel... Rede... Servicos.

  \033[37;1m-H\033[m ou \033[37;1m--hardware\033[m
    Exibe informacoes do seu Hardware.
      Quantidade de memoria RAM (MB)
      Quantidade de memoria SWAP (MB)
      Processador, quantidade de nucleos e modelo
      Disco(s) caminho e tamanho do(s) disco(s)

  \033[37;1m-h\033[m ou \033[37;1m--help\033[m
    Mostra esta tela de ajuda.

  \033[37;1m-k\033[m ou \033[37;1m--kernel\033[m
    Informacoes do kernel
      name, realease e version.

  \033[37;1m-r\033[m ou \033[37;1m--rede\033[m
     Informacoes de rede
       Endereco de rede
       IP address e mascara de rede
       Gateway padrao e dns
       Broadcast e endereco fisico (MAC ADDRESS)

  \033[37;1m-s\033[m ou \033[37;1m--system\033[m"
}

if [[ $(id -u) != "0" ]];then
	echo
	echo -e " O usuário atual não é o ROOT, execute o comando [sudo -i]<ENTER> depois digite sua senha"

	exit 1
fi

case $1 in
	-r | --rede)
		REDE
	;;

	-H | --hardware)
		HARDWARE
	;;

	-k | --kernel)
		KERNEL
	;;

	-s | --system)
		SISTEMA
	;;

	-a | --all)
		HARDWARE
		SISTEMA
		KERNEL
		REDE
	;;

	-h | --help)
		AJUDA
	;;

	*)
		echo "Passe um parametro valido, pois nao sou adivinho!"
		echo " Esperimente usar o -h ou --help para receber ajuda"
		echo
		exit 1
	;;
esac
