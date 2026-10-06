**TextToInteger**

> `raylib.h` — módulo `rtext`

O `TextToInteger` converte o início de uma string em um número inteiro, lendo os dígitos até encontrar um caractere que não seja dígito

```c
int TextToInteger(const char *text);
```

- `text`: a string com o número

- Devolve o número lido
- Aceita um sinal `-` ou `+` no início (o comentário no header diz que negativos não são suportados, mas no raylib 5.5 o `-` funciona)
- Para no primeiro caractere que não é dígito: `"42abc"` devolve `42`
- Sem nenhum dígito no início, devolve `0`, sem nenhum aviso de erro

```c
TextToInteger("42");      // 42
TextToInteger("-5");      // -5
TextToInteger("42abc");   // 42
TextToInteger("abc");     // 0
```

```c
// campo de texto numérico digitado pelo usuário
int quantidade = TextToInteger(campo_texto);
if (quantidade <= 0) quantidade = 1;
```

> Assim como o `atoi`, não há como diferenciar `"0"` de um texto inválido pelo retorno. Para validar a entrada do usuário ou detectar números grandes demais, use o `strtol` (ver `../../../string/casting/atoi.md` e `../../../string/casting/strtol.md`)
