**memmove**

> `string.h`

O `memmove` copia `n` bytes de um endereço de origem (`src`) para um endereço de destino (`dest`), funcionando corretamente mesmo quando as duas regiões de memória se sobrepõem, ou seja, quando parte dos bytes que vão ser lidos também vão ser sobrescritos durante a cópia

> Duas regiões se `sobrepõem` (overlap) quando compartilham pelo menos um byte em comum. Isso acontece quase sempre que se copia dados de uma posição para outra dentro do mesmo array, como ao deslocar elementos para a esquerda ou para a direita

```c
void *memmove(void *dest, const void *src, size_t n);
```

- `dest`: ponteiro para o início da região onde os bytes vão ser escritos
- `src`: ponteiro para o início da região de onde os bytes vão ser lidos
- `n`: a quantidade de bytes a copiar, e não a quantidade de elementos. Para um array de `int`, por exemplo, é preciso multiplicar por `sizeof(int)`

- Devolve o próprio ponteiro `dest`
- O resultado é sempre o mesmo que seria obtido se os `n` bytes de `src` fossem primeiro copiados para um buffer temporário e só depois escritos em `dest`, ou seja, `dest` recebe exatamente o conteúdo que `src` tinha antes da chamada
- Trabalha com bytes crus (`void *`), então serve para qualquer tipo: `char`, `int`, structs, etc, e não para no `\0` como as funções de string
- Nem `dest` nem `src` podem ultrapassar o tamanho real do bloco a que pertencem. Copiar além dele é um buffer overflow

---

**Por que a sobreposição é um problema**

Uma cópia ingênua lê e escreve um byte de cada vez, da esquerda para a direita. Se `dest` estiver à direita de `src` e as regiões se sobrepuserem, a cópia sobrescreve bytes de `src` antes de lê-los:

```c
char s[] = "ABCDE";
// queremos deslocar "ABCD" uma posição para a direita (dest = s + 1, src = s)
// resultado esperado: "AABCD"

// copiando da esquerda para a direita, um byte por vez:
// s[1] = s[0] -> "AACDE"   (o 'B' original foi perdido)
// s[2] = s[1] -> "AAADE"   (s[1] já não é mais 'B', agora é 'A')
// s[3] = s[2] -> "AAAAE"
// s[4] = s[3] -> "AAAAA"   resultado errado
```

É exatamente isso que pode acontecer com o `memcpy`, que assume que as regiões nunca se sobrepõem. O `memmove` resolve escolhendo a direção da cópia conforme a posição dos ponteiros:

- Se `dest` está antes de `src` (deslocando para a esquerda), copia do primeiro byte para o último, pois cada byte lido está sempre à frente do que está sendo escrito
- Se `dest` está depois de `src` (deslocando para a direita), copia do último byte para o primeiro, pelo mesmo motivo no sentido contrário

```c
char s[] = "ABCDE";
memmove(s + 1, s, 4);
// copiando do último para o primeiro:
// s[4] = s[3] -> "ABCDD"
// s[3] = s[2] -> "ABCCD"
// s[2] = s[1] -> "ABBCD"
// s[1] = s[0] -> "AABCD"   resultado correto
```

---

**Removendo um elemento do meio de um array**

Para apagar um item, desloca-se tudo o que vem depois dele uma posição para a esquerda, por cima dele:

```c
int nums[] = {10, 20, 30, 40, 50};
int total = 5;
int i = 1; // índice do 20

// dest: onde está o 20      -> &nums[i]
// src:  o elemento seguinte -> &nums[i + 1]
// n:    os elementos depois de i (30, 40, 50) em bytes
memmove(&nums[i], &nums[i + 1], (total - i - 1) * sizeof(int));
total--;

// memória: {10, 30, 40, 50, 50}
// o último 50 continua lá, mas fica fora dos 4 elementos considerados válidos
```

---

**Inserindo um elemento no meio de um array**

Para abrir espaço, desloca-se tudo a partir da posição desejada uma posição para a direita, que é justamente o caso em que uma cópia da esquerda para a direita estragaria os dados:

```c
int nums[6] = {10, 20, 40, 50}; // capacidade 6, 4 elementos usados
int total = 4;
int i = 2; // posição onde o 30 deve entrar

// dest: uma posição à frente  -> &nums[i + 1]
// src:  a partir da posição i -> &nums[i]
// n:    os elementos de i até o fim (40, 50) em bytes
memmove(&nums[i + 1], &nums[i], (total - i) * sizeof(int));
nums[i] = 30;
total++;

// nums == {10, 20, 30, 40, 50}
```

> O array precisa ter capacidade para o elemento extra antes do `memmove`. Se ele estiver cheio, é preciso aumentá-lo primeiro com `realloc`

---

**Removendo espaços do início de uma string**

Como o texto útil está à direita dos espaços e vai ser movido para o começo do mesmo buffer, as regiões se sobrepõem. O `+ 1` no tamanho leva junto o `\0`, para que o resultado continue sendo uma string válida:

```c
char s[] = "   pato";
char *inicio = s;

while (*inicio == ' ') {
  inicio++;
}

// inicio aponta para "pato", 3 bytes à frente de s
memmove(s, inicio, strlen(inicio) + 1);
// s == "pato"
```

> Diferente do `memcpy`, que pode ser um pouco mais rápido mas só funciona quando as regiões não se sobrepõem, o `memmove` é sempre seguro. Na dúvida, ou sempre que origem e destino estiverem no mesmo array, use o `memmove`

> O `memmove` nunca diminui, aumenta ou libera a memória de nenhum ponteiro: ele apenas sobrescreve os `n` bytes de `dest` com o conteúdo de `src`, havendo sobreposição ou não. O bloco continua com exatamente o mesmo tamanho alocado, e os bytes que "sobram" no fim (como o último `50` no exemplo de remoção) continuam lá. Quem define quantos elementos são válidos é o seu próprio contador (`total`), ou o `\0` no caso de strings. Para realmente reduzir a memória ocupada, é preciso chamar `realloc` depois do `memmove`
