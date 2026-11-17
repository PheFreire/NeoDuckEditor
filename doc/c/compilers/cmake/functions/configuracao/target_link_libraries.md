**target_link_libraries**

> comando nativo do CMake, não precisa de include

O `target_link_libraries` liga bibliotecas a um target: no link ele recebe o código delas, e na compilação recebe os includes, macros e flags que elas marcaram como `PUBLIC` ou `INTERFACE`

```cmake
target_link_libraries(<target>
    <PRIVATE|PUBLIC|INTERFACE> <item>...
    [<PRIVATE|PUBLIC|INTERFACE> <item>...]
)
```

- `target`: o target que recebe as bibliotecas. Precisa ter sido criado antes
- `PRIVATE`, `PUBLIC`, `INTERFACE`: se a biblioteca passa adiante para quem linka o `target` (tabela abaixo)
- `item`: o que é linkado
	- um target do projeto: `lista`
	- um target importado: `Threads::Threads`
	- uma biblioteca do sistema pelo nome: `m` vira `-lm`
	- o caminho de um arquivo: `${FILA_LIB}` ou `/opt/fila/lib/libfila.a`
	- uma flag de link começando com `-`: `-pthread`

- Liga a biblioteca a **um** target. Cada target que usa a biblioteca precisa da própria linha
- Um item que é target pode ser criado depois desta linha, pois os nomes só são resolvidos no fim do configure
- Bibliotecas também linkam outras: `target_link_libraries(fila PUBLIC lista)`. Quem linka a `fila` recebe a `lista` junto
- A forma sem palavra-chave (`target_link_libraries(app lista)`) é antiga e não pode ser misturada com a forma nova no mesmo target

```cmake
add_library(lista STATIC lista.c)
target_include_directories(lista PUBLIC include)

find_package(Threads REQUIRED)

add_executable(app main.c)
target_link_libraries(app PRIVATE lista Threads::Threads m)
```

```text
gcc -Iinclude -c main.c -o main.o
gcc main.o liblista.a -pthread -lm -o app
```

---

**PRIVATE, PUBLIC e INTERFACE**

| Palavra-chave | Vale para o próprio target | Passa para quem o linka | Quando usar |
|---|---|---|---|
| `PRIVATE` | sim | não | a dependência só aparece nos `.c` |
| `PUBLIC` | sim | sim | a dependência aparece nos `.h` públicos |
| `INTERFACE` | não | sim | o target não compila nada (header-only) |

```cmake
target_link_libraries(fila PUBLIC lista)     # fila.h faz #include "lista/lista.h"
target_link_libraries(fila PRIVATE log)      # só fila.c usa o log
target_link_libraries(app PRIVATE fila)      # o app recebe fila e lista, mas não o log
```

- Em executáveis é sempre `PRIVATE`, pois ninguém linka um executável
- A mesma regra vale para `target_include_directories`, `target_compile_definitions` e `target_compile_options`

> `undefined reference to 'lista_criar'` quer dizer que o header foi encontrado, mas o código da função não chegou ao link: o `.c` não está em nenhum target, ou falta o `target_link_libraries` com a biblioteca que o contém
