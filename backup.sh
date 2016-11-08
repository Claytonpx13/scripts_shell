#!/bin/bash
# backup - Gerenciador de Backups

#  Este programa tem a funcionalidade de facilitar o uso do comando 7z,
# tornando-o mais intuitivo, trazendo as principais funções para você gerenciar
# seus Backup's de forma rapida e eficaz!

#  Este programa cria, restaura e exclui backups do sistema.
#  Digite o nome do programa para ver o menu de opções ou digite o parâmetro
# --help para ver uma tela de ajuda para parâmetros diretos na linha de comando.

# Requisitos: 7-Zip e dialog

# Autor: Clayton Pereira
# Contato:    http://telegram.me/Claytonpx13
#             claytonp_13@hotmail.com
# Versão: 0.6 - Setembro de 2016.

if [ $(id -u) != "0" ];then
	echo -e "O usuário atual não é o ROOT, execute o comando [sudo -i]<ENTER> depois digite sua senha"
	echo -e "Pressione <ENTER> para finalizar o script"
	read
	exit 1
fi

if [ "$1" = "--help" ];then
  echo -e "\033[32m Este Script está ainda em desenvolvimento e o parâmetro"
  echo -e "  --help ainda não foi implementado. \033[m"
  exit 0
fi

# Menu Principal
menu(){
	item=$(dialog --stdout \
		--title "Gerenciador de Backups" \
		--menu "Selecione uma opção: " 0 0 0 \
		1 Criar \
		2 Restaurar \
		3 Excluir \
		4 creditos \
		5 Sair )
	clear

	if [ $item ];then # Aqui é processado a escolha do menu.
		case $item in # Invoca a funcao segundo a escolha do usuario
			1) # Cria um backup de pasta ou arquivo selecionado pelo usuário
				criar
			;;

			2) # Restaura um backup
				restaurar
			;;

			3) # Exclui um backup
				excluir
			;;

			4)
				creditos
			;;

			5) # Fecha este programa
				sair
			;;
		esac
	else
		echo "Fim do programa."
	fi
}

criar(){
	criar=$(dialog --stdout \
	--title "Criar Backup de..." \
	--menu "Selecione uma opção: " 0 0 0 \
		1 "/boot" \
		2 "/etc" \
		3 "/home" \
		4 "/opt" \
		5 "/root" \
		6 "/var" \
		7 "Caminho personalizado")
	clear

	if [ $criar ];then
		case $criar in
			1)
				echo "Criando backup de /boot."
				echo "Aguarde..."
				7z  a -t7z -m0=LZMA -mmt=2 -mx9 -md=128m -mfb=273 -ms=on -p{4yj764ka} "/backup/boot-$(hostname)-$(date +%Y-%m-%d)" "/boot/*"
				echo "/boot" > /backup/.log/boot-$(hostname)-$(date +%Y-%m-%d).7z.log
				echo "Backup $(ls /backup/boot-$(hostname)-$(date +%Y-%m-%d).7z) concluido."
				sleep 2
			;;

			2)
				echo "Criando backup de /etc."
				echo "Aguarde..."
				7z  a -t7z -m0=LZMA -mmt=2 -mx9 -md=128m -mfb=273 -ms=on -p{4yj764ka} "/backup/etc-$(hostname)-$(date +%Y-%m-%d)" "/etc/*"
				echo "/etc" > /backup/.log/etc-$(hostname)-$(date +%Y-%m-%d).7z.log
				echo "Backup $(ls /backup/etc-$(hostname)-$(date +%Y-%m-%d).7z) concluido."
				sleep 2
			;;

			3)
				echo "Criando backup de /home."
				echo "Aguarde..."
				7z  a -t7z -m0=LZMA -mmt=2 -mx9 -md=128m -mfb=273 -ms=on -p{4yj764ka} "/backup/home-$(hostname)-$(date +%Y-%m-%d)" "/home/*"
				echo "/home" > /backup/.log/home-$(hostname)-$(date +%Y-%m-%d).7z.log
				echo "Backup $(ls /backup/home-$(hostname)-$(date +%Y-%m-%d).7z) concluido."
				sleep 2
			;;

			4)
				echo "Criando backup de /opt."
				echo "Aguarde..."
				7z  a -t7z -m0=LZMA -mmt=2 -mx9 -md=128m -mfb=273 -ms=on -p{4yj764ka} "/backup/opt-$(hostname)-$(date +%Y-%m-%d)" "/opt/*"
				echo "/opt" > /backup/.log/opt-$(hostname)-$(date +%Y-%m-%d).7z.log
				echo "Backup $(ls /backup/opt-$(hostname)-$(date +%Y-%m-%d).7z) concluido."
				sleep 2
			;;

			5)
				echo "Criando backup de /root."
				echo "Aguarde..."
				7z  a -t7z -m0=LZMA -mmt=2 -mx9 -md=128m -mfb=273 -ms=on -p{4yj764ka} "/backup/root-$(hostname)-$(date +%Y-%m-%d)" "/root/*"
				echo "/root" > /backup/.log/root-$(hostname)-$(date +%Y-%m-%d).7z.log
				echo "Backup $(ls /backup/root-$(hostname)-$(date +%Y-%m-%d).7z) concluido."
				sleep 2
			;;

			6)
				echo "Criando backup de /var."
				echo "Aguarde..."
				7z  a -t7z -m0=LZMA -mmt=2 -mx9 -md=128m -mfb=273 -ms=on -p{4yj764ka} "/backup/var-$(hostname)-$(date +%Y-%m-%d)" "/var/*"
				echo "/var" > /backup/.log/var-$(hostname)-$(date +%Y-%m-%d).7z.log
				echo "Backup $(ls /backup/var-$(hostname)-$(date +%Y-%m-%d).7z) concluido."
				sleep 2
			;;

			7)
				caminho=$(dialog --stdout --inputbox "Digite o caminho completo para backup:" 0 0)

				if [ $caminho ];then
					echo "Criando backup de $caminho."
					echo "Aguarde..."
					7z  a -t7z -m0=LZMA -mmt=2 -mx9 -md=128m -mfb=273 -ms=on -p{4yj764ka} "/backup/personalizado-$(basename $caminho)-$(hostname)-$(date +%Y-%m-%d)" "$caminho/*"
					echo "$caminho" > /backup/.log/personalizado-$(basename $caminho)-$(hostname)-$(date +%Y-%m-%d).7z.log
					echo "Backup $(ls /backup/personalizado-$(basename $caminho)-$(hostname)-$(date +%Y-%m-%d).7z) concluido."
					sleep 2
				else
					criar
				fi 
			;;
		esac
	else
		menu
	fi
}

restaurar(){
	ls /backup/ > /tmp/listback.log
	restaurar=$(dialog --stdout \
	--title ' Restaurar Backup: ' \
	--radiolist 'Selecione uma opção: '  \
	0 0 0 \
	$(cat /tmp/listback.log | sed 's/.*/& \\ OFF/'))
	clear

	if [ $restaurar ];then
		caminho="/backup/.log/$restaurar.log"
		echo "$caminho"
		echo "$restaurar"
		7z x "/backup/$restaurar" -o"$(cat $caminho)" -p{4yj764ka}
	else
		menu
	fi
}

excluir(){
	ls /backup/ > /tmp/listback.log
	bkp=$(dialog --stdout \
	--title ' Excluir Backup: ' \
	--radiolist 'Selecione uma opção: '  \
	0 0 0 \
	$(cat /tmp/listback.log | sed 's/.*/& \\ OFF/'))
	clear

	if [ $bkp ];then
		caminho="/backup/.log/$bkp.log"
		arq="/backup/$bkp"
		rm -f "$caminho"
		rm -f "$arq"
		rm -f /tmp/listback.log
		echo "Backup $bkp excluido..."
		sleep 2
	else
		menu
	fi
}

creditos(){
  # Em construcao
  echo
	#dialog \
   #--title ' Creditos ' \
   #--textbox /caminho/msg.txt \
   #0 0

  sleep 2
   menu
}

sair(){
	clear
	exit 0
}

menu

