**strcat**

> `string.h`

O `strcat` junta (concatena) a string `src` ao final da string `dest`: ele encontra o `\0` que marca o fim de `dest`, começa a escrever `src` exatamente a partir dali, por cima daquele `\0`, e finaliza colocando um novo `\0` no fim do resultado

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
char *strcat(char *dest, const char *src);
```

- `dest`: a string de destino, que já precisa estar terminada em `\0` e ter espaço para receber o resultado
- `src`: a string que será copiada para o final de `dest`

- Devolve o próprio ponteiro `dest`
- `dest` precisa ter espaço suficiente para os seus próprios caracteres, mais os de `src`, mais o `\0` final. A função não verifica esse espaço, apenas escreve nele

```c
char buffer[20] = "ola";
strcat(buffer, " mundo"); // buffer passa a ser "ola mundo"
```

> Por copiar `src` inteira sem nenhum limite, um `dest` pequeno demais causa um buffer overflow. Quando o tamanho de `src` não é conhecido de antemão, o `strncat` é a alternativa segura
