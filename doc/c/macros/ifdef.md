**#ifdef / #ifndef**

> diretiva do pré-processador, não precisa de nenhum header

O `#ifdef` e o `#ifndef` mantêm ou apagam um trecho de código antes da compilação, dependendo de uma macro estar definida ou não, permitindo gerar versões diferentes do programa a partir do mesmo código fonte (compilação condicional)

> Um trecho apagado pelo pré-processador não existe para o compilador: ele não é compilado, não gera código e nem precisa estar correto. É diferente de um `if` comum, que é compilado inteiro e só decide qual caminho seguir enquanto o programa roda

```c
#ifdef NOME
  // mantido se NOME estiver definida
#else
  // mantido se NOME não estiver definida
#endif

#ifndef NOME
  // mantido se NOME não estiver definida
#endif
```

- `#ifdef NOME`: verdadeiro se `NOME` foi definida com `#define`, não importa o valor (até `#define NOME` sem valor nenhum conta)
- `#ifndef NOME`: o contrário, verdadeiro se `NOME` não foi definida
- `#else`: opcional, o trecho mantido quando a condição é falsa
- `#endif`: obrigatório, fecha o bloco

- Os blocos podem ser aninhados, e cada `#ifdef` / `#ifndef` precisa do seu próprio `#endif`
- Por ser fácil se perder em blocos longos, é comum comentar o `#endif` com o nome da macro: `#endif // DEBUG`

**Definindo a macro pelo compilador**

Em vez de escrever o `#define` no código, a macro pode ser definida na linha de compilação com `-D`, o que permite trocar de versão sem editar nenhum arquivo:

```sh
gcc main.c -o programa           # DEBUG não definida
gcc -DDEBUG main.c -o programa   # equivale a #define DEBUG 1 no topo do arquivo
gcc -DNIVEL=3 main.c -o programa # equivale a #define NIVEL 3
```

**Código só para debug**

```c
int dividir(int a, int b) {
#ifdef DEBUG
  printf("dividir(%d, %d)\n", a, b);
#endif
  return a / b;
}
```

Compilado normalmente, o `printf` nem chega ao compilador. Compilado com `-DDEBUG`, ele aparece em toda chamada

**Valor padrão para uma configuração**

O `#ifndef` permite definir um valor só se ninguém tiver definido antes, deixando quem compila sobrescrever com `-D`:

```c
#ifndef TAMANHO_BUFFER
#define TAMANHO_BUFFER 1024
#endif

char buffer[TAMANHO_BUFFER]; // 1024, ou o valor passado em -DTAMANHO_BUFFER=...
```

**Macro de log que some em produção**

```c
#ifdef DEBUG
#define LOG(msg) fprintf(stderr, "[debug] %s\n", msg)
#else
#define LOG(msg) ((void)0)
#endif

LOG("iniciando"); // sem -DDEBUG vira ((void)0);, que não faz nada
```

> Diferente do `#if`, que testa o valor de uma expressão, o `#ifdef` só pergunta se o nome existe. `#ifdef X` equivale a `#if defined(X)`, e quando é preciso combinar mais de uma condição (`&&`, `||`) ou comparar valores, o `#if` com `defined` é a forma a ser usada. O uso mais comum do `#ifndef` é o include guard, explicado em `include_guard.md`
