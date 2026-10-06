**putchar**

> `stdio.h`

O `putchar` escreve um único caractere no `stdout`. É equivalente a `putc(c, stdout)` e é o caminho inverso do `getchar`, servindo para escrever a saída caractere por caractere

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int putchar(int c);
```

- `c`: o caractere a ser escrito. É recebido como `int` e convertido para `unsigned char` antes de ser escrito, então só o byte mais baixo é usado

- Devolve o próprio caractere escrito (como `unsigned char` convertido para `int`) em caso de sucesso
- Devolve `EOF` se ocorrer um erro de escrita, e o indicador de erro do `stdout` é ligado (verificável com `ferror(stdout)`)
- Não adiciona nenhuma quebra de linha: para pular de linha é preciso escrever `'\n'` explicitamente

```c
putchar('A');    // A
putchar('\n');   // quebra de linha
putchar(65);     // A: 65 é o código ASCII de 'A'
```

Copiando a entrada para a saída, como o comando `cat`:

```c
int c;
while ((c = getchar()) != EOF) {
  putchar(c);
}
```

Escrevendo uma string caractere por caractere:

```c
const char *s = "pato";
for (int i = 0; s[i] != '\0'; i++) {
  putchar(s[i]);
}
putchar('\n');
```

Desenhando uma linha com um caractere repetido:

```c
for (int i = 0; i < 20; i++) {
  putchar('-');
}
putchar('\n');   // --------------------
```

**Buffer**

O `putchar` não escreve direto na tela. Ele coloca o caractere no buffer do `stdout`, que só é enviado ao sistema (com `write()`) quando enche, quando aparece um `\n` (se o `stdout` estiver ligado a um terminal) ou quando o programa termina:

```text
putchar('o')   → buffer: "o"
putchar('l')   → buffer: "ol"
putchar('a')   → buffer: "ola"
putchar('\n')  → buffer enviado ao terminal: "ola\n"
```

- Por isso chamar o `putchar` muitas vezes é barato: cada chamada não é uma escrita no sistema
- Se o texto não terminar com `\n` e o programa precisar mostrá-lo antes de esperar algo (como um prompt), use `fflush(stdout)` (ver `fflush.md`)
- Com o `stdout` redirecionado para um arquivo ou pipe, o buffer só é enviado quando enche ou com `fflush`, e não a cada `\n`

**Armadilhas**

- Passar uma string em vez de um caractere (`putchar("a")`) não funciona: `"a"` é um ponteiro, e o compilador avisa sobre a conversão de ponteiro para inteiro. Use aspas simples para caracteres (`'a'`) e `fputs`/`printf` para strings
- Em raw mode do terminal, `putchar('\n')` só desce uma linha, sem voltar para a coluna 0, pois o terminal deixa de converter `\n` em `\r\n`. Escreva `"\r\n"` nesse caso (ver `../termios/output-flags.md`)

> Para escrever uma string inteira, `fputs(s, stdout)` é mais prático que um laço de `putchar`, e `puts(s)` faz o mesmo adicionando um `\n` no final. Para escrever um caractere em outro stream (como `stderr` ou um arquivo), use `putc(c, stream)` ou `fputc(c, stream)`
