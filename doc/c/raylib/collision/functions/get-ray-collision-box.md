**GetRayCollisionBox**

> `raylib.h` — módulo `rmodels`

O `GetRayCollisionBox` testa se um raio (uma semirreta com origem e direção) atinge uma caixa 3D e devolve onde e a que distância. É a função usada para clicar em objetos 3D com o mouse e para testes de linha de visão em 3D

```c
RayCollision GetRayCollisionBox(Ray ray, BoundingBox box);
```

- `ray`: o raio, com `position` (origem) e `direction` (direção, normalizada)
- `box`: a caixa

- Devolve uma `RayCollision`:
    - `hit`: `true` se o raio atingiu a caixa
    - `distance`: a distância da origem do raio até o ponto atingido
    - `point`: o ponto atingido, na superfície da caixa
    - `normal`: a direção perpendicular à face atingida
- Se a origem do raio estiver dentro da caixa, o ponto devolvido é onde o raio **sai** dela

```c
Ray raio = GetScreenToWorldRay(GetMousePosition(), camera);

int mais_perto = -1;
float menor = 1e9f;

for (int i = 0; i < n_caixas; i++) {
  RayCollision c = GetRayCollisionBox(raio, caixas[i]);
  if (c.hit && c.distance < menor) {
    menor = c.distance;
    mais_perto = i;   // guarda o objeto mais próximo da câmera
  }
}

if (mais_perto >= 0 && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
  selecionar(mais_perto);
}
```

---

**O raio do mouse**

```text
câmera ●─────────────────────────────►  direção do raio
        ╲  tela  (onde o mouse está)
         ╲
          ╲──────► caixa atingida (distance)
```

- `GetScreenToWorldRay` cria um raio que parte da câmera e passa pelo ponto da tela onde está o mouse (ver `../../camera/functions/get-screen-to-world-ray.md`)
- Vários objetos podem ser atingidos: o clicado é o de menor `distance`

> Use a `normal` para posicionar algo sobre a superfície atingida, como um bloco novo em um jogo de construção: `Vector3Add(c.point, Vector3Scale(c.normal, 0.5f))` coloca o centro do bloco meio passo para fora da face clicada
