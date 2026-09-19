O kernel de todo sistema operacional tem uma abstração para referenciar um recurso/objeto aberto dentro de um processo e esta abstração é chamada `file descriptors` ou `fds`

O `fds` é um identificador numérico que referencia um objeto de I/O aberto. Estes objetos são acessados por uma interface comum, definida pelo kernel através da struct `file_operations`:

```c
struct file_operations {
    ssize_t (*read)            (struct file *, char __user *, size_t, loff_t *);
    ssize_t (*write)           (struct file *, const char __user *, size_t, loff_t *);
    int     (*open)            (struct inode *, struct file *);
    int     (*release)         (struct inode *, struct file *);   // = close()

    loff_t  (*llseek)          (struct file *, loff_t, int);      // = lseek()
    long    (*unlocked_ioctl)  (struct file *, unsigned int, unsigned long);
    int     (*mmap)            (struct file *, struct vm_area_struct *);
    __poll_t(*poll)            (struct file *, struct poll_table_struct *);
    int     (*flush)           (struct file *, fl_owner_t);
    int     (*fsync)           (struct file *, loff_t, loff_t, int);
    ssize_t (*sendfile)        (struct file *, loff_t *, size_t, read_actor_t, void *);
};
```

Cada campo dessa struct é implementado pelo driver ou sistema de arquivos correspondente, e é chamado pelo kernel quando o processo em userspace faz a chamada de sistema equivalente:

**flush**

O `flush` é chamado no caminho de fechamento do fd, antes do `release`, para limpar ou finalizar qualquer estado pendente daquela abertura específica

```c
int flush(struct file *file, fl_owner_t id);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `id`: identifica o dono daquela abertura, usado para distinguir entre diferentes processos que compartilham o mesmo fd

- Diferente do `release`, que só roda quando a última referência é fechada, o `flush` roda toda vez que um fd é fechado, mesmo que existam outras referências à mesma abertura
- Muito usado para garantir que erros pendentes de operações anteriores sejam reportados no `close`

> O `flush` não é chamado diretamente por uma função de userspace, ele roda internamente como parte do `close(fd)`

**fsync**

O `fsync` força os dados pendentes daquele objeto a serem sincronizados com o armazenamento/dispositivo real, garantindo que eles não fiquem apenas em cache

```c
int fsync(struct file *file, loff_t start, loff_t end, int datasync);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `start` e `end`: o intervalo de bytes do objeto que deve ser sincronizado
- `datasync`: quando diferente de `0`, sincroniza apenas os dados, sem esperar por metadados que não afetam a próxima leitura

- Corresponde à chamada de sistema `fsync(fd)` feita em userspace
- Necessário porque, por padrão, escritas em arquivo costumam ficar em cache na memória (page cache) antes de serem gravadas fisicamente no disco

```c
fsync(fd); // chamada feita em userspace
```

**sendfile**

O `sendfile` transfere dados diretamente entre dois fds já abertos, sem precisar copiar os bytes para um buffer em espaço de usuário no meio do caminho

```c
ssize_t sendfile(struct file *out_file, loff_t *offset, size_t count, read_actor_t actor, void *target);
```

- Evita o caminho tradicional de `read` (kernel para buffer em userspace) seguido de `write` (buffer em userspace para kernel), copiando os dados diretamente dentro do próprio kernel
- Muito usado para servir arquivos estáticos em servidores web, onde os dados só precisam sair de um arquivo em disco e ir para um socket de rede

```c
sendfile(fd_destino, fd_origem, NULL, tamanho); // chamada feita em userspace
```

---

O pulo do gato está no fato de esta API ser a forma base do C se comunicar com entidades externas, sendo que:
- Sockets de rede
- Entrada e saida do terminal
- Erros printados no terminal
- Ler e escrever arquivos em disco
- Se comunicar com drivers externos
São todos tratados como apenas objetos I/O de `fds` que respondem aos mesmos comandos `read` e `write`

**fds Instanciados**

O kernel possui sempre 3 `fds` instanciados no inicio do programa sendo estes o de escrita no terminal (`stdout`), leitura no terminal (`stdin`) e escrita de erro no terminal (`stderr`) 

Quando um novo recurso é aberto, o kernel cria ou associa estruturas internas para representar aquela abertura e adiciona uma entrada na tabela de FDs do processo. Essa entrada aponta para uma estrutura interna, como uma `struct file`, que guarda informações como flags de abertura, posição atual, ponteiro para operações e dados privados. Dependendo do tipo de recurso, podem existir buffers internos, filas ou caches, mas o FD em si não é um buffer, fd é um número que referencia um objeto aberto no kernel. Lembrando que Como `0`, `1` e `2` normalmente já estão ocupados, o primeiro novo FD costuma ser `3`. Porém o kernel retorna o menor descritor livre. Se o FD `0` tiver sido fechado, por exemplo, uma nova chamada a `open` pode retornar `0`.

