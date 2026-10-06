**Noções de rede para usar sockets**

> conceitos por trás de `sys/socket.h`, `netinet/in.h` e `arpa/inet.h`

Para usar a API de sockets do C não é preciso saber como a rede funciona por inteiro, mas é preciso entender alguns conceitos: o que é um endereço IP, o que é uma porta, a diferença entre TCP e UDP e o que acontece quando um cliente se conecta a um servidor. Cada função da API (`socket`, `bind`, `listen`, `accept`, `connect`, `send`, `recv`) corresponde diretamente a um desses conceitos

---

**Rede e pacote**

Uma rede é um conjunto de máquinas (hosts) que conseguem trocar dados entre si. Os dados não viajam como um fluxo contínuo: são divididos em **pacotes**, pequenos blocos de bytes (normalmente até cerca de 1500 bytes em redes Ethernet/Wi-Fi) que viajam de forma independente

```text
pacote
┌──────────────────────────────┬─────────────────────────┐
│ cabeçalho                    │ dados (payload)         │
│ origem, destino, tamanho...  │ os bytes que você enviou│
└──────────────────────────────┴─────────────────────────┘
```

- O **cabeçalho** diz de onde o pacote veio, para onde vai e como tratá-lo. Os **dados** são o conteúdo que o seu programa mandou
- Cada pacote pode seguir um caminho diferente, chegar fora de ordem, chegar duplicado ou se perder. Quem decide se isso é corrigido é o protocolo usado (TCP corrige, UDP não)
- Uma mensagem grande enviada com `send()` pode virar vários pacotes, e vários `send()` pequenos podem ir juntos em um pacote só

---

**Camadas**

A comunicação é organizada em camadas, cada uma resolvendo um problema e usando a de baixo. Cada camada coloca o seu próprio cabeçalho em volta dos dados da camada de cima (encapsulamento):

```text
aplicação     seus dados ("GET / HTTP/1.1", "ola")        ← o seu programa
   │
   ▼
transporte    TCP ou UDP: portas, ordem, confiabilidade   ← o kernel, via socket
   │
   ▼
rede          IP: endereço de origem e destino, rotas     ← o kernel
   │
   ▼
enlace        Ethernet / Wi-Fi: envio até a próxima máquina ← placa de rede
```

- O seu programa só cuida da camada de **aplicação**: escreve e lê bytes no socket. TCP/UDP, IP e enlace são feitos pelo kernel e pelo hardware
- No socket você só **escolhe** qual transporte (TCP ou UDP) e qual versão de IP (IPv4 ou IPv6) quer usar

---

**Endereço IP**

O endereço IP identifica uma **máquina** (mais precisamente, uma interface de rede) na rede. É o que a camada de rede usa para levar um pacote até o destino

- **IPv4**: 32 bits, escrito como 4 números de 0 a 255 (`192.168.0.10`). Na API: `AF_INET`, `struct sockaddr_in`, `INET_ADDRSTRLEN`
- **IPv6**: 128 bits, escrito em hexadecimal (`2001:db8::1`). Na API: `AF_INET6`, `struct sockaddr_in6`, `INET6_ADDRSTRLEN`
- Endereços especiais:
	- `127.0.0.1` (`::1` no IPv6), o **localhost**: a própria máquina. Usado para testar cliente e servidor no mesmo computador. Os pacotes nunca saem da máquina
	- `0.0.0.0` (`INADDR_ANY`): usado só no `bind` de um servidor, significa "aceite conexões em **qualquer** interface desta máquina"
	- `192.168.x.x`, `10.x.x.x`, `172.16.x.x` a `172.31.x.x`: endereços **privados**, válidos só dentro de uma rede local. Para sair para a internet, o roteador troca o IP privado pelo público (NAT)
- A conversão entre texto e o formato binário que a API usa é feita com `inet_pton` (texto → binário) e `inet_ntop` (binário → texto). Ver `functions/inet_pton.md` e `functions/inet_ntop.md`

---

**Nomes e DNS**

Pessoas usam nomes (`example.com`), mas os pacotes só conhecem IPs. O **DNS** é o serviço que traduz um nome para um ou mais IPs. Em C, isso é feito com `getaddrinfo`, que também já preenche a `struct sockaddr` pronta para o `connect` (ver `functions/getaddrinfo.md`)

---

**Porta**

O IP leva o pacote até a máquina, mas uma máquina tem vários programas usando a rede ao mesmo tempo. A **porta** é um número de 16 bits (0 a 65535) que identifica **qual programa** dentro da máquina deve receber os dados

```text
192.168.0.10:80     → servidor web
192.168.0.10:22     → servidor SSH
192.168.0.10:8080   → o seu servidor de teste
```

- Faixas:
	- 0 a 1023: portas conhecidas (`80` HTTP, `443` HTTPS, `22` SSH, `53` DNS). Fazer `bind` nelas normalmente exige permissão de administrador
	- 1024 a 49151: registradas, livres para uso por aplicações (`8080`, `5432`, `3000`)
	- 49152 a 65535: **efêmeras**: escolhidas automaticamente pelo kernel para o lado do cliente
- O servidor escolhe uma porta fixa com `bind`. O cliente normalmente não chama `bind`, e o kernel escolhe uma porta efêmera no `connect`
- Uma conexão TCP é identificada pelo conjunto **IP de origem, porta de origem, IP de destino, porta de destino**. Por isso um servidor na porta `8080` atende vários clientes ao mesmo tempo: cada cliente tem um IP ou uma porta de origem diferente
- TCP e UDP têm portas separadas: a porta `53/tcp` e a porta `53/udp` são coisas diferentes

---

**Byte order**

Números com mais de um byte podem ser guardados na memória em duas ordens. A rede usa **big-endian** (o byte mais significativo primeiro), enquanto x86 e ARM usam little-endian. Por isso portas e IPs precisam ser convertidos antes de ir para a `struct sockaddr`:

```c
address.sin_port = htons(8080);          // host to network short: 8080 na ordem da rede
int porta = ntohs(client.sin_port);      // network to host short: de volta para o seu int
```

- Esquecer o `htons` faz o servidor escutar em outra porta: `8080` (`0x1F90`) sem conversão vira `0x901F` = `36895`. Ver `functions/htons.md` e `functions/ntohs.md`

---

**Socket**

Um socket é a **ponta** de uma comunicação: um objeto do kernel que representa "este programa, neste IP e nesta porta, falando com aquele outro". Para o seu programa, ele é apenas um **file descriptor**, como um arquivo aberto, e por isso dá para usar `read`, `write` e `close` com ele

```c
int fd = socket(AF_INET, SOCK_STREAM, 0);
//              │        │            └─ protocolo: 0 = o padrão para o tipo
//              │        └─ tipo: SOCK_STREAM (TCP) ou SOCK_DGRAM (UDP)
//              └─ família: AF_INET (IPv4) ou AF_INET6 (IPv6)
```

- O `socket()` só cria o objeto. Ele ainda não tem endereço nem está conectado a ninguém. As funções seguintes (`bind`, `listen`, `connect`) dão esse papel a ele (ver `functions/socket.md`)
- Dados escritos no socket vão para um buffer de envio do kernel, que cuida de transformá-los em pacotes. Dados recebidos ficam em um buffer de recepção até o programa chamar `recv`/`read`

---

**TCP**

TCP (Transmission Control Protocol) é um protocolo **orientado a conexão** e **confiável**. Antes de trocar dados, os dois lados estabelecem uma conexão. Depois disso, o TCP garante que:

- todos os bytes chegam (pacotes perdidos são reenviados automaticamente)
- chegam **na ordem** em que foram enviados
- chegam sem duplicação e sem corrupção
- o remetente não envia mais rápido do que o destinatário consegue receber (controle de fluxo) nem do que a rede aguenta (controle de congestionamento)

O TCP é um **fluxo de bytes** (`SOCK_STREAM`), e não de mensagens: ele não preserva os limites entre um `send()` e outro

```text
cliente envia:   send("ola")   send("mundo")
servidor pode receber:
                 recv → "olamundo"           (os dois juntos)
                 recv → "ol"  recv → "amundo" (quebrado em outro ponto)
```

- Um `recv` pode devolver **menos** bytes do que foram enviados, ou partes de dois `send` juntos. O programa precisa definir onde cada mensagem termina: com um delimitador (como `\n` em protocolos de texto) ou com o tamanho enviado antes da mensagem
- Usado quando todos os dados precisam chegar inteiros: HTTP, SSH, banco de dados, transferência de arquivos

---

**Three-way handshake**

É a troca de três pacotes que estabelece uma conexão TCP, antes de qualquer dado ser enviado:

```text
cliente                                  servidor
                                         socket, bind, listen
                                         accept()  → bloqueia
connect() ──── 1. SYN ────────────────►
          ◄─── 2. SYN-ACK ─────────────
          ──── 3. ACK ────────────────►
connect() retorna                        accept() retorna um novo fd
```

1. **SYN** (synchronize): o cliente pede para abrir uma conexão e informa seu número de sequência inicial (usado para numerar os bytes)
2. **SYN-ACK**: o servidor confirma o pedido (ACK) e envia o seu próprio número de sequência (SYN)
3. **ACK** (acknowledge): o cliente confirma. A partir daqui, a conexão está estabelecida nos dois lados

- O handshake é feito **pelo kernel**, e não pelo seu programa: o `connect()` dispara e espera o handshake. O `listen()` faz o kernel responder aos SYN recebidos. O `accept()` só entrega uma conexão que já completou o handshake
- O `backlog` do `listen(fd, backlog)` limita quantas conexões completas podem ficar esperando um `accept()` (ver `functions/listen.md`)
- Se não houver nenhum programa escutando na porta, o servidor responde com um pacote **RST** (reset), e o `connect()` falha com `ECONNREFUSED` ("Connection refused")
- O `accept()` devolve um **novo** socket para aquela conexão. O socket original continua escutando novos clientes (ver `functions/accept.md`)

---

**Encerramento**

```text
lado A                         lado B
close() ──── FIN ───────────►  recv() retorna 0 (fim da conexão)
        ◄─── ACK ─────────────
        ◄─── FIN ─────────────  close()
        ──── ACK ───────────►
```

- Cada lado envia um **FIN** dizendo "não vou mais enviar dados". Quando o outro lado recebe o FIN, o `recv()` retorna `0`, que é o sinal de que a conexão foi fechada
- `shutdown(fd, SHUT_WR)` envia o FIN sem fechar o socket, permitindo continuar lendo a resposta (ver `functions/shutdown.md`)
- Escrever em uma conexão que o outro lado já fechou gera `EPIPE` e o sinal `SIGPIPE`, que por padrão **mata o processo**. Use `send(..., MSG_NOSIGNAL)` no Linux ou ignore o `SIGPIPE`
- Quem fecha primeiro fica um tempo no estado **TIME_WAIT** (até alguns minutos), para garantir que pacotes atrasados não sejam confundidos com uma nova conexão. É por isso que reiniciar um servidor logo depois de fechá-lo pode falhar no `bind` com `EADDRINUSE` ("Address already in use"), e por isso se usa `setsockopt(SO_REUSEADDR)` antes do `bind` (ver `functions/setsockopt.md`)

---

**UDP**

UDP (User Datagram Protocol) é um protocolo **sem conexão** e **sem garantias**: cada envio é um pacote independente (datagrama), enviado direto ao destino, sem handshake

- Não garante entrega: um datagrama pode se perder sem aviso
- Não garante ordem nem ausência de duplicação
- **Preserva os limites das mensagens**: cada `sendto()` chega como exatamente um `recvfrom()`, inteiro, ou não chega
- Não tem controle de fluxo: se o destinatário não ler rápido, os datagramas excedentes são descartados
- Tem menos atraso e menos overhead, pois não há handshake nem reenvio
- Usado quando a velocidade importa mais que a perda de um pacote ou quando a aplicação cuida disso sozinha: DNS, jogos online, chamadas de voz/vídeo, streaming, descoberta na rede local

```c
int fd = socket(AF_INET, SOCK_DGRAM, 0);
sendto(fd, msg, len, 0, (struct sockaddr *)&destino, sizeof(destino));
recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr *)&origem, &origem_len);
```

- Não usa `listen`, `accept` nem (obrigatoriamente) `connect`: o servidor faz `bind` e chama `recvfrom`, que informa quem enviou cada datagrama
- Se o buffer do `recvfrom` for menor que o datagrama, o excesso é **descartado**

---

**TCP vs UDP**

| | TCP (`SOCK_STREAM`) | UDP (`SOCK_DGRAM`) |
|---|---|---|
| Conexão | sim (three-way handshake) | não |
| Entrega garantida | sim, com reenvio | não |
| Ordem garantida | sim | não |
| Limites de mensagem | não: fluxo de bytes | sim: cada datagrama é uma mensagem |
| Controle de fluxo | sim | não |
| Velocidade/latência | maior overhead | menor overhead |
| Funções | `connect`, `listen`, `accept`, `send`, `recv` | `sendto`, `recvfrom` |
| Uso típico | HTTP, SSH, arquivos | DNS, jogos, voz, vídeo |

---

**Cliente e servidor TCP: os conceitos na API**

```text
servidor                                    cliente
socket()     cria o socket                  socket()
bind()       fixa IP e porta (ex: :8080)
listen()     o kernel aceita handshakes
accept()     espera uma conexão ◄────────── connect()  handshake até o IP:porta
recv/send    troca bytes        ◄─────────► send/recv
close()      envia FIN          ◄─────────► close()
```

- Um exemplo completo desse fluxo está em `summary.md`, e cada função tem a sua nota em `functions/`

> Para testar sem escrever o outro lado: `nc -l 8080` cria um servidor TCP simples na porta 8080 e `nc localhost 8080` cria um cliente (adicione `-u` para UDP). `ss -tlnp` (Linux) ou `lsof -iTCP -sTCP:LISTEN -n -P` (macOS) mostra quais programas estão escutando em cada porta, e `tcpdump -i lo port 8080` (Linux, `-i lo0` no macOS) mostra os pacotes do handshake passando
