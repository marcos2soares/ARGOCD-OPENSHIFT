# Carrega Variaveis Senseiveis

. ./.env

echo "Inicializa Build Aplicaçao Versão: v1.0"



echo "- op: replace
  path:  \"/spec/output/to/name\"
  value: appcolor:v1.0"  > base/buildconfig-patch.yaml


#   Git

DIR=$(pwd)
cd ..
git add .
git commit -m "Commit Versao v1.0"
git push


oc login -u vt121170 -p $SENHAOC

cd $DIR

echo "Remove Imagestream de Producao no Namespace Openshift se Existir"
oc delete is appcolor -n openshift

oc apply -f  ./aplication_appcolor_argocd.yaml

oc logout 
