**fgets**

> `stdio.h`

O `fgets` lê uma linha de texto de um `stream` e copia o que foi lido para dentro do buffer que você já possui, parando ao encontrar uma quebra de linha, ao atingir o limite de caracteres informado ou ao chegar no fim do arquivo

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
char *fgets(char *str, int numChars, FILE *stream);
```

- `str`: o buffer que você já possui, para onde a linha lida vai ser copiada
- `numChars`: o tamanho total do buffer `str`, usado para o `fgets` saber o limite de caracteres que pode escrever sem ultrapassar o espaço reservado
- `stream`: de onde os caracteres serão lidos, como um arquivo aberto com `fopen` ou o `stdin`

Sobre o comportamento da leitura:
- Lê no máximo `numChars - 1` caracteres, guardando sempre o último espaço do buffer para o `\0` que ela mesma adiciona no final
- Se encontrar uma quebra de linha antes de atingir o limite, o `\n` é incluído na string lida
- Também funciona com `stdin`, lendo uma linha digitada no teclado como se fosse um stream

```c
char nome[50];
fgets(nome, 50, stdin); // lê no máximo 49 caracteres, o 50º espaço fica para o '\0'
```

> Diferente do `strcpy`, o `fgets` nunca escreve além do tamanho passado em `numChars`, por isso é a forma segura de ler uma linha para dentro de um buffer de tamanho fixo, sem correr o risco de um buffer overflow

