**Erros comuns**

> problemas frequentes ao programar com raylib

Uma lista de erros comuns, com o sintoma, a causa e a correção. A maioria vem de três fontes: a ordem das chamadas (antes ou depois da janela, dentro ou fora do bloco de desenho), o gerenciamento de memória (`Load`/`Unload`) e a mistura de sistemas de coordenadas e unidades

---

**Janela e game loop**

| Sintoma | Causa | Correção |
|---------|-------|----------|
| textura não aparece, log com aviso de OpenGL | `LoadTexture` antes do `InitWindow` | carregar depois do `InitWindow` |
| janela congela e não responde | caminho do loop sem `EndDrawing`, ou laço longo dentro do frame | todo frame passa por `BeginDrawing`/`EndDrawing` |
| `Esc` fecha o jogo em vez de abrir o menu | `Esc` é a tecla de saída padrão | `SetExitKey(KEY_NULL)` |
| rastros na tela | sem `ClearBackground` | limpar no início do desenho |
| jogo mais rápido em uma máquina | movimento sem delta time | multiplicar por `GetFrameTime()` |
| CPU a 100% | sem `SetTargetFPS` nem V-Sync | `SetTargetFPS(60)` |

---

**Recursos e memória**

| Sintoma | Causa | Correção |
|---------|-------|----------|
| memória crescendo sem parar | `Load...` dentro do game loop | carregar antes do loop |
| memória cresce a cada troca de fase | falta o `Unload` dos recursos antigos | liberar antes de carregar os novos |
| crash ao sair | `Unload...` depois do `CloseWindow`, ou liberar duas vezes | liberar na ordem inversa, antes de fechar |
| arquivo não encontrado ao abrir pelo atalho/editor | caminho relativo ao diretório de trabalho | `ChangeDirectory(GetApplicationDirectory())` |
| texto do `TextFormat` mudou sozinho | buffer estático reaproveitado após 4 chamadas | usar na hora ou copiar |

---

**Desenho e coordenadas**

| Sintoma | Causa | Correção |
|---------|-------|----------|
| sprite gira em torno do canto | `DrawTextureEx` gira em torno da posição | `DrawTexturePro` com `origin` no centro |
| render texture de cabeça para baixo | origem das texturas no OpenGL | altura negativa no `source` |
| clique cai no lugar errado com câmera | mouse em coordenadas da tela | `GetScreenToWorld2D` |
| interface se move com o mapa | HUD desenhado dentro do `BeginMode2D` | desenhar depois do `EndMode2D` |
| objeto aponta para direção aleatória | graus passados para função que usa radianos (raymath) | `angulo * DEG2RAD` |
| triângulo não aparece | vértices em sentido horário | ordem anti-horária |
| pixel art borrada | filtro bilinear ou `ImageResize` | filtro point, `ImageResizeNN` |
| acentos aparecem como `?` | fonte carregada só com ASCII | incluir os codepoints no `LoadFontEx` |

---

**Áudio**

| Sintoma | Causa | Correção |
|---------|-------|----------|
| nenhum som | falta o `InitAudioDevice` | chamar antes de carregar os sons |
| música para depois de um instante | falta o `UpdateMusicStream` | chamar todo frame |
| som corta o anterior | `PlaySound` reinicia o mesmo som | `LoadSoundAlias` para vozes extras |

> Quase todos esses erros deixam uma mensagem no log do raylib. Antes de depurar o código, leia as linhas de `WARNING` que aparecem no terminal (ver `../core/logging.md`)
