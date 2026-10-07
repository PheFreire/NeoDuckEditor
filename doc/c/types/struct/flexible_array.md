**flexible array member**

> regra da linguagem (C99), não precisa de header

O último campo de uma struct pode ser um array sem tamanho declarado. Ele não ocupa espaço no `sizeof` da struct e é alocado junto com ela, no mesmo bloco de memória, com o tamanho escolhido na hora do `malloc`

> É a forma de ter uma struct com um cabeçalho de tamanho fixo seguido de dados de tamanho variável, como uma string com o tamanho guardado na frente ou um pacote com o número de itens e depois os itens

```c
struct nome {
  /* pelo menos um campo normal */
  tipo dados[];  // sempre o último campo
};
```

- Precisa ser o último campo, e a struct precisa ter pelo menos um outro campo antes dele
- `sizeof(struct nome)` não conta o array, apenas os campos normais e o padding
- Uma struct assim não pode ser campo de outra struct nem elemento de um array

---

**Alocando**

```c
struct buffer {
  size_t tamanho;
  char dados[];
};

size_t n = 100;
struct buffer *b = malloc(sizeof *b + n * sizeof b->dados[0]);  // a struct mais n elementos
if (b == NULL) {
  return NULL;
}
b->tamanho = n;
b->dados[n - 1] = 'x';

free(b);  // um único free libera a struct e os dados
```

```c
// memória de um struct buffer com n = 100:
// byte:  0 ... 7    8 ... 107
//        tamanho    dados[0] ... dados[99]
```

- O tamanho do array não fica guardado em lugar nenhum, por isso é comum ter um campo como `tamanho` logo antes
- Para conferir se `n * sizeof b->dados[0]` estoura, use a mesma verificação com `SIZE_MAX` (ver `../SIZE_MAX.md`)

---

**Comparando com um ponteiro**

```c
// com ponteiro: dois blocos de memória
struct buffer_ptr {
  size_t tamanho;
  char *dados;
};

struct buffer_ptr *b = malloc(sizeof *b);
b->dados = malloc(100);
/* ... */
free(b->dados);  // dois free, na ordem certa
free(b);
```

- Com o flexible array, é uma alocação e um `free` só, sem risco de esquecer de liberar os dados
- Os dados ficam colados no cabeçalho, o que é melhor para o cache
- O ponteiro gasta 8 bytes a mais e permite trocar os dados sem trocar a struct, o que o flexible array não permite

---

**Armadilhas**

- A atribuição `*b2 = *b` copia só os campos normais, e não os dados. Para copiar, use `memcpy` com o tamanho total
- Declarar a struct como variável comum (`struct buffer b`) deixa o array com zero elementos, então qualquer acesso a `b.dados[i]` escreve fora da memória
- Aumentar o array exige `realloc` da struct inteira, o que pode mudar o endereço dela e invalidar todos os ponteiros antigos para ela

> Código antigo usa `char dados[1]` ou `char dados[0]` no lugar de `char dados[]`. O `[0]` é uma extensão do GCC e o `[1]` funciona por acaso, gastando um byte a mais nas contas. O `[]` é a forma padrão desde o C99 e deve ser a preferida
