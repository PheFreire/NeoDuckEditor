**stdarg.h**

> `stdarg.h`

A `stdarg.h` tem o tipo e as macros usados para ler os argumentos extras de uma função variádica: um cursor (`va_list`) que é posicionado no primeiro argumento depois do `...` e avançado um argumento por vez

> Os argumentos de uma chamada ficam em registradores e na pilha, em posições que a convenção de chamada da plataforma define. O `va_list` esconde esses detalhes: em algumas plataformas ele é só um ponteiro para a pilha, em outras (como x86-64 e ARM64) é uma struct que lembra quais registradores já foram lidos

```c
#include <stdarg.h>

void va_start(va_list ap, ultimo_fixo);
tipo va_arg(va_list ap, tipo);
void va_end(va_list ap);
void va_copy(va_list destino, va_list origem);
```

- `va_list`: o tipo do cursor. Declarado como uma variável local comum (`va_list args;`)
- `va_start(ap, ultimo_fixo)`: inicializa o cursor no primeiro argumento extra. O segundo argumento precisa ser o **último** parâmetro antes do `...`
- `va_arg(ap, tipo)`: devolve o próximo argumento interpretado como `tipo` e avança o cursor. O tipo precisa ser o tipo **promovido** do argumento (ver `type-promotion.md`)
- `va_end(ap)`: encerra o uso do cursor. Toda chamada de `va_start` ou `va_copy` precisa de um `va_end` na mesma função
- `va_copy(destino, origem)`: cria um segundo cursor na mesma posição do primeiro

Apesar da aparência, todas são **macros**, e não funções. Por isso o `va_arg` consegue receber um tipo (`const char *`) como argumento, algo que uma função não aceita

---

**O ciclo de uso**

```c
#include <stdarg.h>

int soma(int n, ...) {
  va_list args;
  va_start(args, n);           // 1. inicializa depois de n

  int total = 0;
  for (int i = 0; i < n; i++) {
    total += va_arg(args, int);  // 2. lê um int por vez
  }

  va_end(args);                // 3. encerra
  return total;
}

soma(3, 10, 20, 30);  // 60
```

- O `va_arg` não sabe quando os argumentos acabam. Chamar além da quantidade real lê lixo da memória
- Também não sabe o tipo real: ler como `int` um argumento que foi passado como `double` devolve um valor sem sentido

---

**va_copy: percorrendo duas vezes**

O cursor só anda para frente. Para ler os argumentos duas vezes, a cópia precisa ser feita **antes** da primeira leitura:

```c
void imprimir_duas_vezes(int n, ...) {
  va_list args, copia;
  va_start(args, n);
  va_copy(copia, args);         // cópia na mesma posição

  for (int i = 0; i < n; i++) printf("%d ", va_arg(args, int));
  for (int i = 0; i < n; i++) printf("%d ", va_arg(copia, int));

  va_end(copia);                // um va_end para cada cursor
  va_end(args);
}

imprimir_duas_vezes(2, 1, 2);   // 1 2 1 2
```

- Atribuir um `va_list` a outro (`copia = args`) não funciona em todas as plataformas, pois em algumas ele é um array. O `va_copy` é a única forma portável
- O caso mais comum é medir o tamanho de um texto com `vsnprintf` e depois escrevê-lo (ver `va-list-forwarding.md`)

> Um `va_list` pode ser passado para outra função como argumento, mas depois que ela usar o `va_arg` nele, o cursor da função original fica em um estado indefinido. Não continue lendo dele depois de passá-lo adiante, a não ser que tenha feito uma cópia com `va_copy` antes
