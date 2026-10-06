**Control flags**

> campo `c_cflag` de `struct termios`

O `c_cflag` descreve o **formato físico** dos caracteres na linha de comunicação: quantos bits de dados, se há bit de paridade, quantos stop bits, se o receptor está ligado e se as linhas de controle do modem são respeitadas. Em uma porta serial (Arduino, GPS, modem, console de um roteador), configurar o `c_cflag` igual ao do outro lado é obrigatório. Em um PTY (terminal emulator, `ssh`), essas opções não têm efeito físico e quase nunca precisam ser alteradas

**Um caractere na linha serial**

```text
repouso  start  d0 d1 d2 d3 d4 d5 d6 d7  [paridade]  stop [stop2]  repouso
──1──────┐  0  ┌──┬──┬──┬──┬──┬──┬──┬──┬───────────┐ 1   [1]   ┌───1────
         └─────┴──┴──┴──┴──┴──┴──┴──┴──┴───────────┘           
          CSIZE: 5 a 8 bits de dados  PARENB/PARODD    CSTOPB
```

- A configuração mais comum é **8N1**: 8 bits de dados, sem paridade (None), 1 stop bit

**Tamanho do caractere: CSIZE**

- `CSIZE`: máscara de **dois bits** que guarda um valor, e não uma flag independente
- `CS5`, `CS6`, `CS7`, `CS8`: os valores possíveis para esse campo (5 a 8 bits de dados por caractere)

```c
t.c_cflag &= ~CSIZE;   // zera o campo
t.c_cflag |= CS8;      // escreve "8 bits"
```

- Sem o `&= ~CSIZE`, um `|= CS7` sobre um campo com `CS8` deixaria `CS8` (pois `CS8` já tem todos os bits de `CS7` ligados). Ver `terminal-attributes.md`
- `CS8` é necessário para UTF-8 e dados binários. `CS7` era usado em linhas antigas, junto com paridade

**Paridade: PARENB e PARODD**

A paridade é um bit extra calculado pelo transmissor para que o receptor detecte erros de 1 bit:

- `PARENB`: liga a geração do bit de paridade na saída e a espera dele na entrada
- `PARODD`: com `PARENB`, usa paridade **ímpar** (total de bits 1 ímpar). Sem ela, paridade **par**
- A verificação na entrada é ligada por `INPCK`, e o tratamento dos erros por `IGNPAR`/`PARMRK`, ambos em `c_iflag` (ver `input-flags.md`)
- Em raw mode, `PARENB` é desligada: em um PTY ela não tem sentido, e em serial a maioria dos dispositivos usa 8N1

**Stop bits: CSTOPB**

- Ligada: 2 stop bits por caractere. Desligada: 1 stop bit
- Dá mais tempo para o receptor entre caracteres. Usado por alguns dispositivos lentos ou antigos

**Receptor e modem**

- `CREAD`: liga o receptor. Desligada, nenhum byte é recebido. Fica ligada por padrão. Ao configurar uma porta serial do zero, garanta `t.c_cflag |= CREAD`
- `CLOCAL`: ignora as linhas de controle do modem (principalmente `DCD`, "carrier detect")
	- Desligada: o `open()` da porta pode bloquear esperando o carrier, e a perda do carrier gera `SIGHUP`
	- Ligada: a porta funciona com cabos de 3 fios (TX, RX, GND) e dispositivos sem modem, como adaptadores USB-serial. Quase sempre deve ser ligada para dispositivos que não são modems
- `HUPCL`: ao fechar o último fd da porta, baixa as linhas de modem ("desliga a chamada"). Em placas como Arduino, isso **reinicia a placa** a cada vez que o programa fecha a porta. Desligue se não quiser esse efeito

**Controle de fluxo por hardware**

- `CRTSCTS` (não POSIX, presente no Linux e no macOS): usa os sinais `RTS`/`CTS` do cabo para pausar a transmissão quando o receptor está cheio. Alternativa ao `IXON`/`IXOFF` por software, que não "rouba" bytes do fluxo de dados
- Ligue apenas se o dispositivo e o cabo realmente tiverem essas linhas. Caso contrário, a saída nunca é transmitida

**Velocidade**

- No Linux, a velocidade também é guardada em bits do `c_cflag` (`CBAUD`). No macOS, fica nos campos `c_ispeed`/`c_ospeed`. Em ambos, **nunca** altere esses bits diretamente: use `cfsetispeed`/`cfsetospeed` (ver `baud-rate.md`)

```c
// configuração típica 8N1 para uma porta serial
t.c_cflag &= ~(CSIZE | PARENB | CSTOPB | CRTSCTS);
t.c_cflag |= CS8 | CREAD | CLOCAL;
```

> O kernel pode não suportar todas as combinações (por exemplo, `CS5` com um adaptador USB-serial). O `tcsetattr` só falha se **nenhuma** mudança puder ser aplicada. Para saber se o `c_cflag` foi aceito, leia de volta com `tcgetattr` e compare (ver `tcgetattr-tcsetattr.md`)
