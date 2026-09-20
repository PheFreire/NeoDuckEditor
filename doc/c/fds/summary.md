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

Cada campo dessa struct é implementado pelo driver ou sistema de arquivos correspondente, e é chamado pelo kernel quando o processo em userspace faz a chamada de sistema equivalente

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

