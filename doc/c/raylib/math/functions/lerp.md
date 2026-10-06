**Lerp**

> `raymath.h`

O `Lerp` (linear interpolation) calcula um valor entre `start` e `end`, a uma fração `amount` do caminho. Com `0` devolve o início, com `1` o fim, e com `0.5` o meio

```c
float Lerp(float start, float end, float amount);
```

- `start`: o valor inicial
- `end`: o valor final
- `amount`: a fração do caminho, normalmente de `0.0` a `1.0`

- Devolve `start + amount * (end - start)`
- Com `amount` fora de `0` a `1`, o resultado passa dos extremos (extrapola)

```c
// fade-in de 2 segundos
float alfa = Lerp(0.0f, 1.0f, Clamp(tempo / 2.0f, 0, 1));
DrawTexture(logo, x, y, Fade(WHITE, alfa));

// barra de vida que desce suavemente até o valor real
vida_exibida = Lerp(vida_exibida, vida_real, 8.0f * GetFrameTime());
```

> Usar `Lerp(atual, alvo, k * dt)` todo frame cria uma aproximação suave que desacelera perto do alvo. Ver as duas formas de usar o `Lerp` e as curvas de easing em `../interpolation.md`
