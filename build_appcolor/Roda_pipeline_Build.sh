#!/bin/bash

# Carrega Variaveis sensiveis
. ./.env 

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

# Pergunta ao usuário qual é a versão da aplicação
yellow_text "Insira a versão da aplicação que será gerada ( Ex: v1.0, v2.0, v3.0 ): \c"
read VERSAO

# Exibe a versão inserida pelo usuário
green_text "A versão da aplicação que será gerada é: $VERSAO"

red_text  "Confirma Versão $VERSAO ? (S/N): \c"
read CONFIRMA

[ "$CONFIRMA" != "S" ] &&  red_text "GERAÇÃO CANCELADA" && exit 0

echo "- op: replace
  path:  \"/spec/output/to/name\"
  value: appcolor:$VERSAO"  > base/buildconfig-patch.yaml

#   Git 

cd ..
git add .
git commit -m "Commit Versao $VERSAO"
git push

#   Argocd

argocd login --username admin --password  $SENHAARGOCD openshift-gitops-server-openshift-gitops.apps.ocplab.vtal.intra --grpc-web

echo ""
green_text "SINCRONIZANDO ARGOCD COM REPOSITORIO  - $VERSAO"
echo ""

argocd app sync appcolor-build

argocd logout  openshift-gitops-server-openshift-gitops.apps.ocplab.vtal.intra

#  Starta o Build


oc login -u vt121170 -p $SENHAOC

echo ""
green_text "COMPILANDO APLICACAO - $VERSAO"
echo ""


oc start-build appcolor-build -n appcolor --follow


echo ""
green_text "LISTANDO IMAGESTREAM - TAG: $VERSAO"
echo ""

oc get is -n appcolor


oc logout 
