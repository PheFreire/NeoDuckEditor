**FileExists**

> `raylib.h` — módulo `rcore`

O `FileExists` verifica se um arquivo existe no caminho indicado

```c
bool FileExists(const char *fileName);
```

- `fileName`: o caminho do arquivo

- Devolve `true` se o arquivo existe, e `false` caso contrário
- Não gera aviso no log, ao contrário de tentar carregar um arquivo inexistente
- Também devolve `true` para pastas (`FileExists("assets")` é verdadeiro se a pasta existir). Para garantir que é um arquivo, combine com `!DirectoryExists(caminho)` ou use `IsPathFile`

```c
// menu principal: "Continuar" só aparece se houver um save
bool tem_save = FileExists("saves/slot1.sav");
if (tem_save) {
  DrawText("Continuar", 300, 200, 30, BLACK);
}
DrawText("Novo jogo", 300, 250, 30, BLACK);
```

> Entre verificar e abrir, o arquivo pode ser apagado por outro programa. Para o carregamento em si, o mais seguro é tentar carregar e tratar o resultado `NULL` (ver `../../../os/access.md`, que explica esse problema)
