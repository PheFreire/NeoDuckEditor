**ctest**

> ferramenta de linha de comando, vem com o CMake

O `ctest` executa os testes registrados com `add_test` e mostra quais passaram e quais falharam, considerando aprovado o teste cujo programa termina com código de saída `0`

```bash
ctest --test-dir <diretório de build> [opções]
```

- `--test-dir`: o diretório de build. Sem ele, o `ctest` usa o diretório atual
- `--output-on-failure`: mostra a saída dos testes que falharam
- `-R <regex>` / `-E <regex>`: roda só os testes cujo nome casa, ou não casa, com a expressão
- `-L <label>`: roda só os testes com um rótulo
- `-j <N>`: roda `N` testes em paralelo
- `-V`: mostra a saída de todos os testes
- `--rerun-failed`: roda de novo só os que falharam na última vez
- `-C <tipo>`: o build type, nos generators com vários build types

- Não compila nada. Rode o `cmake --build` antes, ou o `ctest` executa a versão antiga dos testes
- `No tests were found` quer dizer que falta o `enable_testing` no `CMakeLists.txt` raiz

```bash
cmake --build build
ctest --test-dir build --output-on-failure
ctest --test-dir build -R lista          # só os testes com "lista" no nome
```

```text
1/2 Test #1: lista ............   Passed    0.01 sec
2/2 Test #2: lista_arquivo ....***Failed    0.01 sec

50% tests passed, 1 tests failed out of 2
```
