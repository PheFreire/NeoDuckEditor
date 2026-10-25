**Funções variádicas**

> `stdarg.h`

Uma função variádica aceita uma quantidade variável de argumentos, como o `printf`, que recebe um formato e depois quantos valores forem necessários. Ela é declarada com `...` no fim da lista de parâmetros, e os argumentos extras são lidos um por um dentro da função com as macros da `stdarg.h`

> Os argumentos de uma chamada ficam guardados em registradores e na pilha, em posições que a convenção de chamada da plataforma define. Uma função normal sabe pelo protótipo quantos são e de que tipo. Uma função variádica não sabe: o `...` só diz "pode haver mais", então é a própria função que precisa descobrir quantos argumentos vieram e qual o tipo de cada um, e a `stdarg.h` dá as ferramentas para ir buscá-los

```c
#include <stdarg.h>

tipo nome(tipo fixo, ...);

void va_start(va_list ap, fixo);
tipo va_arg(va_list ap, tipo);
void va_end(va_list ap);
void va_copy(va_list destino, va_list origem);
```

- `...`: precisa ser o último parâmetro. Até o C17, também precisa de pelo menos um parâmetro fixo antes dele
- `va_list`: o tipo que guarda a posição atual na lista de argumentos extras, como um cursor
- `va_start`: inicializa o `va_list`, apontando para o primeiro argumento depois do parâmetro fixo informado, que precisa ser o **último** parâmetro antes do `...`
- `va_arg`: devolve o próximo argumento, interpretado como o `tipo` informado, e avança o cursor
- `va_end`: encerra o uso do `va_list`. Toda chamada de `va_start` precisa de um `va_end` correspondente na mesma função
- `va_copy`: cria uma cópia do `va_list` na posição atual, para percorrer os argumentos duas vezes

Apesar da aparência, `va_start`, `va_arg` e `va_end` são **macros**, e não funções. Por isso o `va_arg` consegue receber um tipo (`char*`) como argumento, algo que uma função não aceita

---

**Exemplo**

```c
#include <stdio.h>
#include <stdarg.h>

// O primeiro parâmetro 'count' diz quantos argumentos foram passados
void imprimir_verde(int count, ...) {
    va_list args;
    va_start(args, count); // Inicializa a lista de argumentos

    printf("\033[32m"); // Ativa a cor verde

    for (int i = 0; i < count; i++) {
        // va_arg extrai o próximo argumento (especificando o tipo, ex: char*)
        char *texto = va_arg(args, char*);
        printf("%s ", texto);
    }

    printf("\033[0m\n"); // Reseta a cor

    va_end(args); // Limpa a memória da lista
}

int main() {
    // Chamada informando que são 3 strings
    imprimir_verde(3, "Texto 1", "Texto 2", "Texto infinitos...");
    return 0;
}
```

```text
Texto 1 Texto 2 Texto infinitos...      (em verde no terminal)
```

- `int count`: o parâmetro fixo. Além de ser obrigatório antes do `...`, é ele que diz quantas vezes o `va_arg` pode ser chamado
- `va_start(args, count)`: posiciona o cursor logo depois de `count`, no `"Texto 1"`
- `va_arg(args, char*)`: cada chamada devolve uma das strings, na ordem em que foram passadas, e avança para a próxima
- `va_end(args)`: encerra a leitura. Ele não libera memória do heap (nenhum `malloc` foi feito), só deixa o `va_list` em um estado final. Na maioria das plataformas não faz nada, mas o padrão exige a chamada, e pular é comportamento indefinido
- `"\033[32m"` e `"\033[0m"`: códigos ANSI que o terminal entende como "mudar a cor do texto para verde" e "voltar para a cor padrão". Não têm relação com a `stdarg.h`

---

**Como a função sabe quantos argumentos vieram**

A `stdarg.h` não tem nenhuma forma de contar os argumentos nem de saber o tipo deles. A informação precisa vir de algum lugar, e há três formas comuns:

- **Um contador**: um parâmetro fixo com a quantidade, como o `count` do exemplo
- **Um sentinela**: um valor especial no fim da lista, normalmente `NULL`, que indica que os argumentos acabaram
- **Uma string de formato**: como no `printf`, onde cada `%d`, `%s` e `%f` diz o tipo e a quantidade dos argumentos seguintes

```c
void juntar(const char *primeiro, ...) {
  va_list args;
  va_start(args, primeiro);
  for (const char *s = primeiro; s != NULL; s = va_arg(args, const char *)) {
    printf("%s", s);
  }
  va_end(args);
  printf("\n");
}

juntar("pa", "to", "!", NULL);  // pato!
```

- O sentinela evita precisar contar os argumentos na chamada, mas esquecer o `NULL` no final faz a função continuar lendo valores que não existem

---

**Promoção dos argumentos**

Os argumentos que caem no `...` passam pelas `default argument promotions` antes de serem enviados, pois a função não tem um protótipo dizendo o tipo deles:

- `char` e `short` viram `int`
- `float` vira `double`

Por isso o `va_arg` deve sempre usar o tipo **promovido**:

```c
float f = va_arg(args, float);   // errado: o valor chegou como double
double d = va_arg(args, double); // certo

char c = va_arg(args, char);     // errado: o valor chegou como int
char c2 = (char)va_arg(args, int); // certo
```

```text
warning: second argument to 'va_arg' is of promotable type 'float'; this va_arg has undefined behavior because arguments will be promoted to 'double' [-Wvarargs]
```

- É por isso que o `printf` usa o mesmo `%f` para `float` e para `double`: ele sempre recebe um `double`

O tipo de quem chama também precisa bater com o que a função lê, e o compilador não converte nada sozinho:

```c
double media(int n, ...);   // lê cada argumento com va_arg(args, double)

media(3, 1.0, 2.0, 4.5);    // 2.50
media(2, 1, 2);             // lixo: 1 e 2 são int, e a função os lê como double
```

---

**Repassando para outra função variádica**

Uma função variádica não consegue repassar o seu `...` direto para outra. Para isso a biblioteca padrão tem versões que recebem um `va_list` no lugar do `...`, com um `v` no começo do nome: `vprintf`, `vfprintf`, `vsnprintf`, `vsprintf`

```c
#include <stdarg.h>
#include <stdio.h>

__attribute__((format(printf, 1, 2)))
void logar(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  fprintf(stderr, "[log] ");
  vfprintf(stderr, fmt, args);   // usa os argumentos que vieram no ...
  fprintf(stderr, "\n");
  va_end(args);
}

logar("porta %d", 8080);    // [log] porta 8080
logar("porta %d", "8080");  // warning: format specifies type 'int' but the argument has type 'char *'
```

- O `va_list` só pode ser percorrido uma vez. Para usá-lo em duas funções (por exemplo, `vsnprintf` para medir o tamanho e outra para escrever), faça uma cópia antes com `va_copy`, e chame `va_end` nas duas
- `__attribute__((format(printf, 1, 2)))`: extensão do GCC e do Clang que diz "o parâmetro 1 é um formato do `printf`, e os argumentos começam no 2". Com ela, o compilador passa a verificar os tipos das chamadas de `logar` como faz com o `printf`

---

**C23: ... sem parâmetro fixo**

```c
int primeiro(...) {
  va_list args;
  va_start(args);          // C23: sem o segundo argumento
  int x = va_arg(args, int);
  va_end(args);
  return x;
}
```

- A partir do C23, uma função pode ter só o `...`, e o `va_start` recebe apenas o `va_list`
- Antes do C23 isso é erro de compilação: `ISO C requires a named parameter before '...'`

> Uma função variádica não tem nenhuma verificação de tipo nem de quantidade: passar menos argumentos do que a função lê, ou de um tipo diferente, compila sem erro e é comportamento indefinido, normalmente lendo lixo da pilha ou causando um crash. Prefira um array e um tamanho (`void f(const char **textos, int n)`) quando todos os argumentos têm o mesmo tipo, e deixe as funções variádicas para quando os tipos mudam, como no `printf`. Para receber um número variável de argumentos no pré-processador, veja `macros/variadic.md`
