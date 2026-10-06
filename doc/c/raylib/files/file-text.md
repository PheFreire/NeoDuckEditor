**Texto de arquivo**

> `raylib.h` — módulo `rcore`

As funções de texto leem um arquivo inteiro para uma string terminada em `\0`, ou escrevem uma string em um arquivo. São usadas para configurações, diálogos, mapas em texto e qualquer formato legível por pessoas

```c
char *LoadFileText(const char *fileName);
void UnloadFileText(char *text);
bool SaveFileText(const char *fileName, char *text);
```

```c
// config.txt:
// largura=1280
// altura=720
// volume=80

int largura = 800, altura = 450, volume = 100;

char *texto = LoadFileText("config.txt");
if (texto != NULL) {
  char *linha = strtok(texto, "\n");
  while (linha != NULL) {
    sscanf(linha, "largura=%d", &largura);
    sscanf(linha, "altura=%d", &altura);
    sscanf(linha, "volume=%d", &volume);
    linha = strtok(NULL, "\n");
  }
  UnloadFileText(texto);
}

InitWindow(largura, altura, "jogo");
```

- O `strtok` modifica a string, o que é permitido porque o texto devolvido pelo `LoadFileText` pertence ao programa até o `UnloadFileText` (ver `../../string/split/strtok.md`)

---

**Salvando**

```c
char buffer[256];
snprintf(buffer, sizeof(buffer), "largura=%d\naltura=%d\nvolume=%d\n", largura, altura, volume);
SaveFileText("config.txt", buffer);
```

---

**Texto vs dados**

| | `LoadFileText` | `LoadFileData` |
|---|---|---|
| Devolve | `char *` terminado em `\0` | `unsigned char *` + tamanho |
| Bytes `\0` no meio | cortariam a string | preservados |
| Uso | arquivos de texto | qualquer arquivo |

> Arquivos de texto do Windows terminam as linhas com `\r\n`. Ao separar linhas por `\n`, o `\r` fica no final de cada linha e pode quebrar comparações. Use `"\r\n"` como delimitador no `strtok` para tratar os dois casos
