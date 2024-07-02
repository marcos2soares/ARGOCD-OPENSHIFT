# ARGOCD-OPENSHIFT
Exemplo de Aplicação utilizando ARGOCD e OPENSHIFT


ADMIN_PASSWD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d)

SERVER_URL=$(oc get routes openshift-gitops-server -n openshift-gitops -o jsonpath='{.status.ingress[0].host}')

argocd login --username admin --password ${ADMIN_PASSWD} ${SERVER_URL}

