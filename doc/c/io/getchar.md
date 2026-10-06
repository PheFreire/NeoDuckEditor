**getchar**

> `stdio.h`

O `getchar` lê um único caractere do `stdin` e o devolve como `int`. É equivalente a `getc(stdin)` e serve para ler a entrada caractere por caractere, seja do teclado ou de um arquivo redirecionado

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int getchar(void);
```

- Não recebe parâmetros: sempre lê do `stdin`

- Devolve o caractere lido como um `unsigned char` convertido para `int` (de `0` a `255`)
- Devolve `EOF` (normalmente `-1`) quando chega ao fim da entrada ou quando ocorre um erro. Para saber qual dos dois aconteceu, use `feof(stdin)` e `ferror(stdin)`
- O retorno é `int`, e não `char`, justamente para caber todos os 256 valores possíveis de um byte **mais** o `EOF`, que precisa ser diferente de todos eles

```c
int c = getchar();
if (c != EOF) {
  printf("leu: %c\n", c);
}
```

Lendo toda a entrada caractere por caractere até o fim:

```c
int c;
while ((c = getchar()) != EOF) {
  putchar(c); // copia a entrada para a saída
}
```

Descartando o resto da linha, como o `\n` deixado por um `scanf`:

```c
int c;
while ((c = getchar()) != '\n' && c != EOF) {
  // descarta
}
```

---

**Por que o getchar espera o Enter**

O `getchar` não lê direto do teclado. Ele pega o próximo caractere do buffer do `stdin`, e quando esse buffer está vazio, pede mais dados ao sistema com `read()`:

```text
teclado
  │  terminal em modo canônico: guarda a linha até o Enter
  ▼
read()
  │  "abc\n" inteiro vai para o buffer do stdin
  ▼
getchar()  → 'a'
getchar()  → 'b'    (sem esperar, já estava no buffer)
getchar()  → 'c'
getchar()  → '\n'
getchar()  → espera a próxima linha
```

- A primeira chamada fica bloqueada até o usuário apertar Enter, porque o terminal só entrega a linha completa (ver `../termios/canonical-mode.md`)
- As chamadas seguintes devolvem os caracteres restantes da mesma linha na hora, inclusive o `\n` final
- Para ler uma tecla sem esperar o Enter, é preciso mudar a configuração do terminal com `termios`, e nesse caso é melhor usar `read()` diretamente, pois o buffer do `stdin` pode guardar bytes além do primeiro (ver `../termios/examples.md`)

---

**Armadilhas**

- Guardar o retorno em um `char` (`char c = getchar();`) quebra a detecção de fim de arquivo:
    - Se `char` for `unsigned` (comum em ARM), `EOF` vira `255` e o laço `while (c != EOF)` nunca termina
    - Se `char` for `signed` (comum em x86), um byte `255` vira `-1` e é confundido com `EOF`, encerrando a leitura antes da hora
- No terminal, o fim da entrada é sinalizado com `Ctrl+D` no começo de uma linha (Linux e macOS). No meio de uma linha, é preciso apertá-lo duas vezes
- Os parênteses em `(c = getchar()) != EOF` são obrigatórios: sem eles, `c = getchar() != EOF` guarda em `c` o resultado da comparação (`0` ou `1`), e não o caractere

> O `getchar` é a forma mais simples de ler caractere por caractere, mas para ler linhas inteiras o `fgets` é mais prático e seguro. O caminho inverso, escrever um caractere no `stdout`, é feito pelo `putchar`
