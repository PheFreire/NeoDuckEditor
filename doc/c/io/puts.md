**puts**

> `stdio.h`

O `puts` escreve uma string no `stdout` e adiciona uma quebra de linha (`\n`) no final. É a forma mais simples de mostrar um texto fixo na tela, sem nenhuma formatação

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int puts(const char *s);
```

- `s`: a string a ser escrita, terminada em `\0`. O `\0` marca o fim e não é escrito

- Devolve um valor não negativo em caso de sucesso (o valor exato depende da implementação, então não use o número, só confira se não é `EOF`)
- Devolve `EOF` se ocorrer um erro de escrita, e o indicador de erro do `stdout` é ligado (verificável com `ferror(stdout)`)
- Sempre adiciona um `\n` depois da string, mesmo que ela já termine com um
- Não interpreta nada dentro da string: `%`, `\` e qualquer outro caractere são escritos como estão

```c
puts("ola mundo");      // ola mundo + quebra de linha
puts("");               // só uma linha em branco
puts("100% pronto");    // 100% pronto: o % não tem significado especial
```

```c
const char *nome = "pato";
puts(nome);             // pato
```

---

**puts x printf**

```c
puts("ola");             // ola\n
printf("ola\n");         // ola\n: mesmo resultado
printf("%s\n", texto);   // equivalente a puts(texto)
```

- Para um texto fixo, o `puts` é mais simples: não precisa do `\n` nem se preocupa com `%`
- O `printf` é necessário quando há valores para formatar (`%d`, `%f`, `%s` junto com outro texto)
- O GCC e o Clang trocam automaticamente um `printf("texto\n")` sem nenhum `%` por `puts("texto")`, por ser mais rápido. Por isso o `puts` aparece no assembly ou no `nm` de programas que só usam `printf` (ver `../compilers/gcc/doc/symbols.md`)

---

**Nunca use o texto do usuário como formato**

```c
printf(entrada);         // ERRADO: se entrada tiver %s ou %n, o printf lê ou escreve memória arbitrária
puts(entrada);           // seguro: o texto é escrito como está
printf("%s\n", entrada); // seguro
```

- Passar um texto que veio de fora como primeiro argumento do `printf` é uma falha de segurança conhecida (format string attack). O `puts` não tem esse problema, pois não tem string de formato. O `-Wformat-security` do GCC avisa sobre o caso errado

---

**puts x fputs**

```c
puts("ola");             // escreve "ola\n" no stdout
fputs("ola", stdout);    // escreve "ola", sem quebra de linha
fputs("ola\n", stderr);  // escreve em qualquer stream, como o stderr ou um arquivo
```

- O `puts` sempre escreve no `stdout` e sempre adiciona o `\n`
- O `fputs` recebe o stream de destino e **não** adiciona nada. É o par natural do `fgets`, que mantém o `\n` lido no final da string

```c
char linha[256];
while (fgets(linha, sizeof(linha), stdin) != NULL) {
  fputs(linha, stdout);  // a linha já tem o \n
  // puts(linha) escreveria uma linha em branco a mais depois de cada uma
}
```

---

**Buffer**

Assim como o `putchar`, o `puts` coloca o texto no buffer do `stdout`, que é enviado ao terminal a cada `\n` quando o `stdout` está ligado a um terminal (ver `putchar.md`). Como o `puts` sempre termina com `\n`, o texto aparece na tela logo após a chamada

- Com o `stdout` redirecionado para um arquivo ou pipe, o buffer só é enviado quando enche, com `fflush(stdout)` ou no fim do programa (ver `fflush.md`)
- Mensagens de erro devem ir para o `stderr` com `fputs` ou `fprintf(stderr, ...)`, e não para o `stdout` com `puts`, para continuarem aparecendo mesmo quando a saída normal for redirecionada

---

**Armadilhas**

- Passar `NULL` (`puts(NULL)`) é comportamento indefinido. Algumas implementações escrevem `(null)`, outras derrubam o programa
- A string precisa terminar com `\0`. Um array de `char` sem o `\0` faz o `puts` continuar lendo a memória seguinte até encontrar um byte zero
- Em raw mode do terminal, o `\n` adicionado pelo `puts` só desce uma linha, sem voltar para a coluna 0. Nesse caso use `fputs("texto\r\n", stdout)` (ver `../termios/output-flags.md`)

> Use o `puts` para textos fixos com quebra de linha, o `fputs` para escrever sem quebra de linha ou em outro stream, e o `printf` quando houver valores para formatar. O caminho inverso, ler uma linha, é feito pelo `fgets`
