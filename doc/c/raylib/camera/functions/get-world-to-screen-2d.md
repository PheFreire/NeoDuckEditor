**GetWorldToScreen2D**

> `raylib.h` — módulo `rcore`

O `GetWorldToScreen2D` converte uma posição do mundo para a posição correspondente na tela, aplicando o deslocamento, a rotação e o zoom de uma `Camera2D`. É usado para desenhar interface sobre objetos do mundo e para saber se um objeto está visível

```c
Vector2 GetWorldToScreen2D(Vector2 position, Camera2D camera);
```

- `position`: a posição no mundo
- `camera`: a câmera usada para desenhar o mundo

- Devolve a posição na tela, em pixels

```c
// nome acima do personagem, com tamanho fixo mesmo com zoom
EndMode2D();
Vector2 tela = GetWorldToScreen2D(npc.pos, camera);
int largura = MeasureText(npc.nome, 16);
DrawText(npc.nome, (int)tela.x - largura / 2, (int)tela.y - 40, 16, BLACK);
```

---

**Indicador de objeto fora da tela**

```c
Vector2 t = GetWorldToScreen2D(objetivo, camera);
bool visivel = t.x >= 0 && t.x <= GetScreenWidth() && t.y >= 0 && t.y <= GetScreenHeight();

if (!visivel) {
  // limita à borda da tela e desenha uma seta apontando para o objetivo
  t.x = Clamp(t.x, 20, GetScreenWidth() - 20);
  t.y = Clamp(t.y, 20, GetScreenHeight() - 20);
  DrawCircleV(t, 10, GOLD);
}
```

> O resultado é em coordenadas da tela, então o desenho que o usa deve ficar fora do `BeginMode2D`. Desenhar dentro aplicaria a câmera duas vezes
