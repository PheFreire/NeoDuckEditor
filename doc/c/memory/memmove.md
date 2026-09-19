**memmove**

> `string.h`

O `memmove` move `n` bytes de um endereço de origem (`src`) para um endereço de destino (`dest`), sendo a única função de cópia que funciona com segurança quando as duas áreas se sobrepõem (overlap)

```c
void *memmove(void *dest, const void *src, size_t n);
```

- `dest`: ponteiro para onde os dados vão
- `src`: ponteiro de onde os dados saem
- `n`: o número exato de bytes a serem copiados, e não a quantidade de elementos
``
Exemplo: "Apagando" um item no meio:

```c
#include <stdio.h>
#include <string.h>

// void *memmove(void *dest, const void *src, size_t n);

int main() {
    int numeros[] = {10, 20, 30, 40, 50};
    int total = 5;
    int indice_para_apagar = 1; // Queremos apagar o '20'

    // memmove(destino, origem, quantos_bytes)
    // Destino: onde está o 20 (numeros[1])
    // Origem: onde está o 30 (numeros[2])
    // Quantos bytes: O que sobrou do array (3 itens: 30, 40, 50)
    memmove(&numeros[indice_para_apagar], 
            &numeros[indice_para_apagar + 1], 
            (total - indice_para_apagar - 1) * sizeof(int));

    total--; // Agora o array "tem" 4 itens úteis

    for(int i = 0; i < total; i++) printf("%d ", numeros[i]);
    // Saída: 10 30 40 50
    
    return 0;
}
```
