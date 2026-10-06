**#if / #elif**

> diretiva do pré-processador, não precisa de nenhum header

O `#if` mantém ou apaga um trecho de código antes da compilação de acordo com o resultado de uma expressão constante, permitindo escolher entre várias versões com `#elif` e combinar condições com `&&`, `||` e `!`

> O pré-processador avalia a expressão do `#if` antes de o programa existir, então ela só pode usar números inteiros, macros e o operador `defined`. Variáveis, `sizeof`, casts e chamadas de função não podem aparecer, pois só existem depois da compilação

```c
#if expressão
  // mantido se a expressão for diferente de 0
#elif outra_expressão
  // mantido se a primeira for 0 e esta for diferente de 0
#else
  // mantido se nenhuma das anteriores for verdadeira
#endif
```

- `expressão`: uma conta com inteiros e macros, considerada verdadeira se o resultado for diferente de `0`
- `#elif`: opcional, pode aparecer várias vezes, como um `else if`
- `#else`: opcional, o trecho mantido quando nenhuma condição é verdadeira
- `#endif`: obrigatório, fecha o bloco

- `defined(NOME)` vale `1` se a macro existe e `0` se não, podendo ser combinado com outros operadores
- Um nome que não é macro dentro de um `#if` vale `0` sem nenhum aviso, então um erro de digitação (`#if DEBGU`) simplesmente desativa o trecho

---

**Combinando condições com defined**

```c
#if defined(DEBUG) && !defined(SEM_LOG)
  // só com DEBUG definida e SEM_LOG não definida
#endif
```

---

**Comparando valores**

```c
#define NIVEL_LOG 2

#if NIVEL_LOG >= 3
#define LOG_DETALHADO 1
#elif NIVEL_LOG >= 1
#define LOG_SIMPLES 1
#endif
```

---

**Detectando o sistema operacional**

O compilador já define macros que indicam a plataforma, permitindo escrever um único código para vários sistemas:

```c
#if defined(_WIN32)
#include <windows.h>
#define SEPARADOR '\\'
#elif defined(__linux__) || defined(__APPLE__)
#include <unistd.h>
#define SEPARADOR '/'
#else
#error "sistema operacional não suportado"
#endif
```

---

**Exigindo uma versão do C**

```c
#if __STDC_VERSION__ >= 201112L
  // pode usar recursos do C11, como _Static_assert
#endif
```

---

**Desativando um bloco com #if 0**

Uma forma de "comentar" um trecho grande de código, que funciona mesmo quando ele já contém comentários `/* */` (que não podem ser aninhados):

```c
#if 0
int funcao_antiga(void) {
  /* este comentário não quebra nada */
  return 0;
}
#endif
```

> Diferente de um `if` comum, que é compilado inteiro e escolhe o caminho em tempo de execução, o `#if` apaga os trechos falsos antes da compilação, então o código descartado não gera instrução nenhuma no executável. Para só testar se um nome existe, `#ifdef` (em `ifdef.md`) é a forma mais curta
