**project**

> comando nativo do CMake, não precisa de include

O `project` dá nome ao projeto, declara as linguagens usadas e detecta o compilador de cada uma, criando variáveis com o nome, a versão e os caminhos do projeto

```cmake
project(<nome>
    [VERSION <maior>[.<menor>[.<patch>]]]
    [DESCRIPTION "<texto>"]
    [LANGUAGES <linguagem>...]
)
```

- `nome`: o nome do projeto, guardado em `PROJECT_NAME`
- `VERSION`: a versão, guardada em `PROJECT_VERSION` e nas partes `PROJECT_VERSION_MAJOR`, `PROJECT_VERSION_MINOR` e `PROJECT_VERSION_PATCH`
- `DESCRIPTION`: um texto livre, guardado em `PROJECT_DESCRIPTION`
- `LANGUAGES`: as linguagens do projeto (`C`, `CXX`, `ASM`). Sem ele, o CMake habilita `C` e `CXX`

- Cria `PROJECT_SOURCE_DIR`, a raiz do projeto, e `PROJECT_BINARY_DIR`, a raiz do diretório de build dele
- Cria `PROJECT_IS_TOP_LEVEL` (3.21+), verdadeiro quando ele é o projeto principal e falso quando é incluído por outro
- Comandos que criam targets (`add_executable`, `add_library`) precisam vir depois dele
- O nome do projeto não tem relação com os nomes dos targets e não precisa ser igual ao do executável

```cmake
cmake_minimum_required(VERSION 3.20)
project(chat VERSION 1.2.0 DESCRIPTION "Servidor de chat" LANGUAGES C)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION}")   # -- chat 1.2.0
```

> Sem `LANGUAGES C`, o configure também procura um compilador C++ e falha se não houver um instalado
