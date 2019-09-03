#!/bin/bash
# Moeda
# Mostra o valor atual das moedas mais importantes.

# Os valores são retirados do site http://dolarhoje.com
# no qual merece todo o crédito das informações.

# A cotação do dólar é atualizada de 10 em 10 minutos. Não há mudança no
# valor nos finais de semana.

# Moedas:
# Dólar (Americano, Australiano e Canadense), Euro, Ouro, Bitcoin,
# Libra, Litecoin, Iene e Peso (Argentino, Chileno e Uruguaio).

# O valor do ouro é mostrado em grama (g).
# Para mais informações passe o parâmetro --help ou -h

# Autor: Clayton Pereira
# Contato:    http://telegram.me/Claytonpx13
#             claytonp_13@hotmail.com
# versão 1.6 - Março de 2016.

ERRO(){ # Esta função é chamada quando o parâmetro não é passado corretamente.
	echo
	echo -e "\033[32m Erro de sintax. \033[m"
	echo "-----------------------------------"
	echo " Parâmetro inválido."
	echo " Esta função não reconhece o parâmetros digitado. certifique-se "
	echo "de que digitou corretamente e tente de novo."
	echo
	echo " Consulte a ajuda para mais informações usando o parâmetro:"
	echo "  -h ou --help"
	echo "-----------------------------------"
}

ajuda(){ # Esta função é chamada quando o parâmetro -h ou --help é encontrado.
	echo
	echo -n " SINTAX: $(basename "$0") [PARÂMETRO]"
	echo
	echo "Requisitos: lynx instalado."
	echo
	echo
	echo " Os parâmetros são:"
	echo
	echo -e "\033[32m <Dólar> \033[m"
	echo " -d  --dolar             : Mostra o valor do Dólar Americano."
	echo " -da --dolar-australiano : Mostra o valor do Dólar Australiano."
	echo " -dc --dolar-canadense   : Mostra o valor do Dólar Canadense."
	echo
	echo -e "\033[32m <Peso> \033[m"
	echo " -p  --peso              : Mostra o valor do Peso Argentino."
	echo " -pc --peso-chileno      : Mostra o valor do Peso Chileno."
	echo " -pu --peso-uruguaio     : Mostra o valor do Peso Uruguaio."
	echo
	echo -e "\033[32m <Outras moedas> \033[m"
	echo " -e  --euro              : Mostra o valor do Euro."
	echo " -i  --iene              : Mostra o valor do Iene."
	echo " -l  --libra             : Mostra o valor da Libra."
	echo " -o  --ouro              : Mostra o valor do Ouro."
	echo
	echo -e "\033[32m <Moedas digitais> \033[m"
	echo " -b  --bitcoin           : Mostra o valor do Bitcoin."
	echo " -L  --litecoin          : Mostra o valor do Litecoin."
	echo
	echo -e "\033[32m <Sobre> \033[m"
	echo " -a  --ajuda             : Mostra esta tela de ajuda."
	echo " -c  --contato           : Contato do criador do programa."
	echo " -h  --help              : Mostra esta tela de ajuda."
	echo " -v  --vesao             : Mostra a versão deste programa."
	echo "     --version           : Mostra a versão deste programa."
	echo
	echo " Este programa não funciona sem um parâmetro."
	echo

	uname -snmo   # Versão do seu sistema operacional.
}

versao(){ # Esta função é chamada quando o parâmetro -v ou --version é encontrado.
	echo
	echo -n "$(basename " $0")"
	echo
	echo " Mostra o valor atual das moedas mais importantes."
	echo
	echo " Versão 1.6 - Março de 2016."
	echo
}

if ! [[ "$1" ]];then # Verifica se não existe um parâmetro para o programa.
	# Se não encontrar um parâmetro este bloco é execultado.
	echo " Você não passou um parâmetro para o programa."
	echo -e " Para mais informações digite\033[32m $(basename "$0") -a\033[m ou\033[32m $(basename "$0") --ajuda\033[m"
fi

if ! [[ $(command -v lynx) ]];then
	echo " ERRO: Requisito nao satisfeito!"
	echo "O lynx nao foi encontrado no seu sistema!"
	echo "Instale o lynx para que este escript funcione corretamente"
	echo 
	echo " Pressione <ENTER> para sair"
	read -r
	exit 1
fi

# Tratamento das opções de linha de comando.
while [[ -n "$1" ]]
do
 case $1 in  # Este case trata o parâmetro passado e retorna o comando equivalente ao parâmetro.
 	--ajuda | -a)
 		ajuda;;

 	--bitcoin | -b)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/bitcoin | grep '฿' | tr -d '_'
 		echo -e "Bitcoin \033[m"
	;;

 	--contato | -c)
		echo
		echo -e "Autor \033[32m Clayton Pereira \033[m"
		echo
		echo "Contato: "
		echo -e "         Telegram : \033[32m http://telegram.me/Claytonpx13 \033[m"
		echo -e "         Email    : \033[32m claytonp_13@hotmail.com \033[m"
	;;

 	--dolar | -d)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com | grep 'US$ 1,00' | tr -d '_'
 		echo -e "Dólar - Americano \033[m"
	;;

 	--dolar-australiano | -da)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/australiano/ | grep 'A$ 1' | tr -d '_'
 		echo -e "Dólar - Australiano \033[m"
	;;

 	--dolar-canadense | -dc)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/canadense/ | grep 'C$ 1' | tr -d '_'
 		echo -e "Dólar - Canadense \033[m"
	;;

 	--euro | -e)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/euro | grep '€ 1' | tr -d '_'
 		echo -e "Euro \033[m"
	;;

 	--help | -h)
 		ajuda
	;;

 	--iene | -i)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/iene | grep '¥' | tr -d '_'
 		echo -e "Iene \033[m"
	;;

 	--libra | -l)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/libra | grep '£' | tr -d '_'
 		echo -e "Libra \033[m"
	;;

 	--litecoin | -L)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/litecoin | grep 'Ł 1' | tr -d '_'
 		echo -e "Litecoin \033[m"
	;;

 	--ouro | -o)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/ouro | grep 'g 1' | tr -d '_'
 		echo -e "Ouro \033[m"
	;;

 	--peso | --pa | -p)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/peso-argentino/ | grep '$ 1' | tr -d '_'
 		echo -e "Peso - Argentino \033[m"
	;;

 	--peso-chileno | -pc)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/peso-chileno/ | grep 'R$ 1' | tr -d '_'
 		echo -e "Peso - Chileno \033[m"
	;;

 	--peso-uruguaio | -pu)
 		echo -e "\033[32m"
 		lynx -dump -nolist http://dolarhoje.com/peso-uruguaio/ | grep '$ 1' | tr -d '_'
 		echo -e "Peso - Uruguaio \033[m"
	;;

 	--version | --versao | --versão | -v)
 		versao
	;;

 	*)
 		ERRO
	;;
 esac

 # Opção $1 já processada a fila deve andar.
 shift # Faz a variável $1 sair da fila, e transporta o valor da variável $2 para $1 e assim por diante.

done
