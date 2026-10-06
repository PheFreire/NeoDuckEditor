**strncat**

> `string.h`

O `strncat` concatena (junta) uma string ao final de outra, limitando quantos caracteres da string de origem são copiados, sendo a base para implementar algo como o `join` do Python em C

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
char *strncat(char *dest, const char *src, size_t n);
```

- `dest`: a string de destino, que já deve ter espaço suficiente para receber o resultado. A concatenação começa a partir do `\0` que já existe nela
- `src`: a string de origem, cujo conteúdo será copiado para o final de `dest`
- `n`: o número máximo de caracteres de `src` a serem copiados, sem contar o `\0` final

- Devolve o próprio ponteiro `dest`
- Sempre escreve um `\0` ao final do resultado, mesmo que copie menos de `n` caracteres (quando `src` é menor que `n`). Quando `src` é maior, o `\0` é escrito logo após os `n` caracteres copiados, totalizando `n + 1` bytes escritos
- `dest` precisa ter espaço para o seu conteúdo original, mais até `n` caracteres de `src`, mais o `\0`, por isso o limite costuma ser calculado como `sizeof(dest) - strlen(dest) - 1`
- Usando o `strncat` em um laço, é possível juntar vários pedaços de string com um separador entre eles, do jeito que o `str.join()` faz em Python

```c
char dst[50] = "";
const char *src[] = {"maca", "banana", "uva"};

for (int i = 0; i < 3; i++) {
  if (i > 0) {
    strncat(dst, ", ", sizeof(dst) - strlen(dst) - 1);
  }
  strncat(dst, src[i], sizeof(dst) - strlen(dst) - 1);
}
// dst == "maca, banana, uva"
```

> Diferente do `strcat`, que copia `src` inteira sem limite, o `strncat` permite controlar o quanto será copiado, evitando estourar o buffer quando o tamanho de `src` não é conhecido de antemão
