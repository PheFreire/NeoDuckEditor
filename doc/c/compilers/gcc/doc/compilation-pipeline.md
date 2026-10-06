**Pipeline de compilação**

> etapas coordenadas pelo driver `gcc`

Transformar um `.c` em executável não é um passo único: o código passa por quatro etapas, cada uma feita por uma ferramenta diferente, e o resultado de uma é a entrada da próxima. O comando `gcc` apenas coordena essas ferramentas, apagando os arquivos intermediários no final

```text
main.c          código C escrito por você
   │
   │ 1. Preprocessor     (cc1 -E)       gcc -E
   ▼
main.i          C puro: headers colados, macros expandidas
   │
   │ 2. Compiler         (cc1)          gcc -S
   ▼
main.s          assembly em texto, específico da arquitetura
   │
   │ 3. Assembler        (as)           gcc -c
   ▼
main.o          código de máquina relocável + tabela de símbolos
   │
   │ 4. Linker           (collect2 → ld)  gcc
   ▼
main            executável (ELF no Linux, Mach-O no macOS)
   │
   │ 5. Loader           (kernel + ld-linux.so / dyld)   ./main
   ▼
processo
```
---

**1. Preprocessing** — `gcc -E main.c -o main.i`

- Trabalha só com texto, sem entender C: 
    - Cola o conteúdo dos `#include`
    - Expande os `#define`
    - Resolve os `#if`/`#ifdef`
    - Remove os comentários

- O `.i` resultante é um grande e unico arquivo C válido, sem nenhum `#`
- Sem `-o`, o `-E` escreve no `stdout`

> O unico "#" existente no arquivo `.i` são os marcadores de linha `# 1 "main.c"`, usados para os erros apontarem a linha original

> Ver `preprocessor.md`

---

**2. Compilation** — `gcc -S main.c` (gera `main.s`)

- É a etapa que realmente entende C: 
    - Análise sintática
    - Checagem de tipos
    - Warnings
    - Otimizações (`-O`)
    - Geração de assembly para a arquitetura alvo (x86-64, ARM64, etc..)

> O `.s` é texto legível, ótimo para ver o efeito de uma otimização
> A flag `-masm=intel` troca a sintaxe AT&T (padrão do GCC) pela Intel em x86

---

**3. Assembly** — `gcc -c main.c` (gera `main.o`)

- O assembler (`as`, do GNU binutils):
    - Traduz cada instrução de texto para bytes de código de máquina

> Endereços de funções e variáveis de outros arquivos ainda não são conhecidos: ficam como zeros acompanhados de uma `relocation`, uma anotação dizendo "preencha aqui com o endereço de `printf`"
> Ver `object-files.md`

---

**4. Linking** — `gcc main.o -o main`

- O linker (`ld`, chamado pelo `collect2` do GCC):
    - Junta todos os `.o`
    - Resolve cada símbolo indefinido encontrando quem o define
    - Aplica as relocations e define o ponto de entrada

- O driver adiciona por conta própria arquivos que você não passou: 
    - O código de inicialização (`crt1.o`, `crti.o`, `crtbegin.o`, ...), que contém o assembly `_start` que chama o seu `main`
    - A libc (`-lc`)

> Ver `linking.md`

---

**5. Loading** — `./main` (fora do GCC)

- O kernel:
    - Lê o executável
    - Mapeia as sections do executável na memória
    - Se o programa usa bibliotecas compartilhadas
        - Entrega o controle ao dynamic loader
        - O dynamic loader carrega a libc e as outras `.so`/`.dylib`
    - Chama o `_start`

> O dynalic loader chama `ld-linux.so` no Linux e `dyld` no macOS
> Ver `libraries.md`

---

**Parando em cada etapa**

| Flag | Para depois de | Saída padrão |
|------|----------------|--------------|
| `-E` | preprocessing | `stdout` |
| `-S` | compilation | `main.s` |
| `-c` | assembly | `main.o` |
| (nenhuma) | linking | `a.out` |


```bash
gcc -save-temps main.c -o main   # gera main.i, main.s e main.o e NÃO apaga
gcc -v main.c -o main            # mostra cada programa chamado e seus argumentos
```

- O driver também aceita entrar no meio do pipeline: 
    - `gcc main.s -o main` começa pelo assembler
    - `gcc main.o -o main` só linka

> Na prática, o `cc1` faz preprocessing e compilação em um único processo, sem gerar o `.i` em disco. As etapas continuam existindo, só não são materializadas em arquivos a não ser que você peça explicitamente com as flags `-E` ou `-save-temps`. Os erros indicam em qual etapa ocorreram: `fatal error: x.h: No such file` vem do preprocessor, `error: expected ';'` vem do compilador, e `undefined reference` vem do linker (ver `common-errors.md`)
