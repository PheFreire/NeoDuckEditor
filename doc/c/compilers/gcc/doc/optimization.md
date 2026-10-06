**Otimização**

> flags `-O` do GCC

Otimizar significa deixar o compilador reescrever o seu código em uma versão diferente, mais rápida ou menor, mas com o mesmo comportamento observável segundo o padrão C.

O processo de otimização consiste em: 
- Eliminar variáveis
- Reordenar instruções
- Manter valores só em registradores
- Copiar o corpo de funções para dentro de quem as chama (inlining)
- Desenrolar laços
- Remover código cujo o resultado nunca é usado

```bash
gcc -O2 main.c -o main
```

- A otimização acontece na etapa de compilação (`.c` → `.s`), então a flag precisa estar no comando que compila, e não só no de link (ver `compilation-pipeline.md`)

---

**Níveis**

| Flag | Objetivo | Uso típico |
|------|----------|------------|
| `-O0` | nenhuma otimização (padrão) | debug, código igual ao fonte |
| `-Og` | otimizar sem atrapalhar o debug | desenvolvimento do dia a dia |
| `-O1` | otimizações básicas e baratas | raramente usado direto |
| `-O2` | quase tudo que não aumenta o tamanho de forma agressiva | **release** |
| `-O3` | `-O2` + inlining e vetorização agressivos | código numérico, laços pesados |
| `-Os` | `-O2` sem o que aumenta o tamanho do binário | embarcados, binários pequenos |
| `-Oz` | ainda menor que `-Os` (GCC 12+) | quando cada byte importa |
| `-Ofast` | `-O3` + `-ffast-math`, quebra regras do padrão | evite, a não ser que saiba o que faz |


- Em `-O0`, cada variável vive na memória (na pilha) e cada linha do C vira um bloco de instruções isolado: lento, mas previsível

- A partir de `-O1`, valores ficam em registradores, código morto é removido e expressões constantes são calculadas em tempo de compilação

- `-O2` também ativa vetorização barata (GCC 12+), inlining de funções pequenas, eliminação de subexpressões comuns, reordenação de instruções, etc

- `-O3` nem sempre é mais rápido que `-O2`: o código maior pode ocupar mais cache de instruções. Meça antes de escolher

```bash
gcc -Q --help=optimizers -O2   # mostra quais otimizações cada nível liga
gcc -O2 -S main.c              # gera main.s para ver o resultado
```

---

**O que a otimização faz com o código**

```c
int soma(void) {
  int total = 0;
  for (int i = 1; i <= 100; i++) {
    total += i;
  }
  return total;
}
```

```text
-O0: aloca total e i na pilha, executa o laço 100 vezes
-O2: mov eax, 5050 ; ret      → o laço inteiro foi calculado na compilação
```

---

**Impacto no debugging** (ver `debugging.md`)

Com otimização, o código de máquina deixa de corresponder linha a linha ao fonte, e o debugger mostra isso:

- `<optimized out>`: a variável só existia em um registrador que já foi reaproveitado, ou foi eliminada
- A execução "pula" linhas ou volta para trás no `step`, porque instruções de linhas diferentes foram reordenadas e misturadas
- Breakpoints em funções inlined podem não parar, ou parar em vários lugares, pois a função não existe mais como chamada
- Laços somem ou mudam de forma, como no exemplo acima

Para evitar isso, usamo o comando: 
- `-O0`/`-Og` para desenvolver e depurar
- `-O2` para o build final

> O `-g` funciona em qualquer nível, mas a experiência piora conforme a otimização aumenta

---

**Armadilhas**

- Um laço de espera como `while (!flag);` pode virar um laço infinito em `-O2` se `flag` for alterada por outra thread ou por um signal handler, pois o compilador lê o valor uma vez só. Portanto, use `atomic` (threads) ou `volatile sig_atomic_t` (signals)
- Apagar dados sensíveis com `memset` antes do `free` pode não funcionar: como a memória não é lida depois de zerada, o compilador considera a escrita inútil e a remove, deixando a senha intacta na memória.

```c
char *text = malloc(64);
memset(text, 0, 64);        // pode ser removido em -O2: ninguém lê senha depois
free(senha);
```

> `-march=native` e `-flto` (link-time optimization, que otimiza entre arquivos `.c` diferentes durante o link) são as duas flags que mais costumam render depois do `-O2`. O `-flto` precisa estar tanto na compilação quanto no link
