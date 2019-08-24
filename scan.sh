#!/bin/bash
# Antivirus - ClamAV
# Versao do script: 1.1

function update(){
	service clamav-freshclam stop
	sleep 1
	echo " Serviço clamav-freshclam parado... [OK]"
	echo " Atualizando base de dados."
	freshclam
	sleep 1
	service clamav-freshclam start
	echo " Serviço clamav-freshclam iniciado... [OK]"
}

case $1 in
--log | -l)
	echo
	tail /var/log/clamav/clamav.log
;;

--log-update | L)
	echo
	tail /var/log/clamav/freshclam.log -n 7
;;

--manual-download | -m)
	echo "Iniciando donwload do PDF de Documentacao do antivirus..."
	sleep 3
	wget -c https://github.com/vrtadmin/clamav-faq/raw/master/manual/clamdoc.pdf > /dev/null
;;

--help | -h)
	echo
	echo " Syntax de uso:"
	echo "$(basename "$0") [ Diretorio alvo ]"
	echo
	echo "   --log                -l              Exibe o log do Clamav"
	echo "   --log-update         -L              Historico de atualizacao da base de dados"
	echo "   --manual-download    -m              Baixa o Manual do Clamav diretamente do github"
	echo "   --help               -h              Mostra esta tela de ajuda"
	echo "   --version            -v              Versao do Anti-Virus"
	echo "   --update             -u              Atualiza base de dados (ROOT necessario)"
	echo "   --remove             -r              Apaga arquivos infectados ou suspeitos"
	echo
	echo
	echo "Site: https://www.clamav.net/"
	echo "Documentacao: https://www.clamav.net/documents/installing-clamav"
	echo "Criador do script: Clayton Pereira"
	echo "Contato: Email claytonp_13@hotmail.com - Telegram @Claytonpx13 (https://telegram.me/Claytonpx13)"
;;

--version | -v)
	echo "Versao: $(clamscan --version)"
;;

--update | -u)
	[[ $(id -u) != "0" ]] && {
		echo -e "É preciso permissao de administrador para instalar o ClamAV"
		echo -e "Pressione <ENTER> para finalizar o script"
		read -r
		exit 1
	}

	update
;;

--remove | -r)
	if command -v clamscan &> /dev/null;then
		clamscan --bell -r --remove "$2"
		exit 0
	else
		echo "Antivirus não encontrado em seu computador."
		echo "Quer instalar o clamav em sua maquina? (S/N)"
		read -r instalar
		if [[ $(echo "$instalar" | tr '[:lower:]' '[:upper:]') == "S" ]];then
			[[ $(id -u) != "0" ]] && {
				echo -e "É preciso permissao de administrador para instalar o ClamAV"
				echo -e "Pressione <ENTER> para finalizar o script"
				read -r
				exit 1
			}
			apt install -y clamav clamav-daemon libclamav7
			sleep 1
			echo "Instalacao concluida."
			exit 0
		elif [[ $(echo "$instalar" | tr '[:lower:]' '[:upper:]') == "N" ]];then
			echo "Instalacao abortada!"
			exit 0
		else
			echo "ERRO: valores validos, (S/N)"
			exit 1
		fi
	fi
;;

*)
	if command -v clamscan &> /dev/null;then
		clamscan --bell -r "$1"
		exit 0
	else
		echo "Antivirus não encontrado em seu computador."
		echo "Quer instalar o clamav em sua maquina? (S/N)"
		read -r instalar
		if [[ $(echo "$instalar" | tr '[:lower:]' '[:upper:]') == "S" ]];then
			[[ $(id -u) != "0" ]] && {
				echo -e "É preciso permissao de administrador para instalar o ClamAV"
				echo -e "Pressione <ENTER> para finalizar o script"
				read -r
				exit 1
			}
			apt install -y clamav clamav-daemon libclamav7
			sleep 1
			echo "Instalacao concluida."
			exit 0
		elif [[ $(echo "$instalar" | tr '[:lower:]' '[:upper:]') == "N" ]];then
			echo "Instalacao abortada!"
			exit 0
		else
			echo "ERRO: valores validos, (S/N)"
			exit 1
		fi
	fi
;;
esac
