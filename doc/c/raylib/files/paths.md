**Caminhos**

> `raylib.h` — módulo `rcore`

As funções de caminho extraem partes de um caminho de arquivo (nome, extensão, pasta), verificam se arquivos e pastas existem e controlam o diretório de trabalho. Elas resolvem o problema mais comum ao distribuir um jogo: os arquivos não são encontrados quando o programa é aberto de outro diretório

| Função | Devolve |
|--------|---------|
| `GetFileName("assets/img/heroi.png")` | `"heroi.png"` |
| `GetFileNameWithoutExt("assets/heroi.png")` | `"heroi"` |
| `GetFileExtension("arq.tar.gz")` | `".gz"` (com o ponto), ou `NULL` sem extensão |
| `GetDirectoryPath("assets/img/heroi.png")` | `"./assets/img"` |
| `GetPrevDirectoryPath("/jogo/assets")` | `"/jogo"` |
| `GetWorkingDirectory()` | o diretório de trabalho atual |
| `GetApplicationDirectory()` | a pasta onde está o executável |
| `FileExists(caminho)` / `DirectoryExists(caminho)` | se existe |
| `IsFileExtension(arquivo, ".png;.jpg")` | se a extensão é uma das listadas |
| `ChangeDirectory(caminho)` | muda o diretório de trabalho |

---

**Diretório de trabalho vs pasta do executável**

```text
/home/user/jogos/meujogo/
├── jogo                (executável)
└── assets/heroi.png

$ cd /home/user/jogos/meujogo && ./jogo     → "assets/heroi.png" é encontrado
$ cd /home/user && ./jogos/meujogo/jogo     → procura /home/user/assets/heroi.png: falha
```

- Caminhos relativos (`"assets/heroi.png"`) são resolvidos a partir do **diretório de trabalho**, que é de onde o programa foi chamado, e não onde ele está
- Clicar duas vezes no executável, rodar pelo editor ou por um atalho pode mudar o diretório de trabalho

```c
// no início do programa: passa a procurar os arquivos a partir da pasta do executável
ChangeDirectory(GetApplicationDirectory());
Texture2D heroi = LoadTexture("assets/heroi.png");
```

---

**Buffers estáticos**

```c
const char *a = GetDirectoryPath("mapas/fase1.txt");
const char *b = GetDirectoryPath("sons/pulo.wav");
// a e b apontam para o MESMO buffer: agora os dois são "./sons"
```

- `GetDirectoryPath`, `GetPrevDirectoryPath`, `GetWorkingDirectory` e `GetFileNameWithoutExt` devolvem um buffer interno que é sobrescrito na próxima chamada. Use o valor na hora ou copie
- `GetFileName` e `GetFileExtension` devolvem um ponteiro para **dentro** da string passada: continuam válidos enquanto a string original existir

> O `GetDirectoryPath` adiciona `"./"` antes de caminhos relativos (`"assets/img"` vira `"./assets/img"`), e um caminho que já começa com `"./"` fica com `"././"`. Os dois funcionam ao abrir arquivos, mas atrapalham comparações de strings
