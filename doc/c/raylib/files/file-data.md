**Dados de arquivo**

> `raylib.h` — módulo `rcore`

As funções de dados leem e escrevem arquivos inteiros como sequências de bytes, sem interpretar o conteúdo. Servem para saves binários, formatos próprios, pacotes de recursos e qualquer dado que não seja texto

```c
unsigned char *LoadFileData(const char *fileName, int *dataSize);
void UnloadFileData(unsigned char *data);
bool SaveFileData(const char *fileName, void *data, int dataSize);
```

---

**Salvando uma struct**

```c
typedef struct {
  int versao;
  int fase;
  float tempo_total;
  int moedas;
} Progresso;

Progresso p = { 1, fase_atual, tempo, moedas };
if (!SaveFileData("progresso.sav", &p, sizeof(p))) {
  TraceLog(LOG_WARNING, "não foi possível salvar");
}
```

---

**Carregando**

```c
Progresso p = { 1, 1, 0, 0 };   // valores padrão para um jogo novo
int tamanho = 0;
unsigned char *dados = LoadFileData("progresso.sav", &tamanho);

if (dados != NULL) {
  if (tamanho == (int)sizeof(Progresso)) {
    memcpy(&p, dados, sizeof(Progresso));   // copia os bytes de volta para a struct
  }
  UnloadFileData(dados);
}
```

---

**Armadilhas da struct binária**

- O arquivo guarda a struct exatamente como ela está na memória, incluindo bytes de padding. Mudar a struct (adicionar um campo) torna os saves antigos incompatíveis. Um campo `versao` no início permite detectar e converter
- Ponteiros não podem ser salvos assim: o arquivo guardaria o endereço, e não o conteúdo apontado. Strings precisam ser arrays dentro da struct (`char nome[32]`)
- O formato depende da máquina (tamanho de `int`, ordem dos bytes). Saves compartilhados entre plataformas diferentes precisam de um formato definido byte a byte ou de texto

> O `LoadFileData` devolve `NULL` e `dataSize = 0` quando o arquivo não existe, com um aviso no log. Para checar antes sem gerar o aviso, use `FileExists` (ver `functions/file-exists.md`)
