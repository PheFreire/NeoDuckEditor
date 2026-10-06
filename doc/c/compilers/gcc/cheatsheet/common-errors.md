**Erros comuns de compilação e linking**

> como reconhecer a etapa e corrigir

Cada erro vem de uma etapa diferente do pipeline (ver `compilation-pipeline.md`), e saber qual etapa reclamou já diz metade da solução: o preprocessor reclama de **arquivos**, o compilador reclama de **código**, o linker reclama de **símbolos e bibliotecas** e o loader reclama de **bibliotecas em tempo de execução**

```text
fatal error: x.h: No such file or directory   → preprocessor
main.c:10:5: error: ...                        → compilador
undefined reference / ld: ... / collect2       → linker
error while loading shared libraries           → loader (ao rodar ./app)
```

---

**undefined reference to `soma'**

```text
/usr/bin/ld: main.o: in function `main': main.c:(.text+0x1f): undefined reference to `soma'
collect2: error: ld returned 1 exit status
# macOS: Undefined symbols for architecture arm64: "_soma", referenced from: _main in main.o
```

1. **Significado**: o código usa `soma`, mas nenhum arquivo entregue ao linker a define
2. **Etapa**: linking
3. **Causas**:
    - Faltou passar o `.c`/`.o` que define a função (`gcc main.c` em vez de `gcc main.c soma.c`)
    - Faltou a biblioteca (`-lm` para `sqrt`, `-pthread` para `pthread_create`)
    - `-l` antes dos arquivos que a usam
    - Função definida como `static` em outro arquivo
    - Nome digitado diferente
    - Código C++ chamado de C sem `extern "C"`
4. **Investigar**:
    - `nm -A *.o | grep soma` para ver quem tem `U soma` e quem tem `T soma`
    - `gcc -v` para ver o comando completo do linker
5. **Corrigir**: adicionar o arquivo ou a `-l` que faltava, colocar as `-l` no final do comando, remover o `static`

---

**multiple definition of `contador'**

```text
/usr/bin/ld: b.o:(.bss+0x0): multiple definition of `contador'; a.o:(.bss+0x0): first defined here
```

1. **Significado**: dois arquivos definem o mesmo símbolo global
2. **Etapa**: linking
3. **Causas**:
    - Variável ou função **definida** em um header incluído por vários `.c` (`int contador;` ou o corpo de uma função no `.h`). Include guards **não** evitam esse erro (ver `preprocessor.md`)
    - O mesmo `.c` passado duas vezes no comando
    - Duas funções globais com o mesmo nome em arquivos diferentes
4. **Investigar**: `nm -A *.o | grep contador` mostra cada `D`/`B`/`T` duplicado
5. **Corrigir**: deixar só `extern int contador;` no header e definir em um único `.c`. Marcar como `static` o que é interno a um arquivo. Funções em header devem ser `static inline` (ver `symbols.md`)

---

**implicit declaration of function 'soma'**

```text
main.c:5:3: warning: implicit declaration of function 'soma' [-Wimplicit-function-declaration]
main.c:5:3: error: implicit declaration of function 'soma' [-Wimplicit-function-declaration]   (GCC 14+)
```

1. **Significado**: a função foi chamada sem nenhuma declaração visível antes. No C antigo, o compilador assumia `int soma()`, com qualquer argumento
2. **Etapa**: compilação
3. **Causas**:
    - Faltou o `#include` do header (ex: `string.h` para `strlen`, `stdlib.h` para `malloc`)
    - A função é definida mais abaixo no mesmo arquivo
    - Erro de digitação no nome
4. **Investigar**: `man 3 nome_da_funcao` mostra qual header incluir
5. **Corrigir**: incluir o header certo ou declarar a função antes do uso. Nunca ignore este aviso: se o tipo real for diferente de `int` (como o `void *` do `malloc`), o valor de retorno é corrompido. A partir do GCC 14 ele é erro por padrão

---

**header not found**

```text
main.c:1:10: fatal error: lista.h: No such file or directory
    1 | #include "lista.h"
compilation terminated.
```

1. **Significado**: o preprocessor não encontrou o arquivo em nenhum diretório de busca
2. **Etapa**: preprocessing
3. **Causas**:
    - O header está em outra pasta (ex: `include/`) e faltou `-Iinclude`
    - Nome ou caminho errado
    - Header de uma biblioteca externa não instalado (no Linux, normalmente falta o pacote `-dev`/`-devel`, ex: `libssl-dev`)
    - No macOS, Command Line Tools ausentes ou headers do Homebrew em `/opt/homebrew/include`
4. **Investigar**:
    - `gcc -xc -E -v - < /dev/null` lista os diretórios onde ele procura
    - `find / -name lista.h 2>/dev/null`
    - `pkg-config --cflags nome` para bibliotecas externas
5. **Corrigir**: adicionar `-I` com o diretório certo, instalar o pacote de desenvolvimento, ou usar `$(pkg-config --cflags --libs nome)`

---

**library not found**

```text
/usr/bin/ld: cannot find -lfila: No such file or directory
# macOS: ld: library 'fila' not found
```

1. **Significado**: o linker não encontrou `libfila.so`/`libfila.a` (ou `.dylib`) em nenhum diretório de busca
2. **Etapa**: linking
3. **Causas**:
    - Faltou `-L` com o diretório da biblioteca
    - Nome errado (`-llibfila` em vez de `-lfila`)
    - Biblioteca não instalada
    - No Linux, só existe `libfila.so.1` e falta o link `libfila.so` do pacote `-dev`
4. **Investigar**:
    - `gcc main.o -lfila -Wl,--verbose 2>&1 | grep fila` mostra cada caminho tentado (GNU ld)
    - `ls` no diretório esperado
5. **Corrigir**: adicionar `-L/caminho`, instalar o pacote de desenvolvimento, ou usar `pkg-config --libs nome`. No Homebrew (Apple Silicon), as bibliotecas ficam em `/opt/homebrew/lib`

---

**error while loading shared libraries** (ao executar)

```text
./app: error while loading shared libraries: libfila.so: cannot open shared object file: No such file or directory
# macOS: dyld: Library not loaded: @rpath/libfila.dylib
```

1. **Significado**: o programa linkou, mas o dynamic loader não encontrou a biblioteca ao executar
2. **Etapa**: carregamento (loader), fora do GCC
3. **Causas**:
    - A biblioteca está em um diretório que o loader não pesquisa
    - O `-L` só vale no link e não é lembrado depois
4. **Investigar**: `ldd ./app` (Linux) ou `otool -L ./app` (macOS) mostram o que falta
5. **Corrigir**: linkar com `-Wl,-rpath,<dir>`, instalar a biblioteca em um diretório padrão e rodar `sudo ldconfig`, ou (para testes) `LD_LIBRARY_PATH=<dir> ./app`. Ver `libraries.md`

> Sempre leia o **primeiro** erro da saída: em C, um único `;` faltando ou um header não encontrado gera uma cascata de erros seguintes que desaparecem quando o primeiro é corrigido. `-Wfatal-errors` faz o GCC parar no primeiro erro
