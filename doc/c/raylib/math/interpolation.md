**Interpolação**

> `raymath.h`

Interpolar é calcular um valor intermediário entre dois valores. É a base de movimentos suaves, transições de cor, câmeras que acompanham o jogador e barras que enchem aos poucos. O raymath tem funções para interpolar, limitar e mudar a escala de números

| Função | Resultado |
|--------|-----------|
| `Lerp(a, b, t)` | `a + (b - a) * t`: o valor a uma fração `t` do caminho de `a` até `b` |
| `Clamp(v, min, max)` | `v` limitado ao intervalo |
| `Normalize(v, a, b)` | a fração de `v` entre `a` e `b` (de `0` a `1`) |
| `Remap(v, a1, b1, a2, b2)` | converte `v` de um intervalo para outro |
| `Wrap(v, min, max)` | `v` dando a volta no intervalo, como um ângulo |
| `Vector2Lerp`, `Vector3Lerp`, `ColorLerp`, `QuaternionSlerp` | o mesmo para vetores, cores e rotações |

---

**Lerp**

```text
Lerp(10, 20, 0.0)  = 10     início
Lerp(10, 20, 0.5)  = 15     metade
Lerp(10, 20, 1.0)  = 20     fim
```

Transição com duração fixa:

```c
float t = Clamp(tempo_passado / duracao, 0.0f, 1.0f);
Vector2 pos = Vector2Lerp(inicio, fim, t);   // chega exatamente no fim em 'duracao' segundos
```

Seguir um alvo suavemente (amortecimento):

```c
camera.target = Vector2Lerp(camera.target, jogador, 5.0f * GetFrameTime());
```

- Esta forma nunca chega exatamente ao alvo: anda uma fração da distância restante a cada frame, desacelerando ao se aproximar. É o efeito de "câmera suave"

---

**Easing: acelerar e desacelerar**

```c
float t = Clamp(tempo / duracao, 0, 1);
float suave = t * t * (3 - 2 * t);   // smoothstep: começa e termina devagar
Vector2 pos = Vector2Lerp(inicio, fim, suave);
```

- O `t` linear dá um movimento de velocidade constante, que parece mecânico. Passar o `t` por uma curva antes do `Lerp` cria acelerações naturais

---

**Normalize e Remap**

```c
// barra de vida: converte vida (0 a 250) em largura (0 a 200 pixels)
float largura = Remap(vida, 0, 250, 0, 200);

// volume conforme a distância: 1 perto, 0 a 500 unidades
float vol = 1.0f - Clamp(Normalize(distancia, 0, 500), 0, 1);
```

> `Lerp` com `t` fora de `0` a `1` extrapola: `Lerp(10, 20, 2)` dá `30`. Use `Clamp` no `t` quando o resultado não pode passar dos extremos
