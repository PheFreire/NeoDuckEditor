**strcmp**

> `string.h`

O `strcmp` compara o conteúdo de duas strings caractere por caractere, indicando se são iguais ou qual delas vem antes na ordem alfabética (lexicográfica)

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
int strcmp(const char *s1, const char *s2);
```

- `s1`: a primeira string a ser comparada
- `s2`: a segunda string a ser comparada

- Devolve `0` quando os dois buffers possuem exatamente o mesmo conteúdo
- Devolve um valor negativo quando `s1` vem antes de `s2`, e um valor positivo quando `s1` vem depois, comparando o valor numérico do primeiro caractere diferente entre as duas
- A comparação diferencia maiúsculas de minúsculas, então `"Pato"` e `"pato"` não são consideradas iguais

```c
const char *nomes[] = {"pato", "pata", "bigode"};

if (strcmp(nomes[0], "pato") == 0) {
  // os buffers tem o mesmo conteudo
}

strcmp("pata", "pato"); // negativo, 'a' vem antes de 'o'
```

> Como um ponteiro é apenas um endereço, comparar dois `char *` com `==` compara os endereços das strings e não o conteúdo dos buffers para os quais eles apontam, por isso para comparar o texto em si é sempre necessário usar o `strcmp`
