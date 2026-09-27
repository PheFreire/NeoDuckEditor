**strncpy**

> `string.h`

O `strncpy` copia uma quantidade fixa de caracteres de uma string de origem para uma string de destino, funcionando de forma semelhante ao fatiamento de strings de outras linguagens (como `str[0:n]`), mas com comportamentos específicos de preenchimento e terminação que exigem atenção manual.

```c
#include <string.h>

char *strncpy(
    char *dest, 
    const char *src, 
    size_t n
);
```

- `dest`: a string de destino, que deve ter espaço alocado suficiente para receber os caracteres copiados
- `src`: a string de origem, de onde os caracteres serão extraídos
- `n`: o número exato de bytes/caracteres a serem copiados de `src`

- Retorna o próprio ponteiro `dest`
- **Não garante o `'\0'` final:** Se os primeiros `n` caracteres de `src` não contiverem um caractere nulo (`'\0'`), o `strncpy` **não** adicionará o terminador nulo ao final de `dest`; o resultado será uma sequência de caracteres sem terminação, o que causará bugs se for tratada como string posteriormente
- **Preenchimento com zeros (Padding):** Se a string `src` for menor que `n` caracteres, o `strncpy` continuará copiando caracteres `'\0'` para `dest` até que o total de `n` bytes tenha sido escrito; isso pode causar uma perda de desempenho desnecessária se `n` for muito grande e a string de origem for muito curta
- É a ferramenta ideal para extrair sub-strings (fatiamento), desde que o programador se lembre de adicionar manualmente o caractere `'\0'` na posição correta do destino após a cópia

Para extrair com segurança os 3 primeiros caracteres de uma string (o equivalente a `str[0:3]` do Python):

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str[] = "TextoOriginal";
    char sub_str[4]; // Espaço para 3 caracteres + 1 para o '\0'

    // Copia exatamente 3 caracteres
    strncpy(sub_str, str, 3);
    
    // IMPORTANTE: Garante manualmente que a string foi terminada
    sub_str[3] = '\0'; 

    printf("Resultado: %s\n", sub_str); // Saída: "Tex"
    return 0;
}
```

Utilizando aritmética de ponteiros, você pode deslocar o início da string de origem para fatiar qualquer trecho do meio do texto (como `str[5:9]`):

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str[] = "Programacao";

    // Espaço para 4 caracteres + 1 para o '\0'
    char sub_str[5]; 

    // str + 5 aponta para o inicio da index 5 ('m')
    // copia 4 caracteres a partir dali ("maca")
    strncpy(sub_str, str + 5, 4);
    
    // Garante a terminação
    sub_str[4] = '\0'; 

    // Saída: "maca"
    printf("Resultado: %s\n", sub_str);

    return 0;
}
```

