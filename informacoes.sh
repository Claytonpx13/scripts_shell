#!/bin/bash 
#### Script para coletar informacoes da maquina

# Autor: Clayton Pereira 
# Contato:    Email      claytonp_13@hotmail.com 
#             Telegram   @Claytonpx13 ou https://telegram.me/Claytonpx13
# Data da criacao 28/10/2016

HARDWARE(){
	# Coleta info de memoria
	MEM=$(cat /proc/meminfo | grep MemTotal: | sed 's/MemTotal:       //' | sed 's/ kB//' | sed 's/.*/echo "& \/ 1024" | bc/' | bash | sed 's/.*/& MB/')
	MEM="$(echo ${MEM})"

	# Coleta info processador - quantidade
	NPROC="$(cat /proc/cpuinfo | grep -i processor | wc -l)"
	NPROC="$(echo ${NPROC})"

	# Coleta info processador - modelo
	PROC="$(cat /proc/cpuinfo | grep "\model name" | tail -1 | cut -d\: -f2-)"
	PROC="$(echo ${PROC})"

	# Coleta info discos
	DISK=$(fdisk -l | grep Disk | egrep -v "identifier" | cut -d ' ' -f2-4 | cut -d ',' -f1)
	echo
	echo -e '\033[32;1m ==== Informacoes hardware ==== \033[m'
	
cat << EOT
Memoria ............: ${MEM}
Processador ........: [ ${NPROC} ] ${PROC}
Disco(s) ...........: $DISK
EOT

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
	for i in $NIC;do
		IP=$(ifconfig $i | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | tail -3 | head -1)
		BCAST=$(ifconfig $i | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | tail -2 | head -1)
		MASK=$(ifconfig $i | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | tail -1 | head -1)
		REDE=$(ip ro | egrep "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[1-3]{1,2}.*$i.*$IP" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2}")
		MAC_ADDR=$(ifconfig | grep HWaddr | cut -d' ' -f9)
		ip ro | grep -o "default equalize" > /dev/null

		if [ $? -eq 0 ];then
			GW=$(ip ro | egrep  ".*nexthop.*$i" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")
		else
			GW=$(ip ro | egrep  ".*default.*$i" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")   
		fi

		if [ $IP != $IP ];then
			echo "Interface: $i"
			echo "Endereco IP .......: -----"
			echo
		else
			echo "Interface .........: $i"
			echo "Endereco IP .......: $IP"
			echo "Endereco Fisico ...: $MAC_ADDR"
			echo "Broadcast .........: $BCAST"
			echo "Mascara:...........: $MASK"
			echo "Rede ..............: $REDE"
			echo "Gateway ...........: $GW"
			echo
		fi
	done

	DNS=$(awk '/nameserver/ {print $2}' /etc/resolv.conf | tr -s '\n' ' ')
	echo -e "DNS Servers........: $DNS"
	echo
}

KERNEL(){
	echo -e '\033[32;1m ==== Informacoes do Kernel ==== \033[m'
	echo "Kernel-name .......: $(uname -s -o)"
	echo "Kernel-release ....: $(uname -r)"
	echo "Kernel-version ....: $(uname -v)"
	echo
}

SISTEMA(){
	echo -e '\033[32;1m ==== Informacoes do Sistema ==== \033[m'
	DISTRIB_DESCRIPTION=$(cat /etc/*-release | grep PRETTY_NAME | cut -d'"' -f2)
	HOME_URL=$(cat /etc/*-release | grep HOME_URL | cut -d'"' -f2)
	SUPPORT_URL=$(cat /etc/*-release | grep SUPPORT_URL | cut -d'"' -f2)

	echo "Nome da maquina ...: $(hostname)"
	echo "Nome do SO ........: $DISTRIB_DESCRIPTION"
	echo "Site Oficial ......: $HOME_URL"
	echo "URL para suporte ..: $SUPPORT_URL"
	echo
}

SERVICOS(){
	echo -e '\033[32;1m ==== Informacoes do(s) Servico(s) ==== \033[m'
	echo "Ainda em construcao..."
	echo
}

AJUDA(){
	echo -e '\033[32;1m  ==== Tela de Ajuda ==== \033[m'
	echo " Este script foi criado para colotar e imprimir na tela"
	echo "as informacoes mais importantes do sistema operacional como"
	echo "tambem informacoes de hardware."
	echo
	echo " Este script nao funciona sem um parametro!"
	echo "USE: $(basename $0) <<PARAMETRO>>"
	echo
	echo -e '\033[32;1m PARAMETROS \033[m'
	echo -e "  \033[37;1m-a\033[m ou \033[37;1m--all\033[m"
	echo "    Para exibir todas as informacoes, os dados seram mostradas na seguinte ordem:"
	echo "      Campos Hardware... Sistema... Kernel... Rede... Servicos."
	echo
	echo -e "  \033[37;1m-H\033[m ou \033[37;1m--hardware\033[m"
	echo "    Exibe informacoes do seu Hardware."
	echo "      Quantidade de memoria RAM (MB)"
	echo "      Quantidade de memoria SWAP (MB)"
	echo "      Processador, quantidade de nucleos e modelo"
	echo "      Disco(s) caminho e tamanho do(s) disco(s)"
	echo
	echo -e "  \033[37;1m-h\033[m ou \033[37;1m--help\033[m"
	echo "    Mostra esta tela de ajuda."
	echo
	echo -e "  \033[37;1m-k\033[m ou \033[37;1m--kernel\033[m"
	echo
	echo -e "  \033[37;1m-r\033[m ou \033[37;1m--rede\033[m"
	echo
	echo -e "  \033[37;1m-S\033[m ou \033[37;1m--services\033[m"
	echo
	echo -e "  \033[37;1m-s\033[m ou \033[37;1m--system\033[m"
}

if [ $(id -u) != "0" ];then
	echo
	echo -e "O usuário atual não é o ROOT, execute o comando [sudo -i]<ENTER> depois digite sua senha"
	echo -e "Pressione <ENTER> para finalizar o script"
	read
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

	-S | --services)
		SERVICOS
	;;

	-a | --all)
		HARDWARE
		SISTEMA
		KERNEL
		REDE
		SERVICOS
	;;

	-h | --help)
		#AJUDA
		echo "  Lamento..."
		echo " Parametro ainda em construcao :("
	;;

	*)
		echo "Passe um parametro valido, pois nao sou adivinho!"
		echo " Esperimente usar o -h ou --help para receber ajuda"
		echo
		exit 1
	;;
esac

echo
exit 0
