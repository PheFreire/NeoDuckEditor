**tcflush, tcdrain e tcflow**

> `termios.h`

Um terminal tem duas filas no kernel: a de **entrada** (bytes recebidos que o programa ainda não leu) e a de **saída** (bytes que o programa escreveu, mas ainda não foram transmitidos). `tcflush` descarta o conteúdo dessas filas, `tcdrain` espera a fila de saída esvaziar e `tcflow` pausa ou retoma a transmissão

```text
                       kernel (tty)
dispositivo ──► [ fila de entrada ] ──► read()
dispositivo ◄── [ fila de saída   ] ◄── write()
```

```c
int tcflush(int fd, int queue_selector);
int tcdrain(int fd);
int tcflow(int fd, int action);
int tcsendbreak(int fd, int duration);
```

- Todas devolvem `0` em caso de sucesso, ou `-1` com `errno` (`ENOTTY` se `fd` não for um terminal)

---

**tcflush**

- `queue_selector`:
	- `TCIFLUSH`: descarta a entrada recebida e não lida
	- `TCOFLUSH`: descarta a saída escrita e não transmitida
	- `TCIOFLUSH`: as duas

```c
tcflush(STDIN_FILENO, TCIFLUSH);  // ignora tudo que o usuário digitou até agora
printf("Confirma? (s/n) ");
```

- Útil antes de uma pergunta importante, para que teclas apertadas por acidente antes do prompt não sejam lidas como resposta
- Em serial, `TCIOFLUSH` logo depois de abrir e configurar a porta descarta bytes antigos ou lixo recebido durante a configuração
- Descarta só a fila do **kernel**. Dados já lidos para o buffer do `stdio` (`FILE *`) não são afetados. Misturar `tcflush` com `scanf`/`fgets` pode deixar sobras no buffer do `stdin`

---

**tcdrain**

- Bloqueia até que **todos** os bytes da fila de saída tenham sido transmitidos
- `write()` em um terminal retorna assim que os bytes entram na fila do kernel, e não quando são enviados. Em uma porta serial a 9600 baud, 1000 bytes levam cerca de 1 segundo para sair depois do `write()` retornar

```c
write(fd, comando, tamanho);
tcdrain(fd);           // garante que o comando terminou de sair pela porta
close(fd);             // sem o tcdrain, fechar cedo pode cortar o fim da transmissão
```

- Em um PTY, "transmitido" significa entregue ao lado master. O `tcdrain` retorna rápido, a não ser que o emulator não esteja lendo
- O `TCSADRAIN` de `tcsetattr` é equivalente a `tcdrain` seguido da mudança de configuração (ver `tcgetattr-tcsetattr.md`)
- Não confunda com o `fflush` do `stdio`: o `fflush(stdout)` move os bytes do buffer do processo para o kernel com `write()`. O `tcdrain` espera eles saírem do kernel para o dispositivo. Para garantir que um `printf` chegou ao dispositivo serial, são necessários os dois

---

**tcflow**

- `action`:
	- `TCOOFF`: pausa a saída (como se o outro lado tivesse enviado `Ctrl+S`)
	- `TCOON`: retoma a saída pausada
	- `TCIOFF`: envia o caractere `VSTOP` ao dispositivo, pedindo que ele pare de transmitir
	- `TCION`: envia `VSTART`, pedindo que ele volte a transmitir
- Controle de fluxo manual. Com `IXON`/`IXOFF` (ver `input-flags.md`) o kernel faz isso automaticamente

---

**tcsendbreak**

- Mantém a linha serial em nível zero por um tempo (com `duration = 0`, entre 0,25 e 0,5 segundo), gerando uma condição de break no outro lado
- Usado por alguns protocolos e dispositivos para sinalizar reset ou entrar em modo de comando. Em um PTY não tem efeito físico

> Nenhuma dessas funções altera a configuração `termios`: elas agem sobre as filas e a transmissão. Mas uma restauração de terminal bem feita usa a mesma ideia: `TCSAFLUSH` na saída do raw mode faz um `tcdrain` e um `tcflush(TCIFLUSH)` antes de aplicar a configuração original
