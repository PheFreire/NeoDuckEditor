**Erros comuns do CMake**

> como reconhecer a fase e corrigir

Os erros de um projeto CMake vêm de duas origens. Os que começam com `CMake Error` acontecem no **configure** e apontam o arquivo e a linha do `CMakeLists.txt`. Os que aparecem durante o `cmake --build` vêm do **compilador ou do linker**, e quase sempre significam que um `target_*` está faltando ou com a visibilidade errada

```text
CMake Error at CMakeLists.txt:12 (find_package):   → configure (código CMake)
fatal error: fila.h: No such file or directory     → build (compilador)
undefined reference to `fila_criar'                → build (linker)
```

---

**does not appear to contain CMakeLists.txt**

```text
CMake Error: The source directory "/home/u/projeto/build" does not appear to contain CMakeLists.txt.
```

1. **Significado**: o diretório passado como código não tem um `CMakeLists.txt`
2. **Fase**: configure
3. **Causas**:
    - Rodou `cmake .` de dentro do diretório de build (estilo antigo, que exige `cmake ..`)
    - `-S` apontando para o lugar errado
    - Nome do arquivo errado (`CmakeLists.txt`, `CMakeLists.txt.txt`)
4. **Investigar**: `ls` no diretório passado em `-S`
5. **Corrigir**: rodar da raiz do projeto com `cmake -S . -B build`

---

**No `CMAKE_C_COMPILER` could be found**

```text
CMake Error at CMakeLists.txt:2 (project):
  No CMAKE_C_COMPILER could be found.
  Tell CMake where to find the compiler by setting either the environment
  variable "CC" or the CMake cache entry CMAKE_C_COMPILER to the full path to
  the compiler, or to the compiler name if it is in the PATH.
```

1. **Significado**: o `project()` não encontrou um compilador funcionando
2. **Fase**: configure
3. **Causas**:
    - Nenhum compilador instalado (Linux sem `build-essential`/`gcc`, macOS sem Command Line Tools)
    - `CC` apontando para um programa que não existe
    - Faltou `LANGUAGES C` e quem não foi encontrado é o compilador C++ (`No CMAKE_CXX_COMPILER`)
4. **Investigar**: `which cc gcc clang` e `echo $CC`
5. **Corrigir**: instalar o compilador (`xcode-select --install` no macOS), corrigir `CC`, adicionar `LANGUAGES C` ao `project()`. Depois, `--fresh`, porque a falha fica no cache

---

**Could not find a package configuration file**

```text
CMake Error at CMakeLists.txt:5 (find_package):
  By not providing "FindFila.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "Fila", but
  CMake did not find one.

  Could not find a package configuration file provided by "Fila" with any of
  the following names:

    FilaConfig.cmake
    fila-config.cmake

  Add the installation prefix of "Fila" to CMAKE_PREFIX_PATH or set
  "Fila_DIR" to a directory containing one of the above files.
```

1. **Significado**: o `find_package(Fila REQUIRED)` não encontrou nem um `FindFila.cmake` nem um `FilaConfig.cmake`
2. **Fase**: configure
3. **Causas**:
    - Biblioteca não instalada, ou instalada sem os arquivos de desenvolvimento (pacote `-dev`/`-devel`)
    - Instalada em um prefixo que o CMake não pesquisa (`/opt/fila`, `~/.local`)
    - A biblioteca não fornece `Config.cmake`, só um `.pc` do pkg-config
    - Nome com maiúsculas diferentes do instalado (`Fila` x `fila`)
4. **Investigar**:
    - `cmake -S . -B build --debug-find-pkg=Fila` lista cada caminho tentado
    - `find / -name "*ila*onfig.cmake" 2>/dev/null`
    - `pkg-config --list-all | grep fila`
5. **Corrigir**: `-DCMAKE_PREFIX_PATH=/opt/fila`, `-DFila_DIR=.../lib/cmake/Fila`, instalar o pacote `-dev`, ou usar `pkg_check_modules` (ver `dependencies.md`)

---

**Cannot specify link libraries for target**

```text
CMake Error at CMakeLists.txt:8 (target_link_libraries):
  Cannot specify link libraries for target "app" which is not built by this
  project.
```

1. **Significado**: um comando `target_*` foi chamado para um target que ainda não existe
2. **Fase**: configure
3. **Causas**:
    - `target_link_libraries(app ...)` escrito **antes** do `add_executable(app ...)`
    - Nome do target diferente do criado (`app` x `App`)
    - O target é criado em um `if` que não foi executado
4. **Investigar**: procurar o `add_executable`/`add_library` com o mesmo nome
5. **Corrigir**: criar o target antes de configurá-lo. Só o **primeiro** argumento precisa existir antes: as bibliotecas linkadas podem ser criadas depois

---

**Target links to ... but the target was not found**

```text
CMake Error at CMakeLists.txt:8 (target_link_libraries):
  Target "app" links to:

    Fila::fila

  but the target was not found.  Possible reasons include:

    * There is a typo in the target name.
    * A find_package call is missing for an IMPORTED target.
    * An ALIAS target is missing.
```

1. **Significado**: um nome com `::` foi usado em `target_link_libraries`, mas nenhum target com esse nome existe
2. **Fase**: generate
3. **Causas**:
    - Faltou o `find_package(Fila)` antes
    - Nome do target importado diferente do que o pacote cria (consulte a documentação do pacote)
    - `find_package` sem `REQUIRED` falhou em silêncio
4. **Investigar**: `cmake --help-module FindNome` ou o `FilaTargets.cmake` instalado mostram os nomes dos targets criados
5. **Corrigir**: adicionar o `find_package` com `REQUIRED` ou corrigir o nome

---

**another target with the same name already exists**

```text
CMake Error at src/CMakeLists.txt:1 (add_library):
  add_library cannot create target "fila" because another target with the
  same name already exists.  The existing target is a static library created
  in source directory "/home/u/projeto/externo/fila".
```

1. **Significado**: nomes de targets são globais e dois diretórios criaram o mesmo nome
2. **Fase**: configure
3. **Causas**:
    - Uma dependência adicionada com `add_subdirectory`/`FetchContent` usa o mesmo nome de um target do projeto
    - O mesmo `add_subdirectory` chamado duas vezes
4. **Investigar**: a mensagem diz onde o primeiro foi criado
5. **Corrigir**: renomear o target do projeto (com prefixo, ex: `meuapp_fila`) e usar `OUTPUT_NAME` para manter o nome do arquivo. Proteger chamadas repetidas com `if(NOT TARGET fila)`

---

**Compatibility with `CMake < 3.5` has been removed**

```text
CMake Error at CMakeLists.txt:1 (cmake_minimum_required):
  Compatibility with CMake < 3.5 has been removed from CMake.

  Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
  to tell CMake that the project requires at least <min> but has been updated
  to work with policies introduced by <max> or earlier.

  Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.
```

1. **Significado**: o projeto (ou uma dependência) declara uma versão mínima antiga demais
2. **Fase**: configure, a partir do CMake 4.0
3. **Causas**: `cmake_minimum_required(VERSION 2.8)` ou `3.1`, comum em dependências antigas
4. **Investigar**: a linha indicada mostra qual `CMakeLists.txt` declara a versão
5. **Corrigir**: atualizar para `cmake_minimum_required(VERSION 3.20)` no próprio projeto. Para uma dependência que você não controla, configurar com `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` (ver `policies.md`)

---

**generator does not match / CMakeCache.txt directory is different**

```text
CMake Error: Error: generator : Ninja
Does not match the generator used previously: Unix Makefiles
Either remove the CMakeCache.txt file and CMakeFiles directory or choose a different binary directory.
```

```text
CMake Error: The current CMakeCache.txt directory /home/u/novo/build/CMakeCache.txt is different than the directory /home/u/projeto/build where CMakeCache.txt was created.
```

1. **Significado**: o diretório de build tem um cache de outra configuração
2. **Fase**: configure
3. **Causas**:
    - Trocar o `-G` em um diretório já configurado
    - Mover ou copiar o projeto junto com o diretório de build
4. **Investigar**: `grep CMAKE_GENERATOR build/CMakeCache.txt`
5. **Corrigir**: `cmake --fresh -S . -B build -G Ninja` ou apagar o diretório de build

---

**header not found / undefined reference no build**

```text
/home/u/projeto/app/main.c:1:10: fatal error: fila.h: No such file or directory
/usr/bin/ld: main.c.o: undefined reference to `fila_criar'
/usr/bin/ld: fila.c.o: undefined reference to `sqrt'
```

1. **Significado**: o configure passou, mas o compilador ou o linker não recebeu o `-I` ou a biblioteca
2. **Fase**: build
3. **Causas**:
    - Faltou `target_link_libraries(app PRIVATE fila)`
    - A biblioteca declarou o `include` como `PRIVATE`, e ele não chega a quem a usa
    - Faltou `m` para funções de `math.h`
    - O `.c` com a função não foi listado no `add_library`
4. **Investigar**: `cmake --build build -v` mostra os `-I` e as bibliotecas de cada comando
5. **Corrigir**: adicionar o `target_link_libraries` que falta ou trocar o include para `PUBLIC` (ver `targets.md`). Os erros de compilação e link em si estão em `compilers/gcc/cheatsheet/common-errors.md`

> Leia sempre o **primeiro** `CMake Error` da saída: os seguintes costumam ser consequência dele. Depois de corrigir um erro de compilador, pacote ou generator, rode o configure com `--fresh`, porque o valor errado ou o `NOTFOUND` continua gravado no cache
