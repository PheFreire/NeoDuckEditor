**Conversão de coordenadas**

> `raylib.h` — módulo `rcore`

Com uma câmera, existem dois sistemas de coordenadas: o mundo e a tela. O raylib tem funções para converter de um para o outro, aplicando (ou desfazendo) o deslocamento, o zoom e a rotação da câmera. A conversão é necessária sempre que o mouse interage com o mundo, ou quando a interface precisa acompanhar um objeto do mundo

| Função | Converte |
|--------|----------|
| `GetScreenToWorld2D(pos, cam2d)` | tela → mundo (2D) |
| `GetWorldToScreen2D(pos, cam2d)` | mundo → tela (2D) |
| `GetWorldToScreen(pos3d, cam3d)` | mundo 3D → tela |
| `GetWorldToScreenEx(pos3d, cam3d, largura, altura)` | mundo 3D → área de tamanho escolhido |
| `GetScreenToWorldRay(pos, cam3d)` | tela → raio no mundo 3D |

---

**Tela para mundo: o mouse no mapa**

```c
Vector2 mouse_tela  = GetMousePosition();
Vector2 mouse_mundo = GetScreenToWorld2D(mouse_tela, camera);

// colocar um bloco na célula do mapa sob o mouse
int col = (int)floorf(mouse_mundo.x / TAMANHO_TILE);
int lin = (int)floorf(mouse_mundo.y / TAMANHO_TILE);
if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) mapa[lin][col] = BLOCO;
```

```text
tela                                  mundo
mouse (400, 225)  ──GetScreenToWorld2D──►  (1200, 900)
                    desfaz offset, rotação e zoom da câmera
```

- Sem a conversão, o clique cairia na posição errada assim que a câmera se movesse ou desse zoom
- O `floorf` (em vez de um cast para `int`) mantém as células corretas para coordenadas negativas (ver `../../math/rounding/floor.md`)

---

**Mundo para tela: interface sobre objetos**

```c
Vector2 tela = GetWorldToScreen2D(inimigo.pos, camera);
DrawRectangle(tela.x - 20, tela.y - 30, 40 * inimigo.vida / 100, 5, RED);   // barra de vida
```

---

**3D: do mouse para a cena**

Na tela, o mouse é um ponto. Na cena 3D, ele corresponde a uma **linha** inteira de pontos possíveis, todos que aparecem atrás daquele pixel. Por isso a conversão 3D devolve um raio:

```c
Ray raio = GetScreenToWorldRay(GetMousePosition(), camera3d);
RayCollision hit = GetRayCollisionBox(raio, caixa);
if (hit.hit) {
  DrawSphere(hit.point, 0.1f, RED);   // marca onde o mouse "tocou" a caixa
}
```

- O raio é testado contra os objetos para descobrir em qual deles o mouse está (ver `../collision/collision-3d.md`)

> As conversões usam a câmera **atual** passada como parâmetro, e funcionam fora do `BeginMode2D`/`BeginMode3D`. Use a mesma câmera que foi usada para desenhar o frame, ou a conversão fica um frame atrasada em relação ao que o usuário vê
