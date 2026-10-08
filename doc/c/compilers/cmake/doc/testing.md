**Testes**

> `enable_testing`, `add_test` e ctest

O CMake registra testes como comandos que devem terminar com código de saída `0`. Quem executa os testes é o `ctest`, que vem junto com o CMake. Ele não é um framework de testes: um teste pode ser um executável em C com `assert`, um script ou qualquer outro programa

```cmake
enable_testing()

add_executable(test_fila tests/test_fila.c)
target_link_libraries(test_fila PRIVATE fila)

add_test(NAME fila COMMAND test_fila)
```

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build
```

```text
    Start 1: fila
1/1 Test #1: fila .............................   Passed    0.01 sec

100% tests passed, 0 tests failed out of 1
```

- Um teste **passa** quando o processo termina com `0` e **falha** com qualquer outro código ou com um crash (como um `assert` que falhou ou um segfault)

> Como escrever testes em C sem framework está em `doc/c/tests/`

---

**`enable_testing` e `include(CTest)`**

```cmake
enable_testing()        # habilita o ctest para este diretório e os abaixo
```

```cmake
include(CTest)          # chama enable_testing() e cria a opção BUILD_TESTING
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
```

- `enable_testing()` deve estar no `CMakeLists.txt` raiz. Sem ele, o `ctest` diz `No tests were found`
- `include(CTest)` cria a opção `BUILD_TESTING` (ligada por padrão), que permite desligar os testes com `-DBUILD_TESTING=OFF`
- Em bibliotecas usadas por outros projetos, combine com `PROJECT_IS_TOP_LEVEL` para não compilar os testes da dependência (ver `subdirectories.md`)

---

**`add_test`**

```cmake
add_test(NAME fila_vazia COMMAND test_fila vazia)          # argumentos para o programa
add_test(NAME fila_cheia COMMAND test_fila cheia)
add_test(NAME arquivo
    COMMAND test_io ${CMAKE_CURRENT_SOURCE_DIR}/dados/entrada.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
```

- Se o `COMMAND` é o nome de um target, o CMake troca pelo caminho completo do executável
- O mesmo executável pode ser registrado várias vezes com argumentos diferentes, cada um como um teste separado
- O diretório de trabalho padrão é o `CMAKE_CURRENT_BINARY_DIR`, então caminhos para arquivos do código devem ser absolutos

---

**Propriedades de teste**

```cmake
set_tests_properties(fila_cheia PROPERTIES
    TIMEOUT 5                          # falha se passar de 5 segundos
    LABELS "unitario;rapido"           # grupos para filtrar com -L
    WILL_FAIL TRUE                     # passa se o programa falhar
    ENVIRONMENT "FILA_DEBUG=1"         # variáveis de ambiente do teste
    PASS_REGULAR_EXPRESSION "ok"       # passa se a saída casar com a regex
    FAIL_REGULAR_EXPRESSION "ERRO"     # falha se a saída casar com a regex
    DEPENDS fila_vazia                 # roda depois de outro teste
)
```

- Com `PASS_REGULAR_EXPRESSION`, o código de saída é ignorado e só a saída decide
- `WILL_FAIL` serve para testar que o programa detecta erros (ex: um `assert` que deve disparar)

---

**ctest**

```bash
ctest --test-dir build                     # roda todos
ctest --test-dir build --output-on-failure # mostra a saída dos que falharam
ctest --test-dir build -R fila             # só os que casam com a regex no nome
ctest --test-dir build -E lento            # exclui pela regex
ctest --test-dir build -L unitario         # só os de um label
ctest --test-dir build -j 8                # 8 testes em paralelo
ctest --test-dir build --rerun-failed      # só os que falharam da última vez
ctest --test-dir build -V                  # saída completa de todos
ctest --test-dir build -N                  # lista sem executar
ctest --test-dir build -C Debug            # obrigatório em generators multi-config
```

- `--test-dir` (3.20+) evita precisar entrar no diretório de build. Em versões antigas: `cd build && ctest`
- `export CTEST_OUTPUT_ON_FAILURE=1` deixa o `--output-on-failure` ligado sempre
- A saída de cada execução fica em `build/Testing/Temporary/LastTest.log`

---

**Testes com sanitizers e valgrind**

```bash
cmake -S . -B build-asan -DCMAKE_BUILD_TYPE=Debug -DUSAR_SANITIZERS=ON
cmake --build build-asan
ctest --test-dir build-asan --output-on-failure

ctest --test-dir build -T memcheck          # roda cada teste dentro do valgrind
```

- Um diretório de build separado com sanitizers ligados (ver `compiler-flags.md`) roda os mesmos testes procurando erros de memória e comportamento indefinido
- O `-T memcheck` usa o `valgrind` se ele estiver instalado e o projeto usar `include(CTest)`

> O `ctest` não compila nada. Rodar `ctest` depois de editar um `.c` executa o binário antigo. Sempre rode `cmake --build build` antes, ou use os dois juntos: `cmake --build build && ctest --test-dir build --output-on-failure`
