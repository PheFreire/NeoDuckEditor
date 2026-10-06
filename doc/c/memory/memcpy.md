**memcpy**

> `string.h`

O `memcpy` copia `n` bytes de um endereço de origem (`src`) para um endereço de destino (`dest`), byte a byte, sem interpretar o conteúdo, sendo a forma mais direta de duplicar qualquer bloco de memória quando origem e destino são regiões separadas

> Duas regiões se `sobrepõem` (overlap) quando compartilham pelo menos um byte em comum. Isso acontece quase sempre que se copia dados de uma posição para outra dentro do mesmo array, como ao deslocar elementos para a esquerda ou para a direita

```c
void *memcpy(void *dest, const void *src, size_t n);
```

- `dest`: ponteiro para o início da região onde os bytes vão ser escritos
- `src`: ponteiro para o início da região de onde os bytes vão ser lidos
- `n`: a quantidade de bytes a copiar, e não a quantidade de elementos. Para um array de `int`, por exemplo, é preciso multiplicar por `sizeof(int)`

- Devolve o próprio ponteiro `dest`
- Trabalha com bytes crus (`void *`), então serve para qualquer tipo: `char`, `int`, structs, etc, e não para no `\0` como as funções de string
- Copia exatamente `n` bytes, nem mais nem menos. `dest` precisa ter pelo menos `n` bytes de espaço, caso contrário ocorre um buffer overflow
- Se `src` e `dest` se sobrepuserem, o comportamento é indefinido: o resultado pode sair certo em uma máquina e corrompido em outra, dependendo de como a biblioteca implementa a cópia

---

**Copiando um array inteiro**

Arrays em C não podem ser atribuídos com `=`, então para duplicar um array é preciso copiar os bytes dele:

```c
int origem[5] = {10, 20, 30, 40, 50};
int copia[5];

// copia = origem; // erro de compilação, arrays não são atribuíveis
memcpy(copia, origem, sizeof(origem)); // sizeof(origem) == 5 * sizeof(int) == 20

// copia == {10, 20, 30, 40, 50}, independente de origem
```

> O `sizeof(origem)` só devolve o tamanho do array inteiro quando `origem` é o próprio array. Se ele tiver sido recebido como parâmetro de função, já virou um ponteiro e `sizeof` devolve apenas o tamanho do ponteiro (8 bytes), então o tamanho precisa ser calculado como `quantidade * sizeof(int)`

---

**Copiando um pedaço de um array para outro**

Somando um deslocamento aos ponteiros, é possível copiar apenas um trecho, para qualquer posição do destino:

```c
int origem[] = {10, 20, 30, 40, 50};
int destino[3];

// copia 3 elementos a partir do índice 1 (20, 30, 40)
memcpy(destino, &origem[1], 3 * sizeof(int));

// destino == {20, 30, 40}
```

---

**Duplicando dados para a heap**

Um uso muito comum é copiar dados que estão na stack para um bloco alocado com `malloc`, para que continuem existindo depois que a função terminar. Para strings, o `+ 1` leva junto o `\0`, que é exatamente o que o `strdup` faz por dentro:

```c
const char *nome = "pato";
size_t tamanho = strlen(nome) + 1; // 4 caracteres + 1 para o '\0'

char *copia = malloc(tamanho);
if (copia != NULL) {
  memcpy(copia, nome, tamanho);
  // copia == "pato", em um bloco próprio na heap
}

free(copia);
```

---

**O caso em que o memcpy não funciona**

Quando origem e destino estão no mesmo array e se sobrepõem, o `memcpy` pode sobrescrever bytes de `src` antes de lê-los:

```c
char s[] = "ABCDE";

memcpy(s + 1, s, 4); // comportamento indefinido, as regiões se sobrepõem
// uma implementação que copia da esquerda para a direita produz "AAAAA" em vez de "AABCD"

memmove(s + 1, s, 4); // correto, s == "AABCD"
```

> Diferente do `memmove`, o `memcpy` não verifica se as regiões se sobrepõem, o que permite que ele seja um pouco mais rápido. Use o `memcpy` quando origem e destino forem blocos separados (arrays diferentes, ou stack para heap), e o `memmove` sempre que os dois estiverem dentro do mesmo array
