**ChangeDirectory**

> `raylib.h` — módulo `rcore`

O `ChangeDirectory` muda o diretório de trabalho do processo, que é a pasta a partir da qual os caminhos relativos são resolvidos

```c
bool ChangeDirectory(const char *dir);
```

- `dir`: a nova pasta de trabalho

- Devolve `true` se a mudança funcionou, e `false` se a pasta não existe ou não pode ser acessada
- Afeta **todos** os caminhos relativos do programa a partir dali, inclusive os usados por `LoadTexture`, `LoadSound` e `fopen`

```c
int main(void) {
  ChangeDirectory(GetApplicationDirectory());   // primeira linha: assets relativos à pasta do executável

  InitWindow(800, 450, "jogo");
  Texture2D heroi = LoadTexture("assets/heroi.png");   // funciona de qualquer lugar onde o jogo seja aberto
  /* ... */
}
```

---

**Por que é necessário**

```text
o usuário abre o jogo por um atalho, pelo terminal em outra pasta, ou pelo editor
  → o diretório de trabalho não é a pasta do jogo
  → "assets/heroi.png" é procurado no lugar errado
```

> Em macOS, aplicativos empacotados (`.app`) começam com o diretório de trabalho na raiz do sistema (`/`). Sem o `ChangeDirectory`, nenhum asset relativo é encontrado. O `GetApplicationDirectory` devolve a pasta do executável dentro do pacote (ver `../paths.md`)
