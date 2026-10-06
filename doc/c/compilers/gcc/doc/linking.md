**Linking**

> última etapa do pipeline, feita pelo `ld` (via `collect2`)

O linker junta vários arquivos objeto (`.o`) e bibliotecas em um único executável (ou biblioteca). Compilar trabalha com **um** `.c` por vez e só precisa das declarações. Linkar é a etapa que olha para **todos** os arquivos juntos e conecta cada uso de um nome à sua definição

```bash
gcc -c main.c lista.c           # compilação: gera main.o e lista.o
gcc main.o lista.o -lm -o app   # linking: gera o executável app
```

- No Linux, o `gcc` chama o `collect2`, que chama o `ld` do GNU binutils (ou outro linker, como `gold`, `lld` ou `mold`, com `-fuse-ld=`). No macOS, o linker é o `ld` da Apple (`ld64`/`ld-prime`)
- `gcc -v` mostra o comando completo do linker, incluindo tudo que o driver adiciona por conta própria

---

**O que o linker faz**

```text
 main.o            lista.o           libc
┌──────────┐      ┌──────────┐      ┌──────────┐
│ T main   │      │ T lista_ │      │ T printf │
│ U lista_ │─────►│   tamanho│      │ T malloc │
│ U printf │──────┼──────────┼─────►│   ...    │
└──────────┘      └──────────┘      └──────────┘
        │               │
        └───────┬───────┘
                ▼
     ┌─────────────────────┐
     │ app                 │
     │ .text = main.text   │
     │       + lista.text  │
     │ .data = ...         │
     │ entrada: _start     │
     └─────────────────────┘
```

1. **Resolução de símbolos**: para cada símbolo indefinido (`U`) de cada `.o`, procura um arquivo que o define. Se não achar: `undefined reference`. Se achar dois: `multiple definition`. Ver `symbols.md`
2. **Junção das sections**: concatena os `.text` de todos os `.o` em um `.text` final, os `.data` em um `.data`, e assim por diante
3. **Relocação**: com o layout definido, cada símbolo ganha um endereço, e o linker preenche os buracos marcados pelas relocations (ver `object-files.md`)
4. **Ponto de entrada**: define o `_start` (vindo do `crt1.o`) como a primeira instrução executada. É ele que chama o `main`
5. **Dependências dinâmicas**: para bibliotecas compartilhadas, não copia o código, apenas registra que o programa precisa delas em tempo de execução (ver `libraries.md`)

---

**-L e -l**

```bash
gcc main.o -L./lib -lfila -o app
```

- `-lfila`: procura um arquivo chamado `libfila.so` ou `libfila.a` (no macOS, `libfila.dylib`, `libfila.tbd` ou `libfila.a`). O prefixo `lib` e a extensão são adicionados automaticamente
- `-L./lib`: adiciona `./lib` aos diretórios pesquisados, antes dos padrões (`/usr/lib`, `/usr/local/lib`...)
- Se existirem o `.so` e o `.a` no mesmo diretório, o GNU ld prefere o `.so`
- A libc é linkada automaticamente. A `libm` (`math.h`) precisa de `-lm` no Linux, mas no macOS faz parte da `libSystem` e não precisa

---

**Ordem de linking**

O GNU ld lê os argumentos **da esquerda para a direita**. Ao encontrar uma biblioteca estática (`.a`), extrai dela apenas os `.o` que resolvem símbolos **já** indefinidos até aquele ponto, e não volta atrás:

```bash
gcc -lm main.c -o app   # ERRADO: quando leu -lm, ninguém precisava de sqrt ainda
gcc main.c -lm -o app   # certo: main.o pede sqrt, depois -lm fornece
```

- Regra: primeiro os seus `.c`/`.o`, depois as bibliotecas, e cada biblioteca **depois** das que dependem dela (`-lalto -lbaixo`)
- Dependência circular entre duas `.a`: repita a biblioteca (`-la -lb -la`) ou use `-Wl,--start-group -la -lb -Wl,--end-group`
- O linker do macOS é bem menos sensível à ordem, mas mantenha a ordem correta por portabilidade

---

**Erros típicos** (detalhes em `common-errors.md`)

```text
# Linux
/usr/bin/ld: main.o: in function `main': main.c:(.text+0x1f): undefined reference to `soma'
/usr/bin/ld: b.o:(.bss+0x0): multiple definition of `contador'; a.o:(.bss+0x0): first defined here
collect2: error: ld returned 1 exit status

# macOS
Undefined symbols for architecture arm64:
  "_soma", referenced from: _main in main.o
ld: symbol(s) not found for architecture arm64
```

- `undefined reference`: a função foi **declarada** (o compilador aceitou), mas nenhum arquivo do link a **define**: faltou um `.c`/`.o` no comando, faltou o `-l`, ou o nome está diferente
- `multiple definition`: dois arquivos definem o mesmo símbolo global, normalmente uma variável ou função definida dentro de um header incluído por vários `.c`

---

**Opções úteis**

```bash
gcc main.o -Wl,--verbose -o app     # mostra o linker script e onde procurou cada biblioteca
gcc main.o -Wl,-Map=app.map -o app  # gera um mapa com o endereço de cada símbolo
gcc main.o -Wl,--trace-symbol=soma  # mostra quem define e quem usa um símbolo (GNU ld)
```

> Uma forma simples de distinguir as etapas: se o erro cita uma linha do seu `.c` com `error:`, foi o compilador, e o código precisa mudar. Se cita `ld`, `collect2` ou `Undefined symbols`, o código compilou e o problema está em **quais arquivos e bibliotecas** foram entregues ao linker
