**sprintf**

> `stdio.h`

O `sprintf` escreve texto formatado dentro de uma string, funcionando como um `printf` cujo destino é um buffer em vez da tela. Converte números (e outros valores) em string, mas **sem nenhum limite de tamanho**: escreve quantos caracteres o texto precisar, mesmo que o buffer não tenha espaço para eles

```c
int sprintf(char *str, const char *format, ...);
```

- `str`: o buffer que você já possui, para onde o texto formatado vai ser escrito. Precisa ter espaço para o texto inteiro mais o `\0`
- `format`: a string de formato, com os mesmos especificadores do `printf` (`%d`, `%f`, `%s`, `%x`, etc)
- `...`: os valores que vão substituir os especificadores em `format`

- Devolve a quantidade de caracteres escritos, sem contar o `\0`. Devolve um valor negativo se ocorrer erro de formatação
- Sempre adiciona o `\0` no final do texto escrito
- Não recebe o tamanho do buffer, então não tem como saber se o texto cabe: se não couber, continua escrevendo na memória que vem depois do buffer, causando um **buffer overflow**
- Usar o próprio `str` como um dos argumentos (`sprintf(buf, "%s!", buf)`) é comportamento indefinido, pois a origem e o destino se sobrepõem

```c
char buf[32];
sprintf(buf, "%d", 42);                  // "42"
sprintf(buf, "%.2f", 3.14159);           // "3.14"
sprintf(buf, "%x", 255);                 // "ff"
sprintf(buf, "id=%d nome=%s", 7, "ana"); // "id=7 nome=ana"
```

Usando o retorno para continuar escrevendo a partir do fim do texto anterior:

```c
char buf[64];
int pos = 0;
pos += sprintf(buf + pos, "x=%d ", 10);
pos += sprintf(buf + pos, "y=%d", 20);
// buf == "x=10 y=20", pos == 9
```

---

**O problema do buffer overflow**

```c
char buf[8];
sprintf(buf, "usuario: %s", nome); // "usuario: " já tem 9 caracteres
// escreve além dos 8 bytes de buf, sobrescrevendo outras variáveis da pilha
```

- O resultado depende de quais dados estavam depois do buffer: o programa pode continuar rodando com variáveis corrompidas, travar mais tarde em outro ponto ou ser explorado para executar código, quando o texto vem do usuário (`%s` com uma entrada externa)
- O GCC avisa em alguns casos em que o tamanho dá para ser calculado na compilação (`-Wformat-overflow`, incluído no `-Wall`), e o AddressSanitizer detecta o overflow em tempo de execução, mas nenhum dos dois cobre todos os casos
- No macOS, o SDK marca o `sprintf` como obsoleto (deprecated), e o compilador emite um aviso sugerindo o `snprintf`

> Prefira sempre o `snprintf`, que recebe o tamanho do buffer e nunca escreve além dele. O `sprintf` só é seguro quando o tamanho máximo do texto é conhecido e cabe com folga no buffer, como em `char buf[16]; sprintf(buf, "%d", n);`, já que um `int` de 32 bits tem no máximo 11 caracteres (`-2147483648`)
