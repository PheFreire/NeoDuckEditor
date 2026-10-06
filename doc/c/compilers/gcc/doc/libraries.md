**Bibliotecas**

> bibliotecas estáticas (`.a`) e compartilhadas (`.so` / `.dylib`)

Uma biblioteca é código já compilado, empacotado para ser reaproveitado por vários programas. Existem dois tipos, e a diferença está em **quando** o código dela entra no programa: na hora do link (estática) ou na hora em que o programa é executado (compartilhada)

```text
ESTÁTICA (.a)                          COMPARTILHADA (.so / .dylib)
link:  main.o + libfila.a              link:  main.o + libfila.so
         │                                      │
         ▼                                      ▼
  app (contém o código da fila)         app (contém só "preciso de libfila.so")
         │                                      │
run:   ./app (não precisa de nada)      run:   ./app → loader carrega libfila.so
```

| | Estática | Compartilhada |
|---|---|---|
| Linux | `libfila.a` | `libfila.so` |
| macOS | `libfila.a` | `libfila.dylib` |
| O código vai para | dentro do executável | um arquivo separado, carregado ao executar |
| Executável | maior, autossuficiente | menor, depende da biblioteca existir |
| Atualizar a biblioteca | precisa linkar o programa de novo | basta trocar o arquivo |
| Memória | cada processo tem sua cópia | o código é compartilhado entre processos |

---

**Biblioteca estática (.a)**

Um `.a` é só um arquivo (`archive`) contendo vários `.o`, criado com o `ar`:

```bash
gcc -c fila.c pilha.c                # gera fila.o e pilha.o
ar rcs libestruturas.a fila.o pilha.o
gcc main.c -L. -lestruturas -o app
```

- `ar rcs`: `r` insere/substitui os `.o`, `c` cria o arquivo se não existir, `s` gera o índice de símbolos usado pelo linker
- O linker copia para o executável apenas os `.o` do `.a` que resolvem algum símbolo indefinido, e não a biblioteca inteira. Por isso a ordem dos argumentos importa (ver `linking.md`)
- `ar t libestruturas.a` lista os `.o` dentro dele. `nm libestruturas.a` lista os símbolos de cada um

---

**Biblioteca compartilhada (.so / .dylib)**

```bash
# Linux
gcc -fPIC -c fila.c pilha.c
gcc -shared fila.o pilha.o -o libestruturas.so
gcc main.c -L. -lestruturas -o app

# macOS
gcc -fPIC -c fila.c pilha.c
gcc -dynamiclib fila.o pilha.o -o libestruturas.dylib
gcc main.c -L. -lestruturas -o app
```

- `-fPIC` (Position Independent Code): gera código que funciona em qualquer endereço, pois a biblioteca pode ser carregada em lugares diferentes em cada processo. No macOS e em várias distros Linux modernas já é o padrão
- `-shared` / `-dynamiclib`: diz ao linker para gerar uma biblioteca, e não um executável (sem `main`, sem `_start`)
- No link, o código **não** é copiado: o linker apenas confere que os símbolos existem e grava no executável o nome da biblioteca necessária

---

**Carregamento em tempo de execução**

Quando o programa roda, o dynamic loader (`ld-linux.so` no Linux, `dyld` no macOS) encontra e carrega as bibliotecas antes do `main`. Se não encontrar:

```text
./app: error while loading shared libraries: libestruturas.so: cannot open shared object file
```

- **Linux**: procura no `rpath`/`runpath` gravado no executável, em `LD_LIBRARY_PATH`, no cache do `ldconfig` (`/etc/ld.so.cache`) e em `/lib` e `/usr/lib`. O `-L` só vale na hora do link, o loader não o conhece
- **macOS**: cada `.dylib` tem um `install name` (caminho gravado nela, ex: `@rpath/libestruturas.dylib`) que é copiado para o executável. O `dyld` usa esse caminho, resolvendo `@rpath`, `@executable_path` e `@loader_path`. `DYLD_LIBRARY_PATH` existe, mas é ignorado em binários protegidos pelo SIP

```bash
gcc main.c -L. -lestruturas -Wl,-rpath,'$ORIGIN' -o app          # Linux: procura ao lado do executável
gcc main.c -L. -lestruturas -Wl,-rpath,@executable_path -o app   # macOS: equivalente
ldd ./app          # Linux: lista as bibliotecas e onde cada uma foi encontrada
otool -L ./app     # macOS: lista as dylibs necessárias
```

---

**Static linking vs dynamic linking**

- Por padrão, o GCC linka dinamicamente com a libc e com qualquer `-l` que tenha `.so` disponível
- `gcc -static main.c -o app` (Linux) gera um executável sem nenhuma dependência dinâmica, que roda em qualquer Linux da mesma arquitetura. Fica bem maior e não recebe correções de segurança da libc do sistema. A glibc tem limitações com `-static` (como funções de rede/`getpwnam`). A `musl` é mais usada para isso
- No macOS, executáveis totalmente estáticos **não são suportados**: a `libSystem` (que contém a libc) só existe como dinâmica. Bibliotecas `.a` próprias continuam podendo ser linkadas estaticamente
- Para forçar o `.a` de uma biblioteca específica no Linux quando também existe o `.so`: `-Wl,-Bstatic -lfila -Wl,-Bdynamic`, ou passe o caminho do `.a` diretamente

> Uma biblioteca compartilhada no Linux costuma ter três nomes: `libfila.so.1.2.0` (o arquivo real), `libfila.so.1` (o `soname`, gravado no executável, que muda só quando a ABI quebra) e `libfila.so` (link simbólico usado apenas pelo `-lfila` na hora do link, vindo normalmente do pacote `-dev`). Isso permite atualizar a biblioteca sem recompilar os programas que a usam
