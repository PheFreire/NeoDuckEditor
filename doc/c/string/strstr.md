**strstr**

> `string.h`

O `strstr` procura a primeira ocorrência de uma substring dentro de outra string, funcionando como o `in` ou o `find` de outras linguagens, mas devolvendo um ponteiro para onde o trecho foi encontrado em vez de um índice

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
char *strstr(const char *haystack, const char *needle);
```

- `haystack`: a string onde a busca será feita
- `needle`: a substring que está sendo procurada, sem contar o seu `\0` final

- Devolve um ponteiro para o primeiro caractere da ocorrência dentro de `haystack`, ou `NULL` se `needle` não for encontrada
- Se `needle` for uma string vazia (`""`), devolve o próprio `haystack`
- Não modifica nem copia nada: o ponteiro devolvido aponta para dentro do buffer original, então tudo a partir dele (até o `\0` de `haystack`) é o restante do texto
- A busca diferencia maiúsculas de minúsculas, então procurar `"Pato"` em `"o pato nada"` devolve `NULL`
- Subtraindo o ponteiro devolvido do início de `haystack` (aritmética de ponteiros), obtém-se o índice onde a ocorrência começa

```c
const char *frase = "o pato nada no lago";
char *achou = strstr(frase, "nada");

if (achou != NULL) {
  // achou aponta para "nada no lago"
  long indice = achou - frase; // 7
}

if (strstr(frase, "ganso") == NULL) {
  // "ganso" não aparece em frase
}
```

> Diferente do `strtok`, que corta a string escrevendo `\0` em cima dos delimitadores, o `strstr` apenas procura e não altera o buffer, podendo ser combinado com o `strncpy` para extrair o trecho antes ou depois da ocorrência encontrada
