**cmake**

> ferramenta de linha de comando (gerador de sistemas de build)

O CMake lê a descrição de um projeto escrita no arquivo `CMakeLists.txt` e gera os arquivos de um sistema de build (`Makefile` ou `build.ninja`), que é quem chama o `gcc` ou o `clang` para compilar e linkar o programa

> Em vez de escrever o comando do compilador à mão (`gcc -Iinclude main.c lista.c -lm -o app`), você descreve **o que** o projeto tem: quais executáveis, quais bibliotecas, onde ficam os headers e quem depende de quem. O CMake monta os comandos certos para o compilador da máquina e recompila só o que mudou

```text
CMakeLists.txt  →  cmake -S . -B build  →  build/Makefile
build/Makefile  →  cmake --build build  →  gcc ...  →  build/app
```

- O CMake não compila nada. Ele gera os arquivos de build, e o `make` ou o `ninja` chama o compilador
- Tudo que é gerado fica em um diretório separado (`build/`), e o diretório do código continua limpo
- O mesmo `CMakeLists.txt` funciona no Linux, macOS e Windows, com GCC, Clang ou MSVC

---

**A lógica do CMakeLists.txt**

O `CMakeLists.txt` é um script executado de cima para baixo. Cada linha chama um comando, `nome(argumentos)`, e o objetivo do arquivo é criar **targets** e dizer como eles se ligam. Um target é algo que o build produz: um executável ou uma biblioteca

```text
add_executable / add_library    → cria um target
target_*                        → configura um target (headers, macros, flags)
target_link_libraries           → liga um target a outro
```

- Configurações pertencem a um target, e não ao projeto inteiro. O `project()` só dá nome ao projeto e detecta o compilador
- Tudo é string. Variáveis são criadas com `set` e lidas com `${NOME}`
- O nome do comando aceita maiúsculas ou minúsculas, mas o padrão é minúsculo. Palavras-chave (`PRIVATE`, `STATIC`) são escritas em maiúsculo
- Caminhos relativos partem do diretório do `CMakeLists.txt` que está rodando

---

**Lendo um exemplo linha por linha**

```text
projeto/
├── CMakeLists.txt
├── include/
│   └── lista.h      # declara lista_criar()
└── src/
    ├── lista.c      # define lista_criar() e faz #include "lista.h"
    └── main.c       # chama lista_criar() e faz #include "lista.h"
```

```cmake
add_library(lista STATIC src/lista.c)
target_include_directories(lista PUBLIC include)
add_executable(app src/main.c)
target_link_libraries(app PRIVATE lista)
```

---

**add_library**

Cria uma biblioteca como um target
Em `add_library(lista STATIC src/lista.c)`:

    - `lista`: o nome que você dá ao target (será por esse nome que os outros comandos irão identificar esse target)

    - `STATIC`: o tipo, que gera o arquivo `liblista.a`

    - `src/lista.c`: o código compilado dentro dela

    - O `lista.c` faz `#include "lista.h"`, mas o header está em `include/` e não ao lado dele. Sem a próxima linha, a compilação falha com `fatal error: lista.h: No such file or directory`

---

**target_include_directories**

Diz em que diretórios estão os headers e os vincula ao target
Em `target_include_directories(lista PUBLIC include)`:

    - `lista`: O nome do target que está sendo configurado

    - `PUBLIC`: Quem tem acesso aos headers vinculados
        - `PUBLIC`: O target "lista" e todos os outros que se linkarem a ele

        - `PRIVATE`: Apenas o target "lista"

        - `INTERFACE`: Apenas os targets que se linkarem a "lista"

    - `include`: O path do diretório onde o preprocessor vai procurar os headers (vira `-I/projeto/include` no comando do `gcc`)

> Os `#include` do C são procurados a partir dos diretórios passados com `-I`. Um caminho relativo como `/include` parte do diretório do `CMakeLists.txt` que está rodando.

```cmake
target_include_directories(lista PUBLIC ${PROJECT_SOURCE_DIR}/include)
```

- `${PROJECT_SOURCE_DIR}` é a raiz do projeto, o diretório do `CMakeLists.txt` que chamou o `project()`. Funciona em qualquer `CMakeLists.txt` para escrever caminhos a partir da raiz

- `${CMAKE_CURRENT_SOURCE_DIR}` é o diretório do `CMakeLists.txt` que está rodando. É dele que partem os caminhos relativos, como o `include` do exemplo

Para definir um path root, passe um único diretório que contém todos os módulos do projeto. Todo `#include` passa a ser escrito a partir dele, não importa em qual diretório o arquivo esteja:

```text
projeto/
├── CMakeLists.txt
└── src/                  # path root dos includes
    ├── main.c
    ├── lista/
    │   ├── lista.h
    │   └── lista.c
    └── fila/
        ├── fila.h
        └── fila.c        # usa a lista
```

```cmake
add_library(raiz INTERFACE)
target_include_directories(raiz INTERFACE ${PROJECT_SOURCE_DIR}/src)

add_library(lista STATIC src/lista/lista.c)
target_link_libraries(lista PUBLIC raiz)

add_library(fila STATIC src/fila/fila.c)
target_link_libraries(fila PUBLIC lista)

add_executable(app src/main.c)
target_link_libraries(app PRIVATE fila)
```

```c
// src/lista/lista.c
#include "lista/lista.h"

// src/fila/fila.c
#include "fila/fila.h"
#include "lista/lista.h"

// src/main.c
#include "fila/fila.h"
#include "lista/lista.h"
```

```text
gcc -I/projeto/src -c src/lista/lista.c
gcc -I/projeto/src -c src/fila/fila.c
gcc -I/projeto/src -c src/main.c
```

- `raiz`: uma biblioteca `INTERFACE`, que não compila nada e só guarda o path root. Quem a linka recebe o `-I/projeto/src`

- `INTERFACE ${PROJECT_SOURCE_DIR}/src`: o path root, o diretório `src/` escrito a partir da raiz do projeto. Funciona igual em qualquer `CMakeLists.txt`, mesmo em subdiretórios

- `target_link_libraries(lista PUBLIC raiz)`: a `lista` recebe o path root e, por ser `PUBLIC`, passa ele adiante. A `fila` recebe da `lista`, e o `app` recebe da `fila`, sem nenhum dos dois repetir o `target_include_directories`

- Um target que não linka nada que carregue o path root precisa linkar a `raiz` direto: `target_link_libraries(nome PRIVATE raiz)`

- O caminho dentro das aspas é sempre escrito a partir de `src/`. O nome do módulo aparece no include (`"lista/lista.h"`), o que mostra de onde vem cada header e evita colisão entre dois headers de mesmo nome em módulos diferentes

- Evite `#include "../lista/lista.h"`: o caminho depende de onde o arquivo está e quebra quando ele muda de diretório

---

**add_executable**

Cria um executável como um target
Em `add_executable(app src/main.c)`:

    - `app`: o nome que você dá ao target, que também vira o nome do arquivo gerado (`build/app`)

    - `src/main.c`: path do script que sera executado.

---

**target_link_libraries**

Liga uma biblioteca a um target
Em `target_link_libraries(app PRIVATE lista)`:

    - `app`: o nome do target que recebe a biblioteca

    - `PRIVATE`: se a biblioteca passa adiante para quem linkar o `app`
        - `PRIVATE`: apenas o `app` recebe a `lista`. É o usado em executáveis, pois ninguém linka um executável

        - `PUBLIC`: o `app` e todos os outros targets que se linkarem a ele

        - `INTERFACE`: apenas os targets que se linkarem ao `app`

    - `lista`: a biblioteca que é ligada. O `app` recebe a `liblista.a` no link e, por causa do `PUBLIC` da `lista`, recebe também o `-I/projeto/include`

---

**Os comandos gerados**

Com essas quatro linhas, o CMake gera estes comandos para o `gcc`:

```text
# -I: o PUBLIC vale para a própria lista
gcc -I/projeto/include -c src/lista.c -o lista.o

ar rcs liblista.a lista.o

# -I: o PUBLIC passou para o app pelo target_link_libraries
gcc -I/projeto/include -c src/main.c -o main.o

# liblista.a: o target_link_libraries
gcc main.o liblista.a -o app
```


| Se fosse | `lista.c` recebe `-Iinclude` | `main.c` recebe `-Iinclude` | Resultado |
|---|---|---|---|
| `PRIVATE` | sim | não | o `main.c` falha: `lista.h: No such file or directory` |
| `PUBLIC` | sim | sim | compila |
| `INTERFACE` | não | sim | o `lista.c` falha: `lista.h: No such file or directory` |


> A biblioteca declara uma única vez onde estão os seus headers, e quem a usa só precisa do `target_link_libraries`. Se o `include/` mudar de lugar, só a linha da `lista` muda, e nenhum executável precisa ser editado

---

**Preenchendo o CMakeLists.txt**

Todo `CMakeLists.txt` segue a mesma ordem:

```cmake
# 1. versão mínima do CMake, sempre a primeira linha
cmake_minimum_required(VERSION 3.20)

# 2. nome do projeto e linguagem
project(app VERSION 1.0.0 LANGUAGES C)

# 3. configuração global
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 4. opções que quem compila pode mudar com -D
option(APP_LOG "Habilita as mensagens de log" OFF)

# 5. dependências de fora do projeto
find_package(Threads REQUIRED)

# 6. bibliotecas do projeto
add_library(lista STATIC src/lista/lista.c)
target_include_directories(lista PUBLIC ${PROJECT_SOURCE_DIR}/src)

# 7. executáveis
add_executable(app src/main.c)
target_link_libraries(app PRIVATE lista Threads::Threads)
target_compile_options(app PRIVATE -Wall -Wextra)

if(APP_LOG)
    target_compile_definitions(app PRIVATE APP_LOG)
endif()
```

- Cada comando tem a sua nota em `functions/<grupo>/<comando>.md` (lista completa em `doc-map.md`)

---

**Executando**

```bash
# configura: lê o CMakeLists.txt e gera build/
cmake -S . -B build        

# compila
cmake --build build

# executa
./build/app
```

- A configuração é feita uma vez. Depois basta `cmake --build build` a cada mudança, inclusive no `CMakeLists.txt`, que é relido automaticamente

- Rode o `cmake -S . -B build` de novo só para mudar uma opção (`-D...`)

- Coloque `build/` no `.gitignore`

| Parâmetro | O que faz |
|---|---|
| `-S .` / `-B build` | diretório do código / diretório de build |
| `-G Ninja` | usa o `ninja` no lugar do `make` |
| `-DCMAKE_BUILD_TYPE=Debug` | `Debug` (`-g`), `Release` (`-O3 -DNDEBUG`), `RelWithDebInfo` ou `MinSizeRel` |
| `-DNOME=valor` | muda uma variável ou `option` do projeto |
| `--fresh` | descarta o cache e configura do zero |
| `--build build -j 8` | compila com 8 jobs em paralelo |
| `--build build -t app` | compila só um target |
| `--build build -v` | mostra os comandos completos do `gcc` |
| `ctest --test-dir build` | roda os testes |
| `cmake --install build` | instala o programa |


- Todos os parâmetros estão em `functions/terminal/`

---

**Flags e macros diferentes por build type**

O build type escolhido no configure (`-DCMAKE_BUILD_TYPE=...`) pode ligar compile options e macros diferentes. Assim o mesmo código compila com debug e valores de desenvolvimento em um build, e otimizado com valores de produção em outro:

```cmake
add_executable(server src/server/server.c)

target_compile_options(server PRIVATE
    -Wall -Wextra
    $<$<CONFIG:Debug>:-g3>
    $<$<CONFIG:Debug>:-O0>
)

target_compile_definitions(server PRIVATE
    $<$<CONFIG:Debug>:PORTA=8080>
    $<$<CONFIG:Debug>:LOG_NIVEL=3>
    $<$<CONFIG:Release>:PORTA=80>
    $<$<CONFIG:Release>:LOG_NIVEL=1>
)
```

Em `$<$<CONFIG:Debug>:-g3>`:

    - `$<...>`: uma generator expression, um valor que o CMake só decide depois de saber o build type

    - `$<CONFIG:Debug>`: vale `1` quando o build type é `Debug` e `0` quando não é

    - `-g3`: o que entra no comando quando a condição vale `1`. Quando vale `0`, a expressão inteira some

    - Escreva uma flag ou macro por expressão. Com espaço dentro, como `$<$<CONFIG:Debug>:-g3 -O0>`, o CMake separa em dois argumentos quebrados

Em `target_compile_definitions(server PRIVATE ...)`:

    - `$<$<CONFIG:Debug>:PORTA=8080>`: no `Debug`, define a macro `PORTA` valendo `8080`

    - `$<$<CONFIG:Release>:PORTA=80>`: no `Release`, a mesma macro vale `80`

    - `LOG_NIVEL`: outra macro que muda entre os dois, usada no código para decidir o quanto imprimir

```c
// src/server/server.c
#include <stdio.h>

int main(void) {
    printf("server na porta %d\n", PORTA);

#if LOG_NIVEL >= 3
    printf("log detalhado ligado\n");   // só no Debug
#endif
    return 0;
}
```

```bash
# um diretório de build para cada build type, lado a lado
cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug
cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release

cmake --build build-debug
cmake --build build-release

./build-debug/server      # server na porta 8080 e log detalhado ligado
./build-release/server    # server na porta 80
```

```text
# o comando que o CMake gera para o server.c em cada build
build-debug:    gcc -DLOG_NIVEL=3 -DPORTA=8080 -g -Wall -Wextra -g3 -O0 -c src/server/server.c
build-release:  gcc -DLOG_NIVEL=1 -DPORTA=80 -O3 -DNDEBUG -Wall -Wextra -c src/server/server.c
```

- O `Debug` já adiciona `-g`, e o `Release` já adiciona `-O3 -DNDEBUG`. A generator expression só acrescenta o que é do seu projeto

- Cada diretório de build guarda o seu build type. Compilar um não mexe no outro

- `$<CONFIG:Debug,RelWithDebInfo>` (3.19+) vale para mais de um build type

Para um valor que quem compila escolhe no terminal, sem depender do build type, crie uma variável de cache e passe ela como macro:

```cmake
set(CHAT_PORTA 8080 CACHE STRING "Porta do servidor")
target_compile_definitions(server PRIVATE PORTA=${CHAT_PORTA})
```

Em `set(CHAT_PORTA 8080 CACHE STRING "Porta do servidor")`:

    - `CHAT_PORTA`: o nome da variável do CMake. Use o nome do projeto como prefixo

    - `8080`: o valor padrão, usado quando nada é passado no terminal

    - `CACHE STRING`: grava a variável no cache, para ser mudada com `-D` e continuar valendo nas próximas configurações

    - `"Porta do servidor"`: a descrição exibida no `cmake -LH`

```bash
cmake -S . -B build -DCHAT_PORTA=9000
cmake --build build
./build/server            # server na porta 9000
```

---

**Dois executáveis**

```text
projeto/
├── CMakeLists.txt
└── src/
    ├── rede/
    │   ├── rede.h
    │   └── rede.c        # código usado pelos dois
    ├── server/
    │   └── server.c      # main do server
    └── client/
        └── client.c      # main do client
```

```cmake
add_library(rede STATIC src/rede/rede.c)
target_include_directories(rede PUBLIC ${PROJECT_SOURCE_DIR}/src)

add_executable(server src/server/server.c)
add_executable(client src/client/client.c)

target_link_libraries(server PRIVATE rede)
target_link_libraries(client PRIVATE rede)

target_compile_options(server PRIVATE -Wall -Wextra)
target_compile_options(client PRIVATE -Wall -Wextra)
```

Em `add_executable(server src/server/server.c)` e `add_executable(client src/client/client.c)`:

    - `server` / `client`: dois targets independentes. Cada um vira um arquivo em `build/`

    - `src/server/server.c` / `src/client/client.c`: cada executável tem o seu próprio `main`. Os dois não podem estar no mesmo `add_executable`, pois dá erro de `main` duplicado no link

Em `target_link_libraries(server PRIVATE rede)`:

    - `rede`: o código usado pelos dois fica em uma biblioteca, compilada uma vez e linkada em cada executável. Cada executável precisa da própria linha

```bash
cmake -S . -B build
cmake --build build              # compila os dois
cmake --build build -t server    # compila só o server e a rede
cmake --build build -t client    # compila só o client e a rede

./build/server
./build/client                   # em outro terminal
```

- Flags e macros são de cada target. O `server` pode ter `-g3` e o `client` não, cada um com o seu `target_compile_options`

- Os dois executáveis usam o mesmo build type, escolhido no configure do diretório de build

---

**Exemplo de Organizacao de projeto**

```text
projeto/
├── CMakeLists.txt          # raiz: versão, projeto, configuração e add_subdirectory
├── src/
│   ├── CMakeLists.txt      # bibliotecas: add_library(lista ...)
│   └── lista/
│       ├── lista.h
│       └── lista.c
├── app/
│   ├── CMakeLists.txt      # executáveis: add_executable(app ...)
│   └── main.c
├── tests/
│   ├── CMakeLists.txt      # add_executable(test_lista ...) e add_test
│   └── test_lista.c
└── build/                  # gerado pelo CMake, fora do git
```


```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES C)

set(CMAKE_C_STANDARD 17)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

add_subdirectory(src)
add_subdirectory(app)

enable_testing()
add_subdirectory(tests)
```


```cmake
# src/CMakeLists.txt
add_library(lista STATIC lista/lista.c)
target_include_directories(lista PUBLIC ${PROJECT_SOURCE_DIR}/src)
```


```cmake
# app/CMakeLists.txt
add_executable(app main.c)
target_link_libraries(app PRIVATE lista)
```


```cmake
# tests/CMakeLists.txt
add_executable(test_lista test_lista.c)
target_link_libraries(test_lista PRIVATE lista)
add_test(NAME lista COMMAND test_lista)
```

- O código fica em bibliotecas dentro de `src/`, e cada executável só tem o `main.c`. Assim os testes linkam a mesma biblioteca que o programa

- Cada `CMakeLists.txt` cuida só do próprio diretório. Um `.c` novo mexe só no arquivo daquele diretório

- O `CMAKE_RUNTIME_OUTPUT_DIRECTORY` junta todos os executáveis em `build/bin`. Sem ele, cada um fica no diretório de build que espelha o seu (`build/app/app`)

- Um projeto pequeno pode ter um único `CMakeLists.txt` na raiz. Divida quando ele ficar difícil de ler

---

**Bibliotecas estáticas e dinâmicas**

```cmake
add_library(lista STATIC src/lista/lista.c)
```

Em `add_library(lista STATIC src/lista/lista.c)`:

    - `lista`: o nome que você dá ao target. O arquivo gerado recebe o prefixo `lib` e a extensão automaticamente

    - `STATIC`: o tipo da biblioteca
        - `STATIC`: gera `liblista.a`, que é copiada para dentro do executável no link

        - `SHARED`: gera `liblista.so` no Linux ou `liblista.dylib` no macOS, que fica separada do executável e é carregada ao executar

    - `src/lista/lista.c`: o código compilado dentro da biblioteca

---

```cmake
target_link_libraries(app PRIVATE lista m)
```

Em `target_link_libraries(app PRIVATE lista m)`:

    - `app`: o nome do target que recebe as bibliotecas

    - `PRIVATE`: as bibliotecas não passam adiante para quem linkar o `app`

    - `lista`: uma biblioteca do projeto, pelo nome do target

    - `m`: uma biblioteca do sistema pelo nome, que vira `-lm`

---

```cmake
find_package(Threads REQUIRED)
target_link_libraries(app PRIVATE Threads::Threads)
```

Em `find_package(Threads REQUIRED)`:

    - `Threads`: o nome do pacote procurado no sistema

    - `REQUIRED`: para o configure com erro se o pacote não for encontrado

    - Quando encontra, cria o target `Threads::Threads`, que já carrega o header e a biblioteca para o `target_link_libraries`

---

```cmake
find_library(FILA_LIB fila REQUIRED)
target_link_libraries(app PRIVATE ${FILA_LIB})
```

Em `find_library(FILA_LIB fila REQUIRED)`:

    - `FILA_LIB`: a variável que recebe o caminho completo do arquivo encontrado

    - `fila`: o nome da biblioteca, sem o `lib` e sem a extensão. Encontra `libfila.a`, `libfila.so` ou `libfila.dylib`

    - `REQUIRED`: para o configure com erro se a biblioteca não for encontrada

    - Serve para bibliotecas instaladas que não têm suporte a `find_package`

- O `add_library` **cria** uma biblioteca a partir dos seus `.c`. Para usar uma que já existe, use `find_package` ou `find_library`

- O `target_link_libraries` liga a biblioteca a **um** target. Cada executável que usa a biblioteca precisa da própria linha

- O CMake adiciona sozinho o `ar`, o `-fPIC` e o `-shared`. Uma `SHARED` roda direto do diretório de build sem configurar nada

- Na dúvida, use `STATIC`: o executável não depende de encontrar arquivos ao rodar

---

**Listando os fontes com file(GLOB)**

O `add_library` e o `add_executable` não entendem `*`. Um padrão como `src/client/providers/*.c` escrito direto neles é tratado como o nome de um arquivo, e o configure falha com `Cannot find source file`. Para usar um padrão, monte a lista antes com `file(GLOB)`:

```text
src/client/providers/
├── client_providers.h
├── conect_into_server.c
├── get_client_adress.c
├── get_server_adress.c
└── open_client.c
```

```cmake
file(GLOB CLIENT_PROVIDERS CONFIGURE_DEPENDS src/client/providers/*.c)
add_library(client_providers STATIC ${CLIENT_PROVIDERS})
```

Em `file(GLOB CLIENT_PROVIDERS CONFIGURE_DEPENDS src/client/providers/*.c)`:

    - `GLOB`: procura os arquivos que casam com o padrão e grava a lista deles em uma variável

    - `CLIENT_PROVIDERS`: o nome da variável que recebe a lista

    - `CONFIGURE_DEPENDS`: confere o diretório de novo a cada `cmake --build`. Sem ele, um `.c` novo só entra no build depois de rodar o `cmake -S . -B build` de novo

    - `src/client/providers/*.c`: o padrão. O `*` casa com qualquer nome, então pega todos os `.c` do diretório, mas não os dos subdiretórios

Em `add_library(client_providers STATIC ${CLIENT_PROVIDERS})`:

    - `client_providers`: o nome que você dá ao target da biblioteca

    - `STATIC`: gera `libclient_providers.a`

    - `${CLIENT_PROVIDERS}`: a lista montada pelo `file(GLOB)`. Sem aspas, cada arquivo vira um argumento, como se tivesse sido escrito à mão

```cmake
# o que o add_library recebe depois que a variável é expandida
add_library(client_providers STATIC
    /projeto/src/client/providers/conect_into_server.c
    /projeto/src/client/providers/get_client_adress.c
    /projeto/src/client/providers/get_server_adress.c
    /projeto/src/client/providers/open_client.c
)
```

- O `client_providers.h` fica de fora porque o padrão só pega `.c`. Headers não precisam estar na lista

- Os caminhos da lista são absolutos. Por isso ela funciona igual em qualquer `CMakeLists.txt`

- `GLOB_RECURSE` procura também nos subdiretórios: `file(GLOB_RECURSE FONTES CONFIGURE_DEPENDS src/*.c)`

- `message(STATUS "${CLIENT_PROVIDERS}")` mostra no configure quais arquivos foram encontrados

- O `GLOB` pega todo `.c` do diretório, inclusive um rascunho ou um teste esquecido ali, e ele passa a ser compilado na biblioteca

> A recomendação do CMake é listar os fontes à mão: o diff do `CMakeLists.txt` mostra quais arquivos entraram ou saíram do build, e o `CONFIGURE_DEPENDS` deixa cada build um pouco mais lento. O `GLOB` compensa quando o diretório tem muitos arquivos que mudam com frequência (ver `functions/arquivos/file.md`)

---

**Macros**

```cmake
target_compile_definitions(app PRIVATE
    DEBUG              # -DDEBUG       → #ifdef DEBUG
    VERSAO=2           # -DVERSAO=2    → #if VERSAO >= 2
    "NOME=\"app\""     # -DNOME="app"  → printf("%s\n", NOME)
)
```

**target_compile_definitions**

Em `target_compile_definitions(app PRIVATE DEBUG VERSAO=2 "NOME=\"app\"")`:

    - `app`: o nome do target que recebe as macros

    - `PRIVATE`: as macros valem só para os `.c` do `app`

    - `DEBUG`: uma macro sem valor, que vira `-DDEBUG` e vale `1`

    - `VERSAO=2`: uma macro com valor, que vira `-DVERSAO=2`

    - `"NOME=\"app\""`: uma macro com texto. As aspas de dentro são escapadas com `\` para o código C receber `"app"`

---

```bash
cmake -S . -B build -DAPP_LOG=ON    # liga a option APP_LOG, que o if transforma em macro
```

- O CMake passa as macros para o compilador como `-D`. No código elas funcionam como um `#define` (ver `doc/c/macros/`)
- Para uma macro que quem compila liga e desliga, combine `option`, `if` e `target_compile_definitions` (passo 4 e final de **Preenchendo o CMakeLists.txt**)
- O `-DNOME=valor` do terminal muda uma **variável do CMake**, e não uma macro do C. Ela só chega ao código se o `CMakeLists.txt` a passar no `target_compile_definitions`
- Para muitas macros ou valores como a versão do projeto, gere um header com `configure_file`

> Quando algo der errado, `cmake --build build -v` mostra os comandos completos do `gcc`, com cada `-I`, `-D` e biblioteca. Compare com o comando que você escreveria à mão
