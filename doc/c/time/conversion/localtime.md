**localtime**

> `time.h`

O `localtime` converte um `time_t` em uma `struct tm` com a data e hora no fuso horário local da máquina, já considerando o horário de verão, sendo o passo necessário para mostrar ou ler partes de uma data como o usuário a vê

> O fuso horário local vem da variável de ambiente `TZ` ou, se ela não existir, da configuração do sistema (`/etc/localtime` no Linux e no macOS). O mesmo `time_t` gera horas diferentes em máquinas configuradas com fusos diferentes

```c
struct tm *localtime(const time_t *t);
struct tm *localtime_r(const time_t *t, struct tm *resultado); // POSIX, e C23
```

- `t`: ponteiro para o instante a ser convertido
- `resultado`: no `localtime_r`, a struct que você já possui, onde o resultado vai ser escrito

- Devolve um ponteiro para a `struct tm` preenchida, ou `NULL` se a conversão falhar (por exemplo, um ano que não cabe em um `int`)
- Preenche todos os campos, inclusive `tm_wday`, `tm_yday` e `tm_isdst`
- O `localtime` devolve um ponteiro para uma struct estática, interna da biblioteca, que é sobrescrita a cada nova chamada de `localtime` ou `gmtime`

```c
time_t agora = time(NULL);
struct tm *t = localtime(&agora);

printf("%02d:%02d\n", t->tm_hour, t->tm_min); // 15:00
printf("%d\n", t->tm_year + 1900);           // 2026
```

---

**O problema do buffer estático**

Como as duas chamadas devolvem o mesmo ponteiro, o segundo resultado sobrescreve o primeiro:

```c
time_t a = 0;
time_t b = time(NULL);

struct tm *ta = localtime(&a);
struct tm *tb = localtime(&b);

// ta e tb apontam para a mesma struct: os dois mostram a data de b
printf("%d %d\n", ta->tm_year + 1900, tb->tm_year + 1900); // 2026 2026
```

Copiar a struct logo depois da chamada resolve, mas ainda não é seguro com threads:

```c
struct tm ta = *localtime(&a); // cópia
struct tm tb = *localtime(&b);
```

---

**localtime_r**

A versão com `_r` (de "reentrante") escreve em uma struct que você fornece, então nunca é sobrescrita por outras chamadas e é segura para usar com várias threads:

```c
time_t agora = time(NULL);
struct tm local;

if (localtime_r(&agora, &local) == NULL) {
  // falhou
}

printf("%02d/%02d/%d\n", local.tm_mday, local.tm_mon + 1, local.tm_year + 1900);
```

> No Windows, o equivalente é o `localtime_s`, com os parâmetros na ordem inversa: `localtime_s(&local, &agora)`

---

**Mesmo instante, fusos diferentes**

```sh
TZ=UTC ./programa                # 18:00
TZ=America/Sao_Paulo ./programa  # 15:00
TZ=Asia/Tokyo ./programa         # 03:00 (do dia seguinte)
```

> Diferente do `gmtime`, que sempre converte para UTC e dá o mesmo resultado em qualquer máquina, o `localtime` depende da configuração de fuso do sistema. Use-o para mostrar datas ao usuário, e o `gmtime` para logs, arquivos e comunicação entre sistemas. Em qualquer código novo, prefira a versão `localtime_r`
