**strcmp**

> `string.h`

Como um ponteiro é apenas um endereço, comparar dois `char *` com `==` compara os endereços das strings e não o conteúdo dos buffers para os quais eles apontam. Para comparar o conteúdo, ou seja, os valores dentro dos buffers, é necessário usar `strcmp`

```c
int strcmp(const char *s1, const char *s2);
```

> `strcmp` retorna `0` quando os dois buffers possuem o mesmo conteúdo

```c
const char *nomes[] = {"pato", "pata", "bigode"};

if (strcmp(nomes[0], "pato") == 0) {
  // os buffers tem o mesmo conteudo
}
```

