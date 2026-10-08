**Policies**

> `cmake_minimum_required`, compatibilidade entre versões e CMP0xxx

O CMake muda o comportamento de comandos entre versões, mas não pode quebrar projetos antigos. Cada mudança de comportamento é uma `policy` com um número (`CMP0077`) e dois estados: `OLD` (comportamento antigo) e `NEW` (comportamento novo). O `cmake_minimum_required` decide quais policies ficam `NEW`: todas as introduzidas até a versão declarada

```cmake
cmake_minimum_required(VERSION 3.20)
```

```text
CMP0001 ... CMP0120   introduzidas até a 3.20     → NEW
CMP0121 em diante     introduzidas depois         → não definidas (OLD com aviso)
```

- O comando faz duas coisas: dá erro se o CMake instalado for mais antigo que a versão e configura as policies
- Deve ser a primeira linha do `CMakeLists.txt` raiz, antes do `project()`

---

**Faixa de versões**

```cmake
cmake_minimum_required(VERSION 3.20...3.31)
```

- O projeto exige no mínimo a 3.20, mas foi testado até a 3.31
- Policies até a 3.31 ficam `NEW` quando o CMake instalado é 3.31 ou mais novo. Em um CMake 3.25, valem as policies até a 3.25
- Evita avisos de policies novas sem perder compatibilidade com versões mais antigas

---

**Aviso de policy**

```text
CMake Warning (dev) at CMakeLists.txt:10 (option):
  Policy CMP0077 is not set: option() honors normal variables.  Run "cmake
  --help-policy CMP0077" for policy details.  Use the cmake_policy command to
  set the policy and suppress this warning.
This warning is for project developers.  Use -Wno-dev to suppress it.
```

- Aparece quando o projeto usa um comportamento que mudou depois da versão declarada
- O CMake usa o comportamento `OLD` e avisa
- `cmake --help-policy CMP0077` explica a diferença entre `OLD` e `NEW`

---

**`cmake_policy`**

```cmake
cmake_policy(SET CMP0135 NEW)         # define uma policy específica

if(POLICY CMP0135)                    # só se a versão instalada a conhecer
    cmake_policy(SET CMP0135 NEW)
endif()

cmake_policy(PUSH)                    # salva o estado atual
cmake_policy(SET CMP0077 OLD)
include(antigo.cmake)
cmake_policy(POP)                     # restaura
```

- `SET` em uma policy que a versão instalada não conhece é erro. Por isso o `if(POLICY ...)`
- Uma `function` usa as policies de onde foi **definida**, e não de onde foi chamada

```bash
cmake -S . -B build -DCMAKE_POLICY_DEFAULT_CMP0135=NEW   # padrão para quem não definiu
```

---

**CMake 4**

A versão 4.0 removeu o suporte a projetos que declaram `cmake_minimum_required` abaixo de 3.5. As policies anteriores a essa versão só existem como `NEW`

```bash
cmake -S . -B build -DCMAKE_POLICY_VERSION_MINIMUM=3.5
```

- Faz o CMake tratar qualquer versão mínima abaixo de 3.5 como 3.5. É uma saída para dependências antigas que ainda não foram atualizadas
- Também pode ser definida como variável de ambiente (`CMAKE_POLICY_VERSION_MINIMUM=3.5`)
- O correto é atualizar o `cmake_minimum_required` do projeto

---

**Escolhendo a versão mínima**

| Versão | Recursos que a justificam |
|---|---|
| 3.13 | `-S`/`-B`, `target_link_options` |
| 3.14 | `FetchContent_MakeAvailable`, `install(TARGETS)` sem `DESTINATION` |
| 3.15 | `cmake --install`, `$<C_COMPILER_ID:a,b>` |
| 3.19 | presets |
| 3.20 | `cmake_path`, `ctest --test-dir` |
| 3.21 | `C_STANDARD 23`, `PROJECT_IS_TOP_LEVEL`, `--toolchain` |
| 3.23 | `FILE_SET HEADERS` |
| 3.24 | `--fresh`, `COMPILE_WARNING_AS_ERROR`, `FIND_PACKAGE_ARGS` |
| 3.25 | `LINUX`, `SYSTEM`, workflow presets, `block()` |

> Declare a menor versão que tem os recursos que o projeto realmente usa, e não a versão instalada na sua máquina. Uma versão mínima muito alta impede que o projeto seja compilado em distros mais antigas, e uma muito baixa ativa comportamentos `OLD` sem você perceber
