#!/bin/bash

# Caminho para o arquivo YAML de entrada
input_file=$1
# Diretório de saída para os arquivos divididos
output_dir="base"

# Cria o diretório de saída se não existir
mkdir -p "$output_dir"

# Le o arquivo YAML e divide pelos documentos (recursos)
awk '/^---/{n++}{print > "'"$output_dir"'/doc" n ".yaml"}' "$input_file"

# Processa cada arquivo dividido
for file in "$output_dir"/doc*.yaml; do
  kind=$(awk '/^kind:/ {print $2; exit}' "$file")
  name=$(awk '/^metadata:/ {found=1} found && /^  name:/ {print $2; exit}' "$file")
  
  if [[ -n "$kind" && -n "$name" ]]; then
    kind_dir="$output_dir/$kind"
    mkdir -p "$kind_dir"
    mv "$file" "$kind_dir/$name.yaml"
    echo "Recurso $kind/$name salvo em $kind_dir/$name.yaml"
  else
    echo "Documento inválido encontrado em $file, não será movido."
    rm "$file"
  fi
done

