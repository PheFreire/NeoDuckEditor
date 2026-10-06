**struct timespec**

> `time.h`

A `struct timespec` representa um instante ou um intervalo de tempo com precisão de nanossegundos, separando a parte inteira em segundos e a parte fracionária em nanossegundos, sendo usada por `clock_gettime`, `timespec_get` e `nanosleep`

> Um `nanossegundo` é um bilionésimo de segundo (`0.000000001 s`). Para medir o tempo de uma função ou dormir por alguns milissegundos, a precisão de segundos do `time_t` não é suficiente, e a `timespec` resolve isso sem usar ponto flutuante

```c
struct timespec {
  time_t tv_sec;  // segundos inteiros
  long tv_nsec;   // nanossegundos, de 0 a 999999999
};
```

- `tv_sec`: a parte em segundos, do mesmo tipo e com o mesmo significado de um `time_t`
- `tv_nsec`: a fração de segundo, sempre entre `0` e `999999999`. Um valor fora desse intervalo é inválido para a maioria das funções

- Faz parte do padrão desde o C11, e do POSIX desde antes
- O valor `1.5 s` é guardado como `tv_sec = 1` e `tv_nsec = 500000000`
- Tabela de conversão: `1 s = 1000 ms = 1000000 µs = 1000000000 ns`

```c
struct timespec meio_segundo = {0, 500000000};   // 0.5 s
struct timespec cem_ms = {0, 100 * 1000000};     // 100 ms
struct timespec dois_e_meio = {2, 500000000};    // 2.5 s
```

---

**Diferença entre dois timespec**

Subtraindo campo a campo, os nanossegundos podem ficar negativos, e é preciso "pegar emprestado" um segundo:

```c
struct timespec diferenca(struct timespec inicio, struct timespec fim) {
  struct timespec r;
  r.tv_sec = fim.tv_sec - inicio.tv_sec;
  r.tv_nsec = fim.tv_nsec - inicio.tv_nsec;

  if (r.tv_nsec < 0) {
    r.tv_sec -= 1;
    r.tv_nsec += 1000000000;
  }
  return r;
}

// inicio = {10, 900000000}, fim = {12, 100000000}
// sem correção: {2, -800000000}
// com correção: {1, 200000000}, ou seja, 1.2 s
```

---

**Convertendo para um único número**

Para mostrar ou comparar, costuma ser mais prático transformar em segundos (`double`) ou em nanossegundos (inteiro de 64 bits):

```c
double em_segundos(struct timespec t) {
  return t.tv_sec + t.tv_nsec / 1e9;
}

int64_t em_nanossegundos(struct timespec t) {
  return (int64_t)t.tv_sec * 1000000000 + t.tv_nsec;
}

double em_ms(struct timespec t) {
  return t.tv_sec * 1000.0 + t.tv_nsec / 1e6;
}
```

> O cast para `int64_t` antes da multiplicação é obrigatório: `tv_sec * 1000000000` feito em um tipo de 32 bits estouraria com qualquer valor acima de 2 segundos

---

**Somando um intervalo**

```c
struct timespec somar_ms(struct timespec t, long ms) {
  t.tv_sec += ms / 1000;
  t.tv_nsec += (ms % 1000) * 1000000;

  if (t.tv_nsec >= 1000000000) {
    t.tv_sec += 1;
    t.tv_nsec -= 1000000000;
  }
  return t;
}
```

> Diferente da antiga `struct timeval` (`tv_sec` e `tv_usec`, usada por `gettimeofday` e `select`), que tem precisão de microssegundos, a `timespec` usa nanossegundos e é a usada pelas funções modernas. As duas seguem a mesma ideia de separar segundos e fração, e as contas de diferença e normalização são idênticas, só mudando o `1000000000` para `1000000`
