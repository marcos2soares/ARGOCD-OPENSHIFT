#!/bin/bash

# Carrega Variaveis sensiveis
. ./.env 
AMBIENTE=dev

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
green_text "LISTANDO AS IMAGENS NO IMAGESTREAM da APLICACAO appcolor"
echo ""


oc get is appcolor -n appcolor -o json | jq -r '.metadata.name as $name | .status.tags[].tag | "\($name):\(.)"'


echo  ""
oc logout  > /dev/null 2>&1


# Pergunta ao usuário qual é a versão da aplicação
yellow_text "Insira a versão da aplicação que vai ser instalada no AMBIENTE: ${AMBIENTE}  -  Aplicação: appcolor ( Ex: v1.0, v2.0 ): \c"
read VERSAO

# Exibe a versão inserida pelo usuário
green_text "A versão da aplicação que será Instalada é: $VERSAO"

red_text  "Confirma Versão $VERSAO ? (S/N): \c"
read CONFIRMA

[ "$CONFIRMA" != "S" ] &&  red_text "GERAÇÃO CANCELADA" && exit 0



mkdir $VERSAO  > /dev/null 2>&1
cp -rp base/* $VERSAO/

DIR=$(pwd)
cd $VERSAO

# PROBLEMA COM SERVICE. NAo pode ter ponto no nome

VERSAO_ALT=$(echo "$VERSAO" | awk '{gsub(/\./, "-"); print}')


sed -e "s/{VERSAO}/${VERSAO}/g" -e "s/{VERSAO_ALT}/${VERSAO_ALT}/g"  appcolor-dev-deploy.yaml  > appcolor-dev-deploy_temp.yaml
sed -e "s/{VERSAO}/${VERSAO}/g" -e "s/{VERSAO_ALT}/${VERSAO_ALT}/g" appcolor-dev-route.yaml  > appcolor-dev-route_temp.yaml
sed -e "s/{VERSAO}/${VERSAO}/g" -e "s/{VERSAO_ALT}/${VERSAO_ALT}/g" appcolor-dev-svc.yaml  > appcolor-dev-svc_temp.yaml

sed -e "s/{VERSAO}/${VERSAO}/g" aplication_appcolor_argocd.yaml >  aplication_appcolor_argocd_temp.yaml

mv aplication_appcolor_argocd_temp.yaml aplication_appcolor_argocd.yaml
mv appcolor-dev-deploy_temp.yaml appcolor-dev-deploy.yaml
mv appcolor-dev-route_temp.yaml appcolor-dev-route.yaml
mv appcolor-dev-svc_temp.yaml appcolor-dev-svc.yaml



echo ""
green_text "FAZENDO PUSH DA APLICACAO PARA O  GITHUB   - $VERSAO"
echo ""


cd $DIR
cd ..
git add .
git commit -m "Deploy Ambiente Dev ${VERSAO}"
git push


echo ""
green_text "CRIANDO NAMESPACE appcolor-dev SE NECESSARIO"
echo ""


cd $DIR

echo  ""
oc login -u vt121170 -p $SENHAOC   > /dev/null 2>&1
echo ""

oc apply -f namespace-appcolor-dev.yaml

echo ""
green_text "CRIANDO APLICACAO appcolor - AMBIENTE: ${AMBIENTE}  - $VERSAO NO ARGOCD"
echo ""



oc apply -f $VERSAO/aplication_appcolor_argocd.yaml > result.txt

RESULT=$(cat result.txt  | awk '{ print $2 }')
[ "X$RESULT" = "Xunchanged" ] &&  oc rollout restart deploy appcolor-dev-deploy-${VERSAO}  -n appcolor-${AMBIENTE}


rm -f result.txt


echo  ""
oc logout  > /dev/null 2>&1


