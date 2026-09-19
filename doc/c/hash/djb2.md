**djb2**

Criado por Daniel J. Bernstein, é um dos hashes de string mais replicados que existem, aparecendo em implementações de tabelas hash de diversas linguagens e bibliotecas. Sua mágica está no valor inicial `5381` e na combinação `hash * 33 + c`, feita através de `(hash << 5) + hash`, o que evita uma multiplicação real

- Velocidade: muito rápido, já que troca a multiplicação por um shift e uma soma
- Qualidade: distribui bem para a maioria dos casos de uso reais, mesmo sendo simples, mas não possui garantias formais de avalanche como hashes mais modernos
- Quando usar: bom padrão para tabelas hash de uso geral quando não existe um adversário tentando forçar colisões, por ser simples de implementar e ter comportamento bem conhecido na prática
- Observação: por não ser resistente a ataques, não deve ser usado quando a entrada pode ser controlada por um usuário malicioso tentando causar colisões propositalmente (hash flooding)

```c
unsigned long
hash(unsigned char *str)
{
	unsigned long hash = 5381;
	int c;

	while (c = *str++)
		hash = ((hash << 5) + hash) + c;

	return hash;
}
```

