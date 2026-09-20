**strncat**

> `string.h`

O `strncat` concatena (junta) uma string ao final de outra, limitando quantos caracteres da string de origem são copiados, sendo a base para implementar algo como o `join` do Python em C

```c
#include <string.h>

char *strncat(char *dest, const char *src, size_t n);
```

- `dest`: a string de destino, que já deve conter espaço suficiente alocado para receber o resultado; a concatenação começa a partir do `'\0'` que já existe nela
- `src`: a string de origem, cujo conteúdo será copiado para o final de `dest`
- `n`: o número máximo de caracteres de `src` a serem copiados, sem contar o `'\0'` final

- Retorna o próprio ponteiro `dest`
- Sempre escreve um `'\0'` ao final do resultado, mesmo que isso signifique escrever menos de `n` caracteres (quando `src` for menor que `n`) ou mais de `n+1` bytes no total (quando `src` for maior, o `'\0'` ainda é escrito logo após os `n` caracteres copiados)
- `dest` precisa ter espaço para o seu conteúdo original, mais até `n` caracteres de `src`, mais o `'\0'` final; a função não aloca nem verifica esse espaço, apenas escreve nele, então um `dest` pequeno demais causa *buffer overflow*
- Diferente de `strcat` (sem o `n`), que copia `src` inteira sem limite, `strncat` permite controlar o quanto será copiado, evitando estourar o buffer quando o tamanho de `src` não é conhecido de antemão
- Combinando `strncat` em um laço, é possível juntar vários pedaços de string com um separador entre eles, do jeito que `str.join()` faz em Python, embora seja preciso calcular o tamanho total e alocar/declarar o buffer de destino manualmente antes

```c
char resultado[50] = "";
const char *palavras[] = {"maca", "banana", "uva"};

for (int i = 0; i < 3; i++) {
    if (i > 0) {
        strncat(resultado, ", ", sizeof(resultado) - strlen(resultado) - 1);
    }
    strncat(resultado, palavras[i], sizeof(resultado) - strlen(resultado) - 1);
}
// resultado == "maca, banana, uva"
```

