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
green_text "LISTANDO AS IMAGENS PROMOVIDAS PARA O IMAGESTREAM da APLICACAO appcolor do AMBIENTE: ${AMBIENTE}"
echo ""


oc get is appcolor -n appcolor-prd -o json | jq -r '.metadata.name as $name | .status.tags[].tag | "\($name):\(.)"' |  grep -v latest


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



mkdir latest  > /dev/null 2>&1
cp -rp base/* latest/

DIR=$(pwd)
cd latest


sed -e "s/{VERSAO}/${VERSAO}/g"  taglatest-appcolor-prd.yaml > taglatest-appcolor-prd_temp.yaml
mv taglatest-appcolor-prd_temp.yaml taglatest-appcolor-prd.yaml


VERSAODEV=$VERSAO
VERSAO=latest

# PROBLEMA COM SERVICE. NAo pode ter ponto no nome

VERSAO_ALT=$(echo "$VERSAO" | awk '{gsub(/\./, "-"); print}')


sed -e "s/{VERSAO}/${VERSAO}/g" -e "s/{VERSAO_ALT}/${VERSAO_ALT}/g"  appcolor-prd-deploy.yaml  > appcolor-prd-deploy_temp.yaml
sed -e "s/{VERSAO}/${VERSAO}/g" -e "s/{VERSAO_ALT}/${VERSAO_ALT}/g" appcolor-prd-route.yaml  > appcolor-prd-route_temp.yaml
sed -e "s/{VERSAO}/${VERSAO}/g" -e "s/{VERSAO_ALT}/${VERSAO_ALT}/g" appcolor-prd-svc.yaml  > appcolor-prd-svc_temp.yaml

sed -e "s/{VERSAO}/${VERSAO}/g" aplication_appcolor_argocd.yaml >  aplication_appcolor_argocd_temp.yaml

mv aplication_appcolor_argocd_temp.yaml aplication_appcolor_argocd.yaml
mv appcolor-prd-deploy_temp.yaml appcolor-prd-deploy.yaml
mv appcolor-prd-route_temp.yaml appcolor-prd-route.yaml
mv appcolor-prd-svc_temp.yaml appcolor-prd-svc.yaml



echo ""
green_text "FAZENDO PUSH DA APLICACAO PARA O  GITHUB  - AMBIENTE: ${AMBIENTE}  - VERSAO: $VERSAODEV"
echo ""


cd $DIR
cd ..
git add .
git commit -m "Deploy Ambiente Prd ${VERSAODEV}"
git push



echo  ""
oc login -u vt121170 -p $SENHAOC   > /dev/null 2>&1
echo ""

echo ""
green_text "CRIANDO APLICACAO appcolor - AMBIENTE: ${AMBIENTE}  - $VERSAODEV NO ARGOCD"
echo ""

cd $DIR

oc apply -f $VERSAO/aplication_appcolor_argocd.yaml  | tee  result.txt

RESULT=$(cat result.txt  | awk '{ print $2 }')
[ "X$RESULT" = "Xunchanged" ] &&  oc rollout restart deploy appcolor-prd-deploy-${VERSAO}  -n appcolor-${AMBIENTE}


rm -f result.txt


echo  ""
oc logout  > /dev/null 2>&1


