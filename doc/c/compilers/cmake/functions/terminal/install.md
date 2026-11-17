**cmake --install**

> ferramenta de linha de comando, vem com o CMake

O `cmake --install <build>` copia os executáveis, bibliotecas e arquivos declarados com `install` no `CMakeLists.txt` para o prefixo de instalação

```bash
cmake --install <diretório de build> [--prefix <diretório>] [--config <tipo>] [--strip]
```

- `diretório de build`: o diretório já compilado
- `--prefix`: o diretório de instalação. O padrão é `/usr/local`
- `--config`: o build type, nos generators com vários build types
- `--strip`: remove os símbolos de debug dos binários instalados

- Não compila nada. Rode o `cmake --build` antes
- Instalar em `/usr/local` precisa de `sudo`. Um prefixo na sua home, como `~/.local`, não precisa
- Só instala o que o `CMakeLists.txt` declarou com `install` (ver `functions/instalacao/install.md`)

```bash
cmake --build build
cmake --install build --prefix ~/.local
```
