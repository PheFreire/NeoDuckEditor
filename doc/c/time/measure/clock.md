**clock**

> `time.h`

O `clock` devolve quanto tempo de processador (CPU) o programa já gastou desde que começou, servindo para medir o custo de processamento de um trecho de código, sem contar o tempo em que o programa ficou parado esperando

> Tempo de CPU não é o mesmo que tempo real. Um programa que fica 5 segundos esperando o usuário digitar gasta 5 segundos de tempo real, mas quase nada de CPU. E um programa com 4 threads trabalhando ao mesmo tempo por 1 segundo gasta cerca de 4 segundos de CPU

```c
clock_t clock(void);
```

- Devolve o tempo de CPU usado pelo programa até agora, medido em "ticks" do tipo `clock_t`, ou `(clock_t)-1` se a informação não estiver disponível
- Para converter em segundos, divide-se pela constante `CLOCKS_PER_SEC`, que vale `1000000` no Linux e no macOS
- O valor absoluto não tem significado útil. O que importa é a diferença entre duas chamadas
- Em sistemas onde o `clock_t` tem 32 bits, o contador pode dar a volta depois de cerca de 72 minutos de CPU

```c
clock_t inicio = clock();

for (long i = 0; i < 100000000; i++) {
  // trabalho pesado
}

clock_t fim = clock();
double segundos = (double)(fim - inicio) / CLOCKS_PER_SEC;

printf("CPU: %.3f s\n", segundos); // CPU: 0.250 s
```

> O cast para `double` é obrigatório: `(fim - inicio) / CLOCKS_PER_SEC` com dois inteiros faz divisão inteira e dá `0` para qualquer trecho que leve menos de um segundo

---

**O que o clock não mede**

Tempo parado (`sleep`, leitura de arquivo, rede, `scanf`) não conta:

```c
clock_t inicio = clock();
sleep(2);
clock_t fim = clock();

printf("%.3f s\n", (double)(fim - inicio) / CLOCKS_PER_SEC);
// 0.000 s, e não 2 s
```

---

**Comparando dois algoritmos**

O tempo de CPU é útil para comparar implementações, pois é menos afetado por outros programas rodando na máquina:

```c
clock_t t0 = clock();
ordenar_bubble(dados_a, N);
clock_t t1 = clock();
ordenar_quick(dados_b, N);
clock_t t2 = clock();

printf("bubble: %.3f s\n", (double)(t1 - t0) / CLOCKS_PER_SEC);
printf("quick:  %.3f s\n", (double)(t2 - t1) / CLOCKS_PER_SEC);
```

> Diferente do `clock_gettime(CLOCK_MONOTONIC)`, que mede o tempo real que passou, o `clock` mede só o trabalho feito pelo processador. Para saber "quanto o usuário esperou" use o primeiro, e para saber "quanto processamento isso custou" use o `clock`. No Windows, o `clock` do MSVC mede tempo real e não de CPU, o que torna os resultados diferentes entre plataformas
