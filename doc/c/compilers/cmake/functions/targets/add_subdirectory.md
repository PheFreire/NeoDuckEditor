**add_subdirectory**

> comando nativo do CMake, não precisa de include

O `add_subdirectory` executa o `CMakeLists.txt` de um subdiretório no ponto em que é chamado, permitindo dividir o projeto em partes onde cada diretório cria os próprios targets

```cmake
add_subdirectory(<diretório> [<diretório de build>] [EXCLUDE_FROM_ALL] [SYSTEM])
```

- `diretório`: o subdiretório, relativo ao atual. Precisa ter um `CMakeLists.txt`
- `diretório de build`: onde os arquivos desse diretório são gerados. Só é obrigatório para um diretório fora da árvore do projeto
- `EXCLUDE_FROM_ALL`: os targets do diretório só são compilados quando pedidos com `-t nome`. Útil para exemplos
- `SYSTEM` (3.25+): os headers do diretório são incluídos com `-isystem`, sem mostrar os warnings deles

- O subdiretório recebe uma cópia das variáveis de quem chamou. O que ele muda não volta, a não ser com `set(... PARENT_SCOPE)`
- Os targets são globais: uma biblioteca criada em `src/` pode ser linkada em `app/` sem configurar nada
- A ordem dos `add_subdirectory` não importa para o `target_link_libraries`, pois os nomes dos targets só são resolvidos no fim do configure
- O diretório de build espelha o do código: os arquivos de `src/` são gerados em `build/src/`

```text
projeto/
├── CMakeLists.txt
├── src/
│   ├── CMakeLists.txt
│   └── lista.c
└── app/
    ├── CMakeLists.txt
    └── main.c
```

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES C)

add_subdirectory(src)
add_subdirectory(app)
```

```cmake
# src/CMakeLists.txt
add_library(lista STATIC lista.c)
target_include_directories(lista PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```

```cmake
# app/CMakeLists.txt
add_executable(app main.c)
target_link_libraries(app PRIVATE lista)
```

> Os `CMakeLists.txt` de subdiretórios não repetem o `cmake_minimum_required` nem o `project`. Eles só criam e configuram os targets daquele diretório
