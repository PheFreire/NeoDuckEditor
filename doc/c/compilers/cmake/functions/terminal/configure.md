**cmake -S -B**

> ferramenta de linha de comando, vem com o CMake

O `cmake -S <código> -B <build>` configura o projeto: executa o `CMakeLists.txt`, detecta o compilador, procura as dependências e gera os arquivos de build no diretório de build

```bash
cmake -S <diretório do código> -B <diretório de build> [opções]
```

- `-S`: o diretório onde está o `CMakeLists.txt` raiz
- `-B`: o diretório onde tudo é gerado. É criado se não existir
- `-G <generator>`: a ferramenta de build gerada, como `Ninja` ou `"Unix Makefiles"` (o padrão). Só vale na primeira configuração
- `-D <variável>=<valor>`: define uma variável de cache ou uma `option`, como `-DCMAKE_BUILD_TYPE=Debug`
- `-U <variável>`: remove uma variável do cache
- `--fresh` (3.24+): descarta o cache e configura do zero, sem apagar o que já foi compilado
- `--preset <nome>`: usa uma configuração pronta do `CMakePresets.json` (abaixo)
- `--log-level=VERBOSE`: mostra as mensagens `VERBOSE` do `message`
- `-Wno-dev`: esconde os avisos feitos para quem mantém o `CMakeLists.txt`

- É feito uma vez. Depois disso, o `cmake --build` reconfigura sozinho quando um `CMakeLists.txt` muda
- Rode de novo só para mudar uma variável com `-D`. Os valores passados ficam no cache e continuam valendo nas próximas vezes
- O compilador é escolhido na primeira configuração e fica gravado. Para trocar, use `--fresh` junto com `-DCMAKE_C_COMPILER=clang`
- Tudo é gerado dentro do diretório de build. Para começar do zero, apague o diretório

```bash
cmake -S . -B build                                   # o mais simples
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release   # um segundo build, lado a lado
cmake -S . -B build -DAPP_LOG=ON                       # muda uma option
cmake --fresh -S . -B build -DCMAKE_C_COMPILER=clang   # troca de compilador
```

---

**Build types**

| `CMAKE_BUILD_TYPE` | Flags no GCC e no Clang | Uso |
|---|---|---|
| `Debug` | `-g` | desenvolvimento e debugger |
| `Release` | `-O3 -DNDEBUG` | versão final |
| `RelWithDebInfo` | `-O2 -g -DNDEBUG` | versão final com símbolos para depurar |
| `MinSizeRel` | `-Os -DNDEBUG` | binário menor |
| vazio | nenhuma | o padrão, sem otimização e sem debug |

- Sem `-DCMAKE_BUILD_TYPE`, o build não tem nem `-g` nem otimização. Passe sempre um build type

---

**Inspecionando o cache**

```bash
cmake -LH build      # variáveis do cache com a descrição de cada uma
ccmake build         # editor do cache no terminal: c configura, g gera, q sai
```

---

**Presets**

Um `CMakePresets.json` na raiz guarda as opções de configuração, para não repetir a linha de comando inteira:

```json
{
    "version": 3,
    "configurePresets": [
        {
            "name": "debug",
            "generator": "Ninja",
            "binaryDir": "build",
            "cacheVariables": { "CMAKE_BUILD_TYPE": "Debug" }
        }
    ]
}
```

```bash
cmake --list-presets
cmake --preset debug     # o mesmo que cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
```

- O `version` 3 exige o CMake 3.21 ou mais novo

> Evite rodar `cmake .` dentro da pasta do código. Sem `-B`, o CMake gera tudo no diretório atual e espalha `CMakeCache.txt`, `CMakeFiles/` e `Makefile` no meio dos fontes
