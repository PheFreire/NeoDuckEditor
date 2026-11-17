**cmake --build**

> ferramenta de linha de comando, vem com o CMake

O `cmake --build <build>` compila o projeto chamando a ferramenta de build gerada no configure (`make` ou `ninja`), que recompila só os arquivos que mudaram desde o último build

```bash
cmake --build <diretório de build> [opções] [-- <opções da ferramenta>]
```

- `diretório de build`: o mesmo diretório passado no `-B` do configure
- `-j <N>` / `--parallel <N>`: compila `N` arquivos ao mesmo tempo
- `-t <target>` / `--target <target>`: compila só um target e as suas dependências. Pode ser repetido
- `--target clean`: apaga o que foi compilado e mantém o cache
- `--clean-first`: limpa e compila de novo
- `-v` / `--verbose`: mostra o comando completo do `gcc` de cada arquivo
- `--config <tipo>`: o build type nos generators com vários build types (Xcode, Visual Studio)
- `--`: o que vem depois vai direto para o `make` ou o `ninja`

- O build é incremental: recompila os `.c` que mudaram e os que incluem um header que mudou
- Quando um `CMakeLists.txt` mudou, ele reconfigura o projeto antes de compilar
- Funciona com qualquer generator, então os mesmos comandos servem com `make` e com `ninja`

```bash
cmake --build build                  # compila tudo
cmake --build build -j 8             # 8 arquivos em paralelo
cmake --build build -t app           # só o target app
cmake --build build -v               # mostra os -I, -D e bibliotecas de cada comando
cmake --build build --clean-first    # do zero, sem perder o cache
```

> O `-v` é a primeira coisa a usar quando um header não é encontrado ou um símbolo fica sem definição: ele mostra exatamente o que o CMake passou para o compilador
