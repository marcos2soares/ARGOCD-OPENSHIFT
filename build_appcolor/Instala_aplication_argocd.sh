echo "Inicializa Build Aplicaçao Versão: v1.0"



echo "- op: replace
  path:  \"/spec/output/to/name\"
  value: appcolor:v1.0"  > base/buildconfig-patch.yaml


#   Git

cd ..
git add .
git commit -m "Commit Versao v1.0"
git push


oc login -u vt121170 -p $SENHAOC

oc apply -f  aplication_appcolor_argocd.yaml

oc logout 
