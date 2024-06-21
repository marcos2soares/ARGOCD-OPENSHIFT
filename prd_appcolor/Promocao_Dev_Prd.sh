#!/bin/bash

# Carrega Variaveis sensiveis
. ./.env 
AMBIENTE=prd

# Função para exibir texto em vermelho
function red_text {
    echo -e "\033[31m$1\033[0m"
}

# Função para exibir texto em verde
function green_text {
    echo -e "\033[32m$1\033[0m"
}

# Função para exibir texto em azul
function blue_text {
    echo -e "\033[34m$1\033[0m"
}

# Função para exibir texto em amarelo
function yellow_text {
    echo -e "\033[33m$1\033[0m"
}


oc login -u vt121170 -p $SENHAOC   > /dev/null 2>&1

echo ""
green_text "LISTANDO AS IMAGENS NO IMAGESTREAM da APLICACAO appcolor de DEV"
echo ""


oc get is appcolor -n appcolor -o json | jq -r '.metadata.name as $name | .status.tags[].tag | "\($name):\(.)"'


echo  ""
oc logout  > /dev/null 2>&1


# Pergunta ao usuário qual é a versão da aplicação
yellow_text "Insira a versão da aplicação que vai ser promovida  para o AMBIENTE: ${AMBIENTE}  -  Aplicação: appcolor ( Ex: v1.0, v2.0 ): \c"
read VERSAO

# Exibe a versão inserida pelo usuário
green_text "A versão da aplicação que será Promovida  é: $VERSAO"

red_text  "Confirma Versão $VERSAO ? (S/N): \c"
read CONFIRMA

[ "$CONFIRMA" != "S" ] &&  red_text "GERAÇÃO CANCELADA" && exit 0


echo ""
green_text "CRIANDO NAMESPACE appcolor-${AMBIENTE} SE NECESSARIO"
echo ""


oc login -u vt121170 -p $SENHAOC   > /dev/null 2>&1

oc apply -f namespace-appcolor-prd.yaml

echo ""
green_text "CRIANDO IMAGESTREAM  appcolor-${AMBIENTE} - AMBIENTE: ${AMBIENTE}  SE NECESSARIO"
echo ""

oc apply -f imagestream-appcolor-prd.yaml



oc logout  > /dev/null 2>&1

