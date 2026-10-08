**Diretório de build**

> o que o CMake gera e para que serve cada arquivo

Tudo que o CMake produz fica dentro do diretório passado em `-B`: o cache, os resultados da detecção do compilador, os arquivos do generator, os objetos e os binários finais. Conhecer essa estrutura ajuda a entender por que o cache "lembra" de valores antigos e onde procurar quando uma checagem do configure falha

```text
build/
├── CMakeCache.txt              cache: todas as variáveis de cache
├── CMakeFiles/
│   ├── 3.31.2/                 detecção do compilador para esta versão do CMake
│   │   ├── CMakeCCompiler.cmake
│   │   └── CMakeSystem.cmake
│   ├── CMakeConfigureLog.yaml  log de todas as checagens do configure (3.26+)
│   ├── app.dir/                objetos (.o) e regras do target app
│   └── fila.dir/
├── Makefile / build.ninja      arquivos do generator
├── cmake_install.cmake         script executado por cmake --install
├── CTestTestfile.cmake         lista de testes para o ctest
├── compile_commands.json       se CMAKE_EXPORT_COMPILE_COMMANDS=ON
├── src/                        espelho de cada add_subdirectory
│   └── libfila.a
└── app
```

---

**CMakeCache.txt**

```text
//Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel ...
CMAKE_BUILD_TYPE:STRING=Debug

//C compiler
CMAKE_C_COMPILER:FILEPATH=/usr/bin/cc

//Habilita log
USAR_LOG:BOOL=OFF

//Path to a library.
M_LIB:FILEPATH=/usr/lib/x86_64-linux-gnu/libm.so
```

- Cada entrada tem a forma `NOME:TIPO=valor`, com a descrição na linha de cima
- É o único arquivo que guarda estado entre execuções do configure. Tudo que vem de `-D`, `option`, `set(... CACHE ...)` e dos `find_*` fica aqui
- Pode ser editado à mão, mas o jeito seguro é `-D`, `-U` ou `ccmake`
- Entradas marcadas como `INTERNAL` guardam dados do próprio CMake e não aparecem em `cmake -L`

---

**Detecção do compilador**

```text
CMakeFiles/3.31.2/
├── CMakeCCompiler.cmake       ID, versão, padrões suportados, caminhos de busca
├── CMakeSystem.cmake          sistema e processador detectados
├── CMakeDetermineCompilerABI_C.bin
└── CompilerIdC/               programa compilado para identificar o compilador
```

- No primeiro configure, o CMake compila pequenos programas para descobrir qual compilador é, que versão tem, onde ficam os headers do sistema e se ele consegue gerar executáveis
- O resultado é salvo e reaproveitado. Por isso trocar o `CC` depois do primeiro configure não tem efeito sem `--fresh`
- O diretório tem o número da versão do CMake: atualizar o CMake refaz a detecção

---

**`try_compile` e checagens**

```cmake
include(CheckIncludeFile)
include(CheckSymbolExists)
check_include_file(unistd.h TEM_UNISTD_H)
check_symbol_exists(strlcpy "string.h" TEM_STRLCPY)
```

- Cada checagem gera um projeto temporário em `CMakeFiles/CMakeScratch/`, tenta compilá-lo e grava o resultado no cache (`TEM_STRLCPY:INTERNAL=1`)
- Como o resultado fica no cache, a checagem **não** roda de novo. Para refazer, remova a variável (`-U TEM_STRLCPY`) ou use `--fresh`
- A saída do compilador de cada tentativa fica em `CMakeConfigureLog.yaml`. Para manter os projetos temporários: `--debug-trycompile`

---

**Diretório de cada target**

```text
build/CMakeFiles/app.dir/
├── src/main.c.o            objeto (note o .c.o)
├── src/main.c.o.d          dependências de headers (gerado com -MD)
├── flags.make              flags de compilação (Makefiles)
└── link.txt                comando de link (Makefiles)
```

- Os objetos recebem o nome `arquivo.c.o` para não colidir com `arquivo.cpp.o`
- Com Makefiles, `flags.make` e `link.txt` mostram exatamente as flags usadas sem precisar compilar com `-v`
- Com Ninja, tudo fica em `build.ninja` e `ninja -t commands app` lista os comandos

---

**Arquivos do generator**

- **Makefiles**: um `Makefile` em cada diretório de build e em `CMakeFiles/` (regras internas). `make help` lista todos os targets
- **Ninja**: um único `build.ninja` e o `.ninja_log` com o tempo de cada passo. `ninja -t targets` lista os targets e `ninja -t graph | dot -Tpng` desenha o grafo de dependências
- Todos verificam no início se algum `CMakeLists.txt` mudou. Se sim, rodam o `cmake` de novo antes de compilar

---

**File API**

```bash
mkdir -p build/.cmake/api/v1/query
touch build/.cmake/api/v1/query/codemodel-v2
cmake -S . -B build
ls build/.cmake/api/v1/reply/
```

- Uma interface em JSON que descreve o projeto configurado: targets, fontes, flags, includes e dependências
- É o que IDEs e ferramentas usam para entender um projeto CMake sem interpretar o `CMakeLists.txt`

> O diretório de build é descartável: nada nele deve ser editado ou versionado. Quando o comportamento do CMake ficar incompreensível, `--fresh` descarta o cache e a detecção mantendo os objetos, e `rm -rf build` descarta tudo
