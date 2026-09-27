**strcat**

> `string.h`

O `strcat` junta (concatena) a string `src` ao final da string `dest`: ele encontra o `\0` que marca o fim de `dest`, começa a escrever `src` exatamente a partir dali, por cima daquele `\0`, e finaliza colocando um novo `\0` no fim do resultado

```c
char *strcat(char *dest, const char *src);
```

- `dest` precisa ter espaço suficiente para receber seus próprios caracteres mais os de `src`, caso contrário ocorre um buffer overflow
- Retorna o próprio ponteiro `dest`

```c
char buffer[20] = "ola";
strcat(buffer, " mundo"); // buffer passa a ser "ola mundo"
```

