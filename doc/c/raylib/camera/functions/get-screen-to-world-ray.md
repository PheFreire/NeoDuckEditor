**GetScreenToWorldRay**

> `raylib.h` — módulo `rcore`

O `GetScreenToWorldRay` cria um raio 3D que parte da câmera e passa pelo ponto da tela indicado. Como um ponto da tela corresponde a uma linha inteira de pontos na cena 3D, o resultado é um raio, que depois é testado contra os objetos para descobrir qual está sob o mouse

```c
Ray GetScreenToWorldRay(Vector2 position, Camera camera);
```

- `position`: o ponto na tela (normalmente `GetMousePosition()`)
- `camera`: a câmera 3D usada para desenhar a cena

- Devolve um `Ray` com `position` (origem, na câmera) e `direction` (normalizada, apontando para dentro da cena)
- Em versões anteriores do raylib, esta função se chamava `GetMouseRay`

```c
Ray raio = GetScreenToWorldRay(GetMousePosition(), camera);

RayCollision chao = GetRayCollisionQuad(raio,
  (Vector3){ -50, 0, -50 }, (Vector3){ -50, 0, 50 },
  (Vector3){  50, 0, 50 },  (Vector3){  50, 0, -50 });

if (chao.hit && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
  destino = chao.point;   // clicar no chão para mover o personagem
}
```

---

**Raio**

```text
câmera ●
        ╲
         ╲  passa pelo pixel do mouse
  tela ───●───
           ╲
            ╲
             ● objeto atingido (GetRayCollision...)
```

- O raio sozinho não acerta nada: ele precisa ser testado com `GetRayCollisionBox`, `GetRayCollisionSphere`, `GetRayCollisionMesh` ou `GetRayCollisionQuad` (ver `../../collision/collision-3d.md`)

> Para depurar, o `DrawRay(raio, cor)` desenha o raio dentro do `BeginMode3D`. Visto da própria câmera, ele aparece como um ponto sob o mouse, então mova a câmera para vê-lo
