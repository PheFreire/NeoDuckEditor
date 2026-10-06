**Macros variádicas**

> diretiva do pré-processador, não precisa de nenhum header

Uma macro variádica aceita um número variável de argumentos, usando `...` na lista de parâmetros e `__VA_ARGS__` no texto, o que permite repassar os argumentos para funções como o `printf` e criar macros de log

> Uma função `variádica` é uma função que aceita quantos argumentos quiser, como o `printf` (`int printf(const char *format, ...)`). Uma macro variádica é o equivalente no pré-processador, e normalmente serve justamente para envolver uma dessas funções

```c
#define NOME(fixo, ...) texto usando fixo e __VA_ARGS__
```

- `...`: precisa ser o último parâmetro, e representa todos os argumentos que sobrarem depois dos fixos
- `__VA_ARGS__`: é substituído por esses argumentos, exatamente como foram escritos, incluindo as vírgulas entre eles
- Pode haver parâmetros fixos antes do `...`, ou nenhum (`#define NOME(...)`)

```c
#define PRINT(...) printf(__VA_ARGS__)

PRINT("ola\n");             // printf("ola\n");
PRINT("%d + %d\n", 1, 2);   // printf("%d + %d\n", 1, 2);
```

**Macro de log com prefixo**

Usando um parâmetro fixo para o formato, é possível juntar um texto antes dele (strings lado a lado são juntadas pelo compilador):

```c
#define LOG(fmt, ...) fprintf(stderr, "[log] " fmt "\n", __VA_ARGS__)

LOG("usuario %s entrou", "pato");
// vira:  fprintf(stderr, "[log] " "usuario %s entrou" "\n", "pato");
// saída: [log] usuario pato entrou
```

**O problema da vírgula sobrando**

Com a macro acima, chamar `LOG` só com o formato deixa uma vírgula sem nada depois, o que é um erro de compilação:

```c
LOG("iniciando");
// vira: fprintf(stderr, "[log] " "iniciando" "\n", );
//                                                 ^ vírgula sobrando
```

Há duas soluções, dependendo da versão do C:

```c
// C23: __VA_OPT__(,) só coloca a vírgula se houver argumentos
#define LOG(fmt, ...) fprintf(stderr, "[log] " fmt "\n" __VA_OPT__(,) __VA_ARGS__)

// extensão do GCC e do Clang, funciona em versões antigas: ## antes de
// __VA_ARGS__ apaga a vírgula anterior quando não há argumentos
#define LOG(fmt, ...) fprintf(stderr, "[log] " fmt "\n", ##__VA_ARGS__)

LOG("iniciando");           // fprintf(stderr, "[log] " "iniciando" "\n");
LOG("porta %d", 8080);      // fprintf(stderr, "[log] " "porta %d" "\n", 8080);
```

**Log com arquivo e linha**

Combinando com as macros predefinidas, cada mensagem mostra de onde veio, sem precisar escrever isso em cada chamada:

```c
#define LOG(fmt, ...) \
  fprintf(stderr, "%s:%d: " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)

LOG("abrindo %s", "dados.txt");
// saída: main.c:12: abrindo dados.txt
```

**Log que some sem DEBUG**

```c
#ifdef DEBUG
#define DLOG(fmt, ...) fprintf(stderr, "[debug] " fmt "\n", ##__VA_ARGS__)
#else
#define DLOG(fmt, ...) ((void)0)
#endif
```

> Diferente de uma função variádica, que recebe os argumentos já calculados e precisa da `stdarg.h` (`va_list`, `va_arg`) para lê-los um a um, uma macro variádica só repassa o texto dos argumentos adiante. Ela não sabe quantos são nem de que tipo, então não verifica nada sozinha, deixando essa checagem para a função que vai recebê-los
