**Macros predefinidas**

> definidas pelo compilador, não precisam de nenhum header

O compilador já define uma série de macros por conta própria, que informam o arquivo e a linha atuais, a data da compilação, a versão do C e a plataforma, podendo ser usadas em qualquer lugar do código sem nenhum `#define`

> Por serem macros, elas são trocadas pelo valor no momento do pré-processamento, no ponto exato onde aparecem. `__LINE__` não é "a linha atual do programa rodando", é o número da linha onde ela foi escrita no arquivo fonte, colado ali como um número fixo

- `__FILE__`: o nome do arquivo fonte atual, como string (`"main.c"`, ou o caminho como foi passado ao compilador)
- `__LINE__`: o número da linha atual, como inteiro (`42`)
- `__DATE__`: a data da compilação, como string no formato `"Mmm dd yyyy"` (`"Oct  3 2026"`)
- `__TIME__`: a hora da compilação, como string no formato `"hh:mm:ss"`
- `__STDC__`: vale `1` se o compilador segue o padrão C
- `__STDC_VERSION__`: a versão do C usada na compilação, como `long`
	- `199901L`: C99
	- `201112L`: C11
	- `201710L`: C17
	- `202311L`: C23

```c
printf("arquivo: %s\n", __FILE__);  // arquivo: main.c
printf("linha: %d\n", __LINE__);    // linha: 2
printf("compilado em %s às %s\n", __DATE__, __TIME__);
```

---

**__func__**

Não é uma macro, mas costuma ser usado junto com elas: dentro de toda função, existe uma variável `static const char __func__[]` com o nome da função atual

```c
void conectar(void) {
  printf("%s\n", __func__); // conectar
}
```

> Por não ser uma macro, `__func__` não pode ser juntado com outras strings literais (`"erro em " __func__` não compila). Ele precisa ser passado como argumento, com `%s`

---

**Macro de erro com localização**

Como `__FILE__` e `__LINE__` são expandidas onde a macro é usada, e não onde ela foi definida, uma macro de log consegue mostrar exatamente de onde foi chamada, coisa que uma função não conseguiria:

```c
#define ERRO(msg) \
  fprintf(stderr, "%s:%d (%s): %s\n", __FILE__, __LINE__, __func__, msg)

void carregar(void) {
  ERRO("arquivo corrompido");
  // saída: main.c:7 (carregar): arquivo corrompido
}
```

---

**Macros de plataforma**

Não fazem parte do padrão, mas todo compilador define macros indicando o sistema e o compilador, usadas com `#if defined(...)`:

- `__linux__`: Linux
- `__APPLE__`: macOS e iOS
- `_WIN32`: Windows (32 e 64 bits)
- `__GNUC__`: compilado com GCC (o Clang também define, por compatibilidade)
- `__clang__`: compilado com Clang

```c
#if defined(__linux__)
const char *sistema = "linux";
#elif defined(__APPLE__)
const char *sistema = "macos";
#elif defined(_WIN32)
const char *sistema = "windows";
#endif
```

Para ver todas as macros que o compilador define na sua máquina:

```sh
gcc -dM -E - < /dev/null
```

> Diferente de uma variável, que guarda um valor enquanto o programa roda, `__LINE__` e `__FILE__` são fixados no texto antes da compilação. Por isso usá-las dentro de uma função de log sempre mostraria a linha da função de log, e só funcionam para indicar a origem quando usadas dentro de uma macro
