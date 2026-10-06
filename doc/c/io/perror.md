**perror**

> `stdio.h`

O `perror` escreve no `stderr` uma mensagem descrevendo o último erro ocorrido em uma chamada da biblioteca padrão ou do sistema, juntando um texto seu com a descrição legível do código guardado em `errno`

> O `errno` (de `errno.h`) é uma variável global onde as funções da biblioteca guardam um código numérico indicando por que falharam, como `ENOENT` (arquivo não existe) ou `EACCES` (permissão negada). Ele só é preenchido quando uma função falha, e nunca é zerado automaticamente quando ela dá certo

```c
void perror(const char *s);
```

- `s`: um texto seu, escrito antes da descrição do erro, normalmente o nome da função ou da operação que falhou. Se for `NULL` ou `""`, apenas a descrição do erro é escrita

- Não devolve nada
- O formato escrito é `s`, seguido de `": "`, da descrição do erro atual em `errno` e de uma quebra de linha, exatamente como em `"fopen: No such file or directory\n"`
- Escreve no `stderr`, e não no `stdout`, então a mensagem aparece no terminal mesmo quando a saída normal do programa é redirecionada para um arquivo (`./programa > saida.txt`)
- Só faz sentido logo depois de uma função que sinalizou falha pelo seu retorno (`NULL`, `-1`, etc), pois qualquer outra chamada no meio, inclusive um `printf`, pode alterar o `errno` e fazer o `perror` descrever o erro errado

```c
FILE *file = fopen("nao_existe.txt", "r");
if (file == NULL) {
  perror("fopen");
  // stderr: fopen: No such file or directory
  return 1;
}
```

Usando um texto mais descritivo, incluindo o nome do arquivo que falhou:

```c
const char *caminho = "config.txt";
FILE *file = fopen(caminho, "r");
if (file == NULL) {
  char msg[256];
  snprintf(msg, sizeof(msg), "erro ao abrir %s", caminho);
  perror(msg);
  // stderr: erro ao abrir config.txt: No such file or directory
}
```

> Diferente do `fprintf(stderr, ...)`, que escreve só o que você mandar, o `perror` já traduz o `errno` para texto automaticamente. Quando é preciso montar uma mensagem com outro formato, a mesma descrição pode ser obtida com `strerror(errno)`, de `string.h`, e usada dentro de um `fprintf`
