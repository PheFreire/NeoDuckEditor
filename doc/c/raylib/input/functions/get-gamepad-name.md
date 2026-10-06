**GetGamepadName**

> `raylib.h` — módulo `rcore`

O `GetGamepadName` devolve o nome interno de um gamepad conectado, como informado pelo driver ou pelo banco de mapeamentos (`"Xbox Controller"`, `"PS4 Controller"`)

```c
const char *GetGamepadName(int gamepad);
```

- `gamepad`: índice do controle, de `0` a `3`

- Devolve o nome do controle, terminado em `\0`
- Para um índice sem controle, o retorno pode ser `NULL` ou vazio. Verifique antes com `IsGamepadAvailable`
- A string pertence ao raylib/GLFW: não modifique nem chame `free`

```c
if (IsGamepadAvailable(0)) {
  const char *nome = GetGamepadName(0);
  bool playstation = strstr(nome, "PS") != NULL || strstr(nome, "DualSense") != NULL;
  // mostra os ícones de botão certos na interface: ✕ ○ □ △ ou A B X Y
  icones = playstation ? ICONES_PS : ICONES_XBOX;
}
```

> O nome é útil para mostrar ícones corretos e para diagnóstico, mas não é padronizado: o mesmo controle pode ter nomes diferentes em Linux, macOS e Windows. Não use o nome para decidir o mapeamento dos botões, que o raylib já normaliza (ver `../gamepad.md`)
