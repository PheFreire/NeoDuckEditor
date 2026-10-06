**Desenhando modelos**

> `raylib.h` — módulo `rmodels`

Um modelo é desenhado em uma posição do mundo 3D, com escala, rotação e uma cor de tint, dentro de um bloco `BeginMode3D`/`EndMode3D`. Cada mesh do modelo é desenhada com o seu material

| Função | Desenha |
|--------|---------|
| `DrawModel(modelo, pos, escala, tint)` | o modelo com escala uniforme |
| `DrawModelEx(modelo, pos, eixo, ângulo, escala3, tint)` | com rotação em torno de um eixo e escala por eixo |
| `DrawModelWires(modelo, pos, escala, tint)` | só as arestas dos triângulos (wireframe) |
| `DrawModelPoints(modelo, pos, escala, tint)` | só os vértices |
| `DrawMesh(mesh, material, matriz)` | uma mesh isolada com uma matriz de transformação |
| `DrawMeshInstanced(mesh, material, matrizes, n)` | a mesma mesh muitas vezes de uma vez |
| `DrawBoundingBox(caixa, cor)` | a caixa de colisão, em arame |

```c
BeginMode3D(camera);
  DrawModel(arvore, (Vector3){ 0, 0, 0 }, 1.0f, WHITE);
  DrawModelEx(nave, nave_pos, (Vector3){ 0, 1, 0 }, nave_angulo, (Vector3){ 1, 1, 1 }, WHITE);
  if (depurar) DrawModelWires(nave, nave_pos, 1.0f, GREEN);
EndMode3D();
```

---

**Tint**

- A cor multiplica a cor do material, como nas texturas 2D. `WHITE` desenha sem alteração
- `Fade(WHITE, 0.5f)` deixa o modelo meio transparente. Objetos transparentes em 3D devem ser desenhados depois dos opacos, do mais distante para o mais próximo, para a mistura ficar correta

---

**Muitas cópias do mesmo modelo**

```c
// floresta: o mesmo modelo de árvore desenhado em várias posições
for (int i = 0; i < 200; i++) {
  DrawModel(arvore, posicoes[i], escalas[i], WHITE);
}
```

- Cada `DrawModel` é um envio separado para a GPU. Para milhares de cópias, o `DrawMeshInstanced` desenha todas em um único envio, mas exige um shader com suporte a instancing

> O `DrawModel` combina a matriz `model.transform` com a posição, a rotação e a escala passadas. Ver como as transformações se combinam em `transformations.md`
