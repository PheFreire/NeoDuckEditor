**ctime / asctime**

> `time.h`

O `ctime` e o `asctime` transformam uma data em um texto com formato fixo, em inglês, como `"Sun Oct  4 15:00:00 2026\n"`, sendo a forma mais rápida de mostrar uma data, mas sem nenhum controle sobre o formato

> As duas funções devolvem um ponteiro para um buffer estático, interno da biblioteca, que é sobrescrito a cada chamada, e por isso não são seguras com threads. Ambas foram marcadas como obsoletas no C23, em favor do `strftime`

```c
char *ctime(const time_t *t);
char *asctime(const struct tm *t);
```

- `ctime`: recebe um `time_t` e converte usando o fuso local, equivalente a `asctime(localtime(t))`
- `asctime`: recebe uma `struct tm` já convertida

- Devolvem um ponteiro para o texto, sempre no formato `"Www Mmm dd hh:mm:ss yyyy\n"`, com 26 bytes incluindo o `\n` e o `\0`
- O texto termina com `\n`, o que costuma atrapalhar ao usar dentro de outra mensagem
- O dia do mês é preenchido com espaço, e não com zero (`"Oct  4"`)

```c
time_t agora = time(NULL);

printf("%s", ctime(&agora));
// Sun Oct  4 15:00:00 2026

struct tm utc;
gmtime_r(&agora, &utc);
printf("%s", asctime(&utc));
// Sun Oct  4 18:00:00 2026
```

**O \n no final**

```c
printf("agora: %s.\n", ctime(&agora));
// agora: Sun Oct  4 15:00:00 2026
// .
```

Para remover, substitui-se o `\n` por `\0`:

```c
char *texto = ctime(&agora);
texto[strcspn(texto, "\n")] = '\0';
printf("agora: %s.\n", texto);
// agora: Sun Oct  4 15:00:00 2026.
```

**Versões seguras**

O POSIX tem as versões `ctime_r` e `asctime_r`, que escrevem em um buffer seu de pelo menos 26 bytes:

```c
char buffer[26];
ctime_r(&agora, buffer);
```

> Diferente do `strftime`, que permite qualquer formato, em qualquer idioma, com tamanho de buffer controlado e sem `\n` no final, o `ctime` e o `asctime` só servem para depuração rápida. Em qualquer saída que o usuário vai ler ou que será gravada, use `strftime`
