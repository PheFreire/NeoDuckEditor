**uintmax_t**

> `stdint.h`

O `uintmax_t` é o maior tipo inteiro sem sinal disponível no compilador, garantido para conseguir guardar qualquer valor de qualquer outro tipo inteiro sem sinal (`unsigned int`, `size_t`, `uint64_t`, etc) sem perder informação

> Tipos como `int` e `long` não têm tamanho fixo em C: um `long` tem 8 bytes no Linux 64 bits, mas 4 bytes no Windows. A `stdint.h` define tipos com tamanho garantido (`uint8_t`, `uint32_t`, `uint64_t`) e os tipos "máximos" `uintmax_t` e `intmax_t`, que se adaptam ao maior inteiro da plataforma

```c
typedef /* maior inteiro sem sinal da plataforma */ uintmax_t;
```

- Na prática, em sistemas de 64 bits, tem 8 bytes (64 bits), indo de `0` até `UINTMAX_MAX` (`18446744073709551615`)
- Existe a versão com sinal, `intmax_t`, que vai de `INTMAX_MIN` até `INTMAX_MAX`
- No `printf` e no `scanf` usa-se o modificador `j`: `%ju` para `uintmax_t` e `%jd` para `intmax_t`
- Para converter uma string diretamente para `uintmax_t` existe o `strtoumax`, de `inttypes.h`, que funciona igual ao `strtol`

O uso mais comum é imprimir tipos cujo tamanho real você não conhece, como os campos de um `struct stat` (`ino_t`, `nlink_t`, etc). Em vez de adivinhar se o certo é `%u`, `%lu` ou `%llu`, converte-se para `uintmax_t` e usa-se sempre `%ju`, que funciona em qualquer plataforma:

```c
struct stat info;
stat("dados.txt", &info);

// ino_t pode ser unsigned long em uma plataforma e unsigned long long em outra
printf("inode: %ju\n", (uintmax_t)info.st_ino);
```

Também serve para fazer uma conta intermediária com o máximo de espaço possível antes de verificar se o resultado cabe em um tipo menor:

```c
unsigned int a = 4000000000u;
unsigned int b = 2;

uintmax_t resultado = (uintmax_t)a * b; // feito em 64 bits, sem estourar

if (resultado > UINT_MAX) { // UINT_MAX vem de limits.h
  // não cabe de volta em um unsigned int
}
```

> Diferente do `uint64_t`, que tem sempre exatamente 64 bits, o `uintmax_t` não promete um tamanho fixo, apenas que é o maior. Por isso ele é ideal para imprimir e converter valores de forma genérica, mas o `uint64_t` é a escolha certa quando o tamanho exato importa, como em formatos de arquivo e protocolos de rede
