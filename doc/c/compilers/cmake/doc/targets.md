**Targets**

> executáveis, bibliotecas e os requisitos de uso que eles propagam

Um `target` é algo que o build produz: um executável ou uma biblioteca. No CMake moderno, todas as configurações de compilação (includes, defines, flags, bibliotecas) pertencem a um target, e não ao projeto inteiro. Cada configuração pode ser marcada para valer só para o próprio target ou também para quem o usa

```cmake
add_library(fila STATIC src/fila.c)
target_include_directories(fila PUBLIC include)
target_compile_definitions(fila PRIVATE FILA_INTERNO)

add_executable(app src/main.c)
target_link_libraries(app PRIVATE fila)    # app recebe -Iinclude automaticamente
```

```text
gcc -DFILA_INTERNO -Iinclude -c src/fila.c       # fila: PRIVATE + PUBLIC
ar rcs libfila.a fila.o
gcc -Iinclude -c src/main.c                       # app: só o PUBLIC da fila
gcc main.o libfila.a -o app
```

---

**Criando targets**

```cmake
add_executable(app src/main.c src/lista.c)
add_library(fila STATIC src/fila.c)       # ver libraries.md
target_sources(app PRIVATE src/utils.c)   # adiciona fontes depois de criar
```

- O nome do target é único em todo o projeto e é usado por todos os comandos `target_*`
- O arquivo gerado recebe o nome do target: `app`, `libfila.a`, `libfila.so`. Para mudar: `set_target_properties(app PROPERTIES OUTPUT_NAME meu_app)`
- Headers não precisam estar na lista de fontes para compilar, mas listá-los faz com que apareçam nas IDEs

---

**Comandos `target_*`**

| Comando | Equivale a | Exemplo |
|---|---|---|
| `target_include_directories` | `-I` | `target_include_directories(app PRIVATE include)` |
| `target_compile_definitions` | `-D` | `target_compile_definitions(app PRIVATE VERSAO=2)` |
| `target_compile_options` | flags de compilação | `target_compile_options(app PRIVATE -Wall)` |
| `target_compile_features` | `-std` mínimo | `target_compile_features(app PRIVATE c_std_17)` |
| `target_link_libraries` | `-l`, `.a`, `.so` | `target_link_libraries(app PRIVATE fila m)` |
| `target_link_options` | flags de link | `target_link_options(app PRIVATE -Wl,--as-needed)` |
| `target_link_directories` | `-L` | `target_link_directories(app PRIVATE /opt/lib)` |
| `target_sources` | arquivos `.c` | `target_sources(app PRIVATE extra.c)` |

- Caminhos relativos em `target_include_directories` são relativos ao `CMAKE_CURRENT_SOURCE_DIR`
- Em `target_compile_definitions`, escreva sem o `-D`: `DEBUG`, `VERSAO=2`
- Evite `target_link_directories`: prefira passar o target ou o caminho completo da biblioteca

---

**PRIVATE, PUBLIC e INTERFACE**

```text
                    usado ao compilar     repassado a quem
                    o próprio target      linka com o target
PRIVATE                   sim                   não
PUBLIC                    sim                   sim
INTERFACE                 não                   sim
```

- **PRIVATE**: detalhe de implementação. Ex: um define usado só dentro de `fila.c`, ou uma biblioteca usada só no `.c` e nunca aparece nos headers públicos
- **PUBLIC**: faz parte da interface. Ex: o diretório `include/` com `fila.h`, que quem usa a fila também precisa para compilar
- **INTERFACE**: só para quem usa. Ex: bibliotecas `header-only` que não compilam nada (ver `libraries.md`)

```cmake
add_library(fila STATIC src/fila.c)
target_include_directories(fila
    PUBLIC  include          # fila.h é incluído por quem usa a fila
    PRIVATE src              # headers internos, só para fila.c
)
target_link_libraries(fila
    PUBLIC  Threads::Threads # fila.h expõe pthread_mutex_t
    PRIVATE m                # sqrt só é usada dentro de fila.c
)
```

> Regra prática: se algo aparece em um header público, é `PUBLIC`. Se aparece só nos `.c`, é `PRIVATE`

---

**Propagação transitiva**

```text
app ──PRIVATE──> servidor ──PUBLIC──> fila ──PUBLIC──> Threads::Threads
```

- `app` recebe tudo que é `PUBLIC`/`INTERFACE` de `servidor`, e também tudo que `servidor` recebeu como `PUBLIC` de `fila`, e assim por diante
- Um `PRIVATE` interrompe a cadeia. Se `servidor` linkasse `fila` como `PRIVATE`, o `app` não receberia o `include/` da fila (mas a `libfila.a` ainda seria linkada, porque o linker precisa dela)
- Isso substitui a necessidade de repetir `-I` e `-l` em cada executável

---

**Comandos globais (evitar)**

```cmake
include_directories(include)       # vale para todos os targets do diretório e subdiretórios
add_definitions(-DDEBUG)
add_compile_options(-Wall)
link_libraries(m)
```

- Afetam todo target criado **depois** no mesmo diretório e nos subdiretórios, inclusive bibliotecas de terceiros adicionadas com `add_subdirectory`
- Não propagam para quem usa o target, então quebram quando o projeto é usado por outro
- `add_compile_options` para warnings é a única exceção comum e aceitável (ver `compiler-flags.md`)

---

**Alias**

```cmake
add_library(fila STATIC src/fila.c)
add_library(Fila::fila ALIAS fila)

target_link_libraries(app PRIVATE Fila::fila)
```

- Um alias é outro nome, somente leitura, para o mesmo target
- Nomes com `::` são sempre tratados como targets. Se `Fila::fila` não existir, o CMake dá erro no configure. Já um nome simples errado (`filaa`) seria passado ao linker como `-lfilaa` e só falharia no link
- O padrão `Projeto::target` é o mesmo nome que o target recebe quando é instalado e encontrado com `find_package` (ver `packages.md`), então quem usa a biblioteca escreve o mesmo nome nos dois casos

> `target_link_libraries` aceita três coisas: o nome de um target (que traz junto todos os seus requisitos de uso), o caminho completo de um arquivo (`/opt/lib/libfila.a`) ou um nome simples (`m`), que vira `-lm`. Prefira sempre targets, porque só eles carregam includes e defines junto com a biblioteca
