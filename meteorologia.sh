#!/bin/bash
# Meteorologia
#
# Mostra a previsão do tempo para a cidade escolhida.
# Requer conexão com a internet.

# Sintax:
#        para exibir clima:  meteorologia nome_cidade
#        para exibir ajuda:  meteoroligia help

# Creditos ao site wttr.in na qual sem ele este script é inútil.

# Autor: Clayton Pereira
# Contato: http://telegram.me/Claytonpx13
#          claytonp_13@hotmail.com

# Versão: 1.0
# Versão: 1.1
#             - Removido créditos do autor do site no final da visualização do programa.
#             - Não diferencia mais as letras minusculas das maiusculas no parâmetro passado.
# Versão: 1.2
#             - Correção de Tradução do Inglês (do site) para o Português (do programa).

param=$(echo "$1" | tr A-Z a-z)

if [ "$param" = "--help" ];then
	echo "Uso:"
	echo
	echo "    $ meteorologia          # Local atual"
	echo "    $ meteorologia muc      # Tempo no aeroporto de Munique"
	echo
	echo "Tipos de localização suportados:"
	echo
	echo "    paris                  # Nome da Cidade"
	echo "    muc                    # Código aeroporto (3 letras)"
	echo "    @stackoverflow.com     # Nome de dominio"
	echo "    94107                  # Código de área"
	echo
	echo "Locais especiais:"
	echo
	echo "    moon                   # Fase da lua (adicionar, +US ou +France para estas cidades)"
	echo
	echo "Unidades:"
	echo
	echo "    ?m                      # Métrico (SI) (usado por padrão em todos os lugares exceto EUA)"
	echo "    ?u                      # USCS (usado por padrão no USA)"
	echo
	echo "Parâmetro Especial:"
	echo
	echo "    help                  # Mostra esta página"

	exit 0
fi

curl -4 wttr.in/$param | grep -v "^Check" | grep -v "^Follow" > /tmp/wttr.txt
clear
cat /tmp/wttr.txt
