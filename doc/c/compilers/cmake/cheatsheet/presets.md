**Presets**

> CMakePresets.json e CMakeUserPresets.json

Presets guardam em um arquivo JSON as opções que normalmente seriam digitadas na linha de comando: generator, diretório de build, build type e variáveis de cache. Em vez de lembrar de `cmake -S . -B build-debug -G Ninja -DCMAKE_BUILD_TYPE=Debug -DUSAR_SANITIZERS=ON`, basta `cmake --preset debug`

```bash
cmake --list-presets          # presets de configure disponíveis
cmake --preset debug          # configure
cmake --build --preset debug  # build
ctest --preset debug          # testes
cmake --workflow --preset dev # configure + build + test em sequência
```

- `CMakePresets.json`: fica na raiz do projeto e vai para o git. Contém presets que servem para todos
- `CMakeUserPresets.json`: preferências pessoais, fica fora do git (`.gitignore`). Pode herdar dos presets do projeto

---

**Estrutura**

```json
{
  "version": 6,
  "cmakeMinimumRequired": { "major": 3, "minor": 25, "patch": 0 },
  "configurePresets": [
    {
      "name": "base",
      "hidden": true,
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/${presetName}",
      "cacheVariables": {
        "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
      }
    },
    {
      "name": "debug",
      "inherits": "base",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug",
        "USAR_SANITIZERS": "ON"
      }
    },
    {
      "name": "release",
      "inherits": "base",
      "cacheVariables": { "CMAKE_BUILD_TYPE": "Release" }
    }
  ],
  "buildPresets": [
    { "name": "debug", "configurePreset": "debug" },
    { "name": "release", "configurePreset": "release" }
  ],
  "testPresets": [
    {
      "name": "debug",
      "configurePreset": "debug",
      "output": { "outputOnFailure": true }
    }
  ]
}
```

- `version`: versão do formato. `6` exige CMake 3.25+ e é a primeira com `workflowPresets`
- `hidden`: o preset não aparece na lista e só serve de base para outros
- `inherits`: copia os campos de outro preset (aceita uma lista)
- `binaryDir`: diretório de build. `${sourceDir}` e `${presetName}` são macros do próprio formato
- `cacheVariables`: o mesmo que `-D` na linha de comando

---

**Campos úteis do configure**

| Campo | Equivale a |
|---|---|
| `generator` | `-G` |
| `binaryDir` | `-B` |
| `cacheVariables` | `-D` |
| `toolchainFile` | `--toolchain` |
| `installDir` | `--install-prefix` |
| `environment` | variáveis de ambiente durante o configure |
| `condition` | só habilita o preset em certas plataformas |
| `warnings` / `errors` | `-Wdev`, `-Wdeprecated`... |

```json
{
  "name": "macos",
  "inherits": "base",
  "condition": { "type": "equals", "lhs": "${hostSystemName}", "rhs": "Darwin" },
  "environment": { "CC": "gcc-15" }
}
```

---

**Workflow**

```json
"workflowPresets": [
  {
    "name": "dev",
    "steps": [
      { "type": "configure", "name": "debug" },
      { "type": "build", "name": "debug" },
      { "type": "test", "name": "debug" }
    ]
  }
]
```

- `cmake --workflow --preset dev` roda os passos na ordem e para no primeiro que falhar
- Útil para CI: um único comando faz tudo

---

**Preset pessoal**

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "meu-debug",
      "inherits": "debug",
      "cacheVariables": { "CMAKE_C_FLAGS": "-march=native" }
    }
  ]
}
```

- `CMakeUserPresets.json` inclui implicitamente o `CMakePresets.json`, então pode herdar dos presets dele
- É o lugar certo para flags e caminhos que só existem na sua máquina

> Com `binaryDir` em `build/${presetName}`, cada preset ganha o seu diretório (`build/debug`, `build/release`), então trocar de preset nunca reaproveita um cache de outra configuração. Para o `clangd` encontrar o `compile_commands.json`, crie um link na raiz do projeto apontando para o preset que você mais usa (ver `debugging.md`)
