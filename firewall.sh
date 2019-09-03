#!/bin/bash
# Firewall - Regras de firewall com iptables

#  Este Script tem como funcao facilitar o uso da ferramenta iptables, assim como mostrar
# relatorios sobre o mesmo (caso a funcao seja ativada).
#  Para ativar ou desativar a funcao de LOG basta digitar na linha de comando
# [ /etc/init.d/firewall --log-enable ] ou [ /etc/init.d/firewall --log-disable ]
#  As outras funcoes do script podem ser ativadas ou desativadas apenas comentando (#) ou
# descomentando as linhas referentes no campo [ start) .... ;; ] do "case $1 in...."
#
#  Crie um atalho deste script na pasta de runlevel padrao de seu sistema para que o
# firewall inicie juntamente com o sistema, perpetuando assim as regras definidas
# Para mais informacoes use o parametro help (...firewall help)

# Autor: Clayton Pereira
# Contato:     Email     claytonp_13@hotmail.com
#              Telegram  @Claytonpx13 ( https://telegram.me/Claytonpx13 )

# Data da criacao: 02/10/2016
# Data da ultima atualizacao: 25/10/2016
#versao 0.3

### Campo de variaveis ####################
ipt=$(command -v iptables)      # Recebe o caminho do executavel iptables
eth0="enp0s3"                   # Interface de rede externa (conexao com a internet)
eth1="enp0s8"                   # Interface de rede interna
rede="192.168.1.0/24"           # IP's da rede interna
portas_altas="1024:65535"       # Portas Cliente
portas_trojans="1234 1524 2583 3024 4092 5742 5556 5557 6000 6001 6002 6711 8787 12345 12346 16660 27444 27665 31335 31336 31337 31338 33270 60001"
### Fim do Campo de variaveis #############


### Funcoes do Firewall ###################
STATEFULL(){
	## Regras StateFull genericas
	$ipt -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	$ipt -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
}

Loopback(){ # Acessar sua propria placa logica
	$ipt -A INPUT -i lo -j ACCEPT
}

SYN_FLOOD(){
	# Previnir syn flood
	# Esta regra limita reserva de recurso da maquina para evidar o esgotamento dos recursos
	$ipt -N SynFlood
	$ipt -A SynFlood -m limit --limit 10/second --limit-burst 5 -j RETURN
	$ipt -A SynFlood -j DROP

	$ipt -A INPUT -p tcp --syn -j SynFlood
}

PACOTES_INVALIDOS(){
	$ipt -A INPUT -m state --state INVALID -j LOG --log-prefix "INVALIDO " --log-ip-options --log-tcp-options --log-tcp-sequence --log-level 4

	## Descomente a linha abaixo caso sua politica padrao seja ACCEPT para a CHAIN INPUT
	#$ipt -A INPUT -m state --state INVALID -j DROP
}

BLOQUEIO_PORTAS_TROJAN(){
	$ipt -t filter -N PortasTrojan

	# Verificando cada porta suspeita
	for PORTA in ${portas_trojans};do
		$ipt -A PortasTrojan -p tcp --sport $portas_altas --dport "${PORTA}" -j LOG --log-prefix "FIREWALL:Trojan tcp p:${PORTA}"
		$ipt -A PortasTrojan -p tcp --sport $portas_altas --dport "${PORTA}" -j REJECT
		$ipt -A PortasTrojan -p udp --sport $portas_altas --dport "${PORTA}" -j LOG --log-prefix "FIREWALL:Trojan udp p:${PORTA}"
		$ipt -A PortasTrojan -p udp --sport $portas_altas --dport "${PORTA}" -j REJECT
	done

	# Redireciona para outra CHAIN as portas_trojans
	$ipt -A INPUT -i $eth0 -j PortasTrojan
}

ICMP(){
	## Pacotes icmp especiais
	$ipt -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
	$ipt -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
	$ipt -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
}


PING(){
	$ipt -A OUTPUT -m limit --limit 6/minute --limit-burst 4 -p icmp --icmp-type echo-request -j ACCEPT
	$ipt -A INPUT -p icmp --icmp-type echo-request -s $rede -j ACCEPT
}

SSH(){ 
	## Permite o servico ssh para a rede,
	## Troque a variavel $rede por um IP de uma maquina caso queira restringir o acesso 
	## para somente ela!

	## Regras ssh - Cliente
	$ipt -A OUTPUT -p tcp -s $rede --sport $portas_altas --dport 22 -j ACCEPT

	## Regras ssh - Servidor
	#$ipt -A INPUT -m state --state NEW -p tcp -s $gateway --sport 22 -d $rede --dport $portas_altas -j ACCEPT
}

WEB(){
	# Os servicos HTTP e HTTPS permitem a conexao com a internet
	$ipt -A OUTPUT -p tcp --sport $portas_altas --dport 80 -j ACCEPT
	$ipt -A OUTPUT -p tcp --sport $portas_altas --dport 443 -j ACCEPT
}

FTP(){
	# Libera a porta 21 para o serviço FTP
	$ipt -A OUTPUT -p tcp --sport $portas_altas --dport 21 -j ACCEPT
}

DNS(){
	# O servico DNS permite a traducao de nomes
	$ipt -A OUTPUT -p udp --sport $portas_altas --dport 53 -j ACCEPT
}

ROTEAMENTO(){
	ip_forward=$(cat /proc/sys/net/ipv4/ip_forward)
	if [[ $ip_forward -eq 0 ]];then
		echo "1" > /proc/sys/net/ipv4/ip_forward
	fi

	$ipt -t nat -A POSTROUTING -o $eth1 -j MASQUERADE # Compartilhando Internet com eth1
	#$ipt -t nat -A POSTROUTING -o $eth2 -j MASQUERADE # Compartilhando Internet com eth2
}

REJEITAR(){
	## Rejeita imediatamente os pedidos nao liberados acima
	## Pedidos de protocolo UDP
	$ipt -A INPUT -p udp -m state --state NEW -j REJECT --reject-with icmp-port-unreachable

	## Pedidos de protocolo TCP
	$ipt -A INPUT -p tcp -m state --state NEW -j REJECT --reject-with tcp-reset


	## Aplica uma regra DROP no final de cada CHAIN
	## Use caso tenha optado por deixar as politicas ACCEPT
	#$ipt -A INPUT -s $all -d $all -j DROP
	#$ipt -A FORWARD -s $all -d $all -j DROP
	#$ipt -A OUTPUT -s $all -d $all -j DROP
}
### Fim do Campo de Funcoes ###############

if [[ $(id -u) != "0" ]];then
	echo -e "O usuário atual não é o ROOT, execute o comando [sudo -i]<ENTER> depois digite sua senha"
	echo -e "Pressione <ENTER> para finalizar o script"
	read -r
	exit 1
fi

### Processar parametros ##################
case $1 in
	start) ### Inicia as Regras do Firewall (iptables)
		## Definindo politicas padrao da tabela filter para DROP
		## Caso queira alguma politica como ACCEPT comente a linha da mesma, nao a modifique!
		$ipt -P INPUT DROP
		$ipt -P FORWARD DROP
		$ipt -P OUTPUT DROP

		## Abaixo estao todas as funcoes do firewall
		## descomente as linhas das funcoes que queira ativar
    		STATEFULL        # Recomendado manter ativo esta funcao!
    		#Loopback
    		#SYN_FLOOD
   		#PACOTES_INVALIDOS
    		#BLOQUEIO_PORTAS_TROJAN
   		#ICMP
   		PING
    		#SSH
   		WEB
    		#FTP
   		DNS
   		ROTEAMENTO
   		#REJEITAR
	;;

	stop) ### Finaliza todas as regras existentes
		## Redefinindo regras padrao das chains
		$ipt -P INPUT ACCEPT
		$ipt -P FORWARD ACCEPT
		$ipt -P OUTPUT ACCEPT

		## Apaga regras da tabela filter
		$ipt -F
		$ipt -X SynFlood
		$ipt -X PortasTrojan

		## Apaga regras da tabela nat
		$ipt -t nat -F
	;;

	restart) ### Reinicia as regras (use sempre que fizer alguma alteracao)
		$0 stop
		sleep 2
		$0 start
	;;

	help | --help | -h) ### Exibe tela de ajuda
		echo "Ainda em construcao!"
	;;

	--regras) ### Lista as regras atuais do Firewall
		echo "#--------------------#"
		echo "# RESUMO DAS REGRAS  #"
		echo "#--------------------#"
		echo

		$ipt -nL --line-number
		echo
		$ipt -t nat -nL --line-number
	;;

	*) ### Toda vez que um parametro incorreto é passado, este bloco é executado!
		clear
		echo "Erro, use $0 [start | stop | restart | help ]"
		exit 1
	;;
esac
### Fim do Campo Processo de parametros ###
exit 0
