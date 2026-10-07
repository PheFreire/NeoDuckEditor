**padding em structs**

> regra da linguagem, `offsetof` vem de `stddef.h` e `alignof` de `stdalign.h` (palavra-chave a partir do C23)

Padding são bytes vazios que o compilador insere entre os campos de uma struct, e no final dela, para que cada campo comece em um endereço alinhado. Por isso o tamanho de uma struct quase nunca é a soma dos tamanhos dos campos

> O processador lê a memória em blocos. Um `int` de 4 bytes que começa em um endereço múltiplo de 4 é lido de uma vez, mas um que começa no meio de um bloco pode exigir duas leituras, ou nem ser permitido em algumas arquiteturas. O alinhamento de um tipo é o número do qual o endereço dele precisa ser múltiplo

```c
alignof(tipo)          // alinhamento exigido pelo tipo, em bytes
sizeof(struct x)       // tamanho total, padding incluído
offsetof(struct x, c)  // em qual byte o campo c começa
```

- Cada campo começa em um endereço múltiplo do seu alinhamento
- O tamanho total é arredondado para um múltiplo do maior alinhamento entre os campos, para que todos os elementos de um array de structs continuem alinhados
- O primeiro campo sempre começa no byte `0`, nunca existe padding antes dele
- Na prática, o alinhamento de um tipo básico é igual ao seu tamanho: `char` 1, `short` 2, `int` e `float` 4, `double`, `long` e ponteiros 8 (em sistemas de 64 bits)

---

**A ordem dos campos importa**

```c
struct ruim {
  char a;     // 1 + 7 de padding
  double b;   // 8
  char c;     // 1 + 7 de padding no final
};            // sizeof == 24

struct boa {
  double b;   // 8
  char a;     // 1
  char c;     // 1 + 6 de padding no final
};            // sizeof == 16
```

```c
// memória de struct ruim:
// byte:  0   1 ... 7     8 ... 15   16   17 ... 23
//        a   [padding]   b          c    [padding]

// memória de struct boa:
// byte:  0 ... 7   8   9   10 ... 15
//        b         a   c   [padding]
```

- Os mesmos três campos ocupam 24 ou 16 bytes dependendo só da ordem
- Ordenar os campos do maior alinhamento para o menor reduz o padding ao mínimo
- O compilador nunca reordena os campos sozinho, a ordem na memória é sempre a da declaração

---

**sizeof e offsetof**

```c
#include <stddef.h>

offsetof(struct ruim, a);  // 0
offsetof(struct ruim, b);  // 8
offsetof(struct ruim, c);  // 16
sizeof(struct ruim);       // 24
```

- O `sizeof` de uma struct nunca é menor que a soma dos campos e muitas vezes é maior, por isso use sempre `sizeof(struct x)` e nunca a soma feita à mão
- O `offsetof` e o `container_of` estão explicados em `../../macros/struct_macros.md`

---

**Vendo o padding na compilação**

```sh
gcc -Wpadded main.c
# warning: padding struct to align 'b' [-Wpadded]
# warning: padding struct size to alignment boundary with 7 bytes [-Wpadded]
```

- O `-Wpadded` não faz parte do `-Wall` nem do `-Wextra`, pois avisa em quase toda struct. É útil para analisar uma struct específica, não para deixar sempre ligado
- Um `static_assert(sizeof(struct x) == 16, "...")` garante que ninguém aumente a struct sem perceber (ver `../../tests/static_assert.md`)

---

**Padding e o conteúdo dos bytes**

O valor dos bytes de padding não é definido: podem conter qualquer lixo, mesmo quando todos os campos foram preenchidos. Isso afeta tudo que trata a struct como uma sequência de bytes:

- `memcmp` entre duas structs pode dizer que são diferentes mesmo com todos os campos iguais
- Gravar a struct inteira em um arquivo com `fwrite` grava também o lixo do padding, e o layout pode mudar entre compiladores e arquiteturas
- Mandar a struct pela rede vaza o conteúdo antigo da memória que ficou no padding

```c
struct ruim r;
memset(&r, 0, sizeof r);  // zera também o padding
r.a = 'x';
r.b = 1.0;
r.c = 'y';
```

> O `memset` antes de preencher deixa o padding zerado, mas não resolve o problema de layout. Para arquivos e rede, o certo é gravar campo a campo em um formato definido, e nunca a struct inteira de uma vez
