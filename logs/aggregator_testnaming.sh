#!/bin/bash

output_dir="./aggregate"
input_file="logs.txt"
symlinks_created=0
symlinks_found=0
entradas_nao_encontradas=0
logs_inacessiveis=0

# Garante que o diretório de agregação exista
mkdir -p "$output_dir"

# Verifica se o arquivo de entrada existe
if [ ! -f "$input_file" ]; then
    echo "Arquivo de entrada não encontrado."
    exit 1
fi

# Processa cada linha do arquivo de entrada
while IFS= read -r pattern; do
    # Expandir padrões de curinga em caminhos de arquivo
    if [[ "$pattern" == *"*"* ]]; then
        files=( $pattern )
        for filename in "${files[@]}"; do
            if [ -r "$filename" ]; then  # Verifica se o arquivo é legível
                # Obtém o diretório contendo o arquivo
                directory=$(dirname "$filename")
                # Extrai o último nome da pasta do diretório
                last_folder=$(basename "$directory")

                # Gera o novo nome do arquivo
                new_name="${filename#"$directory/"}" # Remove o diretório
                new_name="${new_name//\//_}" # Substitui barras por sublinhados
                new_name="${last_folder}_${new_name}" # Prefixa com o último diretório

                # Verifica se já existe um link simbólico para este arquivo
                if [ -L "$output_dir/$new_name" ]; then
                    ((symlinks_found++))
                else
                    # Cria um link simbólico no diretório de saída
                    ln -s "$(realpath "$filename")" "$output_dir/$new_name"
                    ((symlinks_created++))
                fi
            else
                ((logs_inacessiveis++))
            fi
        done
    else
        # Processa entradas de arquivo único sem curingas
        if [ -r "$pattern" ]; then  # Verifica se o arquivo é legível
            base_filename=$(basename "$pattern")
            if [ -L "$output_dir/$base_filename" ]; then
                ((symlinks_found++))
            else
                ln -s "$(realpath "$pattern")" "$output_dir/$base_filename"
                ((symlinks_created++))
            fi
        else
            ((entradas_nao_encontradas++))
        fi
    fi
done < "$input_file"

echo "Links simbólicos criados: $symlinks_created"
echo "Links simbólicos encontrados: $symlinks_found"
echo "Entradas não encontradas: $entradas_nao_encontradas"
echo "Logs inacessíveis: $logs_inacessiveis"

# Pergunta ao usuário se deseja visualizar os itens dos logs inacessíveis
read -p "Deseja visualizar os itens dos logs inacessíveis? [Y/n]: " choice
if [[ "$choice" != "n" && "$choice" != "N" ]]; then
    echo "Itens dos logs inacessíveis:"
    cat "$input_file" | while read line; do
        if [ ! -r "$line" ]; then
            echo "$line"
        fi
    done
fi

# Pergunta ao usuário se deseja visualizar os itens dos logs encontrados
read -p "Deseja visualizar os itens dos logs encontrados? [Y/n]: " choice
if [[ "$choice" != "n" && "$choice" != "N" ]]; then
    echo "Itens dos logs encontrados:"
    ls -l "$output_dir" | grep "^l"
fi
