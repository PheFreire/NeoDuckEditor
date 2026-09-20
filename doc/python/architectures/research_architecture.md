# Padroes do Researches

## Ambiente ROOT, linguagem, Conteiner, Bruno, envs, Poetry e outros

**Linguagem/stack:** Python 3.12+, Django 5.2+, Django REST Framework, Pydantic v2, PostgreSQL 17, Poetry.

**Gerenciamento de pacotes:** Poetry com dois grupos — dependências de produção (`[tool.poetry.dependencies]`) e grupo `dev` (black, isort, flake8, bandit, mypy, django-stubs, pytest-django, pyupgrade, autoflake, locust). `packages` no `pyproject.toml` aponta explicitamente para `apps` e `infra` dentro de `src`.

**Framework de domínio como pacote externo:** o framework reutilizável (DTOs base, `IRepository`, `AppError`, `RelationLoader`, soft-delete Django, `IEnvs`) não vive no monorepo — é o pacote **`duck-domain-django-kit`** (import `dddk`), **publicado no PyPI** (`https://pypi.org/project/duck-domain-django-kit/`, versão resolvida atual `0.3.2`) e consumido no `pyproject.toml` como dependência normal de versão (`^0.3.0`) — não é mais path dependency local (era assim numa fase anterior de desenvolvimento do pacote, hoje é instalado do índice como qualquer outra lib). Repositório próprio em `github.com/PheFreire/DuckDomainDjangoKit`, com testes unitários e de integração Django próprios (`tests/unit/`, `tests/django/`), precisa manter `src/dddk/py.typed` (marcador PEP 561) para o mypy não tratar tudo como `Any`. Explicação completa do que o pacote oferece e como cada peça é usada: seção **"Uso completo do `dddk`"** abaixo. Para a v2, decidir se este mesmo pacote é reaproveitado (ele não tem nenhuma dependência do Researches, só de `django`/`duckdi`/`pydantic`/`toml`, então é plugável em qualquer projeto Django novo) ou se o CORE v2 parte de um fork.

**Injeção de dependência:** `DuckDI` (pacote `duckdi`, também de autoria própria) — `register(Adapter, "label", singleton_bool)` em `infra/*/container.py`, resolvido via `Get(IInterface, label="...")`. Registro de adapters é feito por *side-effect import* (`from dddk import container  # noqa: F401`) dentro de `apps.py` (`ready()`) e `settings.py`.

**Configuração/envs:** arquivo `envs.toml` na raiz (path apontado pelas env vars `INJECTIONS_PATH` e `SETTINGS_PATH`), lido via `IEnvs`/`EnvsToml` do `dddk`. Contém seções `[api]` (allowed_hosts, cors_allowed_hosts), `[debug]`, `[log]`, `[injections]` (mapa de qual adapter concreto usar por interface — ex: `repository = 'django'`, `storage_client = 's3'`, `token_generator = 'uuid'`). Segredos (`SECRET_KEY`, `DATABASE_URL`, credenciais AWS, `DJANGO_SUPERUSER_*`) ficam em variáveis de ambiente (`.envrc`/direnv local, não versionado), nunca no `envs.toml`.

**Container:** `dockerfile` (nome em minúsculo) baseado em `python:3.12-slim`, instala Poetry via script oficial, `poetry install --only main --no-root`, roda como usuário não-root (`app`), `ENTRYPOINT` em `src/entrypoint.sh` que aplica migrations → cria superuser (`make superuser` / management command `seed_admins`) → `collectstatic` → `make run` (gunicorn, 4 workers, 8 threads). `docker-compose.yml` sobe apenas o Postgres local (`db`) com healthcheck; a aplicação roda fora do compose via Poetry local.

**Bruno:** cliente de API (alternativa ao Postman/Insomnia) com coleções `.bru` versionadas em texto plano na pasta `bruno/` da raiz, com uma subpasta por domínio/app Django e um arquivo `.bru` por request. Ambientes em `bruno/environments/*.bru` (local, staging); segredos ficam em `*.bru.env` correspondentes, nunca versionados. `make bruno` / `make bruno-staging` rodam a coleção via `bru run --env <env>`.

---

## Pipeline Pre-push | Infraestrutura Github | CI | CD

**Git hooks locais (`.githooks/pre-push`, ativado uma vez por máquina com `make hooks-install` → `git config core.hooksPath .githooks`):** roda a cada `git push`, em 3 etapas sequenciais, aborta o push se qualquer uma falhar:
1. **Testes** — `poetry run pytest` (suíte completa).
2. **Auto-format** — `pyupgrade --py312-plus` → `autoflake --imports=typing` (nunca `--remove-all-unused-imports`, veja armadilha abaixo) → `isort` → `black`. Se algum arquivo for alterado, cria automaticamente um commit `style: apply automatic code formatting` com apenas os arquivos formatados e aborta pedindo novo `git push`.
3. **Checker** — `flake8` (+ flake8-bugbear), `mypy` (com plugin pydantic), `bandit` (`--skip B605,B101,B105,B608`), todos sobre `./src`.

`make pre-push` roda o mesmo pipeline localmente sem precisar de um push real — usado para validar antes de commitar.

**CI/CD (GitHub Actions):** dois workflows finos que apenas delegam para um workflow reutilizável centralizado da organização (`TaigetaTech/devops-cicd/.github/workflows/ecs-bundle.yml@main`), que builda a imagem Docker a partir do `dockerfile` e faz deploy em ECS (Fargate, cluster `figmify`, região `us-east-1`) via OIDC (`id-token: write`, sem secrets de longa duração no repo):
- `dev-researches.yml` — dispara em push para `dev`, deploy no serviço `dev-researches`.
- `bundle-researches.yml` — dispara em push para `master`, deploy no serviço `researches` (produção).

Nenhuma etapa de teste/lint roda no GitHub Actions — a validação de qualidade acontece 100% no pre-push hook local (client-side), não no servidor. Para a v2, decidir se este é o comportamento desejado ou se deve-se adicionar um workflow de CI que rode `make check`/`make test` como segunda camada de proteção.

---

## Dominios, modularizacao e hierarquias

**Estrutura de diretórios raiz de `src/`:**
```
src/
├── apps/     # domains e sub-domains da regra de negócio
└── infra/    # configurações globais: banco, DI, cloud, REST API (sem regra de negócio)
```

**Cada domain (ou sub-domain) segue sempre 3 diretórios:**
```
apps/<grupo>/<domain>/
├── domain/        # interfaces e DTOs — lógica pura, sem Django
├── infra/         # adapters + configuração Django do app (infra/django/models, admin, migrations, apps.py)
└── entrypoints/    # routes, crons, controllers
```

**Nomenclatura de entidades por domínio:** um domain pequeno tem só `domain/usecases`, `domain/dtos`; um domain maior ganha `domain/flows` (sub-usecases reutilizáveis/injetáveis) e `domain/decorators` (ex: um decorator de resolução de auth/tenant).

---

## Design e arquitetura

Clean Architecture / Hexagonal, documentada formalmente no `README.md` do projeto com nomenclatura própria em 3 camadas conceituais que mapeiam para os 3 diretórios de cada domain:

### Camada de Entrada (`entrypoints/`)
Prepara o ambiente de execução (auth, env vars), captura e estrutura os dados de entrada, delega ao Fluxo. Não implementa regra de negócio.
- **Route** — gatilho HTTP (`APIView` do DRF, instancia o `controller` como atributo de classe).
- **Cron** — gatilho por tempo (tarefas recorrentes).
- **Controller** — classe (nunca função) cujo único papel é: validar `RequestDto`, resolver dependências via `Get(IRepositoryFactory, "repository")` (DuckDI), converter `RequestDto` → DTO de domínio, chamar o usecase. Autenticação/resolução de tenant é feita por um **decorator aplicado no `__call__`** (padrão reutilizável: o decorator lê a chave de auth do payload, resolve a entidade correspondente e reinjeta o valor já resolvido de volta na request antes do controller seguir, mantendo o usecase agnóstico ao mecanismo de auth).

### Camada de Fluxo (`domain/usecases`, `domain/flows`)
Orquestra blocos e flows para resolver um problema de negócio; conhece o objetivo final, decide ordem/condições, valida e trata erros — mas não implementa lógica técnica de baixo nível diretamente.
- **Usecase** — orquestra blocos/flows/state machines; ponto de entrada da regra de negócio.
- **State Machine** — usecase modularizado em `states`, cada state decide e retorna o próximo state; usado para processos com múltiplas etapas/transições.
- **Flow** — "mini usecase" reutilizável e injetável no `__init__` de outros usecases/states (sufixo `Flow`, não `Usecase`); vive em `domain/flows/`, não em `domain/usecases/`. Usado quando lógica é compartilhada entre 2+ usecases ou quando um bloco de lógica merece ser testável isoladamente.

### Camada de Blocos (infra)
Operações concretas de baixo nível; um bloco só depende de infraestrutura, nunca de outro bloco/flow; pequenos, previsíveis, testáveis isoladamente. Regra geral: toda entidade de bloco tem **interface** (em `domain/`) + **adapter** (em `infra/`), cada uma em diretório próprio com seus DTOs, sempre com DTO de entrada e saída.
- **Repository** — CRUD sobre banco. Recebe `CreateDto/UpdateDto/WhereDto/QueryResponseDto`, retorna `Dto`.
- **Factory** — agrupa contexto de DI, instancia adapters de bloco (não recebe nada, retorna o adapter).
- **Provider** — padroniza uma operação/regra reutilizável com variações internas de implementação, mantendo o fluxo agnóstico a elas (ex: um `image_encoder` que troca de base64 para outro formato sem o fluxo saber).
- **Client** — comunicação com serviço terceiro (S3, email, APIs externas).

### Read models via PostgreSQL views
Para leitura analítica pesada, o projeto usa **views do Postgres como read models**, consumidas por *providers* Django que retornam DTOs Pydantic diretamente a partir da view — evita laços em Python, prioriza SQL. Padrão reaproveitável: quando uma consulta de leitura precisa juntar muitas tabelas/dimensões e seria custosa/repetitiva em ORM, materializar a junção como view e mapear 1:1 para um DTO de resposta.

### Middlewares e tratamento de erro global
- `DjangoAppErrorMiddleware` — captura `AppError` (do `dddk`) não tratada e converte em `JsonResponse` com `e.error`/`e.code`; complementado por um `exception_handler` do DRF (`django_app_error_handler`) para o mesmo efeito na camada REST framework.
- `RequestLogMiddleware` — loga toda request/response (exceto `/admin/`, `/static/`, `/media/`, `/health/`, `/metrics/`) de forma assíncrona via fila + thread worker (`request_log/infra/django/queue_worker.py`), sanitizando campos sensíveis (password, token, secret, etc. → `"***"`) e valores base64 grandes (→ `"base_64"`) antes de persistir.
- `HealthCheckMiddleware` — responde `/health` e `/health/` sem tocar em banco.

---

## Frameworks

- **Django 5.2+ / DRF** — camada web, `APIView` por route, `INSTALLED_APPS` listando cada sub-domain como um Django app individual (`apps.<grupo>.<domain>.infra.django.apps.<Domain>Config`), agrupados por comentário por grupo de domínio.
- **`dddk` (duck-domain-django-kit)** — framework de domínio próprio, publicado no PyPI, externo ao monorepo. Ver seção dedicada **"Uso completo do `dddk`"** logo abaixo.
- **`duckdi`** — injeção de dependência própria, publicada no PyPI. Ver seção dedicada **"Uso completo do `duckdi`"** logo abaixo.
- **Pydantic v2** — todos os DTOs de domínio.
- **numpy** — usado onde há cálculo agregado/estatístico pesado em memória, evitando reimplementar essas operações em Python puro.
- **boto3** — cliente S3 (armazenamento de mídia/anexos).
- **gunicorn + whitenoise** — servidor de produção + arquivos estáticos.
- **reportlab** — geração de PDF (relatórios/exports).
- **django-cors-headers**, **dj-database-url**, **psycopg2** — infraestrutura padrão Django/Postgres.
- **locust** — testes de carga (`locust/`, `make locust`), separado do restante do app.

---

## Uso completo do `duckdi`

O `duckdi` é a biblioteca de injeção de dependência própria que sustenta todo o mecanismo de inversão de controle do Researches — inclusive o `dddk` é consumidor dela (registra `EnvsToml` através dela). É deliberadamente minimalista: 3 funções públicas (`Interface`, `register`, `Get`) e um dicionário global como "container". Reaproveitável no CORE v2 tal como está, sem nenhuma dependência do domínio do Researches.

**Distribuição:** pacote PyPI `duckdi`, versão atual `0.1.13` (a versão pinada no `pyproject.toml` do Researches é `^0.1.7`, mas o `dddk` exige `^0.1.13`, e é essa que acaba sendo resolvida — sem conflito real, já que `0.1.13` satisfaz ambas as faixas). Instala também o comando de CLI `duckdi` (`duckdi init [path]`, ver abaixo).

### O mecanismo, em 3 peças

- **`InjectionsContainer`** — o "container" é literalmente uma classe com dois dicionários de classe (não instância): `interfaces: dict[str, Type]` e `adapters: dict[str, Any]`, ambos mutados como estado global do processo. Não existe escopo/contexto — é um singleton de módulo.

- **`@Interface`** — decorator aplicado à classe abstrata (interface). Só faz uma coisa: registrar a classe em `InjectionsContainer.interfaces[label]`, onde `label` é o parâmetro explícito (`@Interface(label="repository")`) ou, se omitido, o nome da classe convertido para snake_case (`@Interface` puro, sem parênteses, também funciona via overload). Lança `InterfaceAlreadyRegisteredError` se o label já estiver em uso. **Importante:** esse registro em `interfaces` é só bookkeeping/anti-colisão — `Get()` nunca consulta esse dicionário para resolver nada; a resolução depende só do label e do dicionário `adapters`.

- **`register(adapter, label=None, is_singleton=False)`** — associa uma classe concreta (adapter) a um label em `InjectionsContainer.adapters[label]`. Se `is_singleton=True`, a classe já é **instanciada imediatamente** na chamada de `register()` e a mesma instância é reaproveitada em toda resolução futura; se `False`, guarda a classe (não instanciada) e cada `Get()` cria uma instância nova. Lança `AdapterAlreadyRegisteredError` em label duplicado. É por isso que todo `register()` do Researches usa `True` — os adapters concretos (repositórios, factories, clients) são stateless o suficiente para serem singletons de processo.

- **`Get(interface, label=None, adapter=None, instance=True)`** — o resolvedor, chamado em runtime (tipicamente dentro de um controller):
  1. Resolve `interface_name` = `label` explícito, ou snake_case do nome da classe interface.
  2. Se `adapter` não foi passado explicitamente, busca `adapter_name` no **payload de injeção** (arquivo TOML — ver abaixo) pela chave `interface_name`.
  3. Busca `InjectionsContainer.adapters[adapter_name]`.
  4. Valida que o adapter resolvido realmente implementa/é subclasse da `interface` pedida — senão lança `InvalidAdapterImplementationError` (proteção contra config incoerente, ex: label apontando pro adapter errado).
  5. Retorna a instância (se singleton, a já criada; se classe, instancia agora) ou a própria classe, dependendo de `instance=True/False`.
  - O parâmetro `adapter=` permite ignorar o payload e forçar uma implementação específica na hora (útil para testes/mocks sem precisar mexer no TOML).

### Payload de injeção — o TOML que liga interface → adapter

`InjectionsPayload.load()` lê o arquivo TOML apontado pela env var `INJECTIONS_PATH` (fallback: `./injections.toml`) e devolve o conteúdo da seção `[injections]` — um mapa simples `"interface_label" = "adapter_label"`. Se o arquivo não existir, lança `MissingInjectionPayloadError` com uma mensagem de erro que já sugere o comando pra criar o arquivo.

**Como o Researches usa isso na prática:** `INJECTIONS_PATH` aponta para o **mesmo arquivo** `envs.toml` que o `dddk` usa como `SETTINGS_PATH` (ambas as env vars, no `.envrc`, apontam para `envs.toml`) — ou seja, o projeto consolida configuração de ambiente e payload de injeção de dependência em um único arquivo TOML, na seção `[injections]`:
```toml
[injections]
repository = 'django'
token_generator = 'uuid'
dashboard = 'numpy'
dashboard_provider = 'django-views'
storage_client = 's3'
image_encoder = 'base64'
```
Cada chave é o label de uma interface decorada com `@Interface(label="...")` em algum lugar do domínio (ex: `IRepositoryFactory` com `@Interface(label="repository")`); cada valor é o label do adapter concreto registrado em `infra/container.py`:
```python
register(DjangoRepositoryFactory, "django", True)
register(UuidTokenGenerator, "uuid", True)
register(NumpyDashboardFactory, "numpy", True)
register(DjangoDashboardProviderFactory, "django-views", True)
register(AwsS3StorageClient, "s3", True)
register(Base64ImageEncoderProvider, "base64", True)
```
Assim, trocar de implementação (ex: trocar S3 por outro storage) é só mudar `storage_client = 's3'` para outro label no TOML — desde que o novo adapter já esteja registrado — sem tocar em nenhum usecase/controller. Esse é o valor central do padrão: **o domínio depende só da interface (`IStorageClient`), nunca do adapter concreto**, e a escolha de qual adapter usar é dado de configuração, não código.

*Observação para quem for portar isso ao CORE v2:* nem toda chave presente em `[injections]` no `envs.toml` atual do Researches corresponde a uma interface de fato registrada/consumida — `debugger = 'ipdb'` e `logger = 'json'` estão na seção mas não há nenhum `@Interface`/`register()` correspondente no código hoje (configuração morta/legada). Vale limpar isso ao montar o `envs.toml` do CORE v2 em vez de copiar a seção `[injections]` como está.

### Registro dos adapters — sempre por *side-effect import*

Não existe um "bootstrap" central que chama `register()` explicitamente a partir do entrypoint da aplicação — o padrão do projeto é colocar todas as chamadas de `register()` em um único módulo `infra/container.py` (ou `infra/*/container.py` por camada) e garantir que esse módulo seja importado uma vez, cedo, via import por efeito colateral:
- Em `infra/django/rest_api/apps.py`, dentro de `ready()` do `AppConfig`.
- Em `infra/django/rest_api/settings.py`, direto no topo do arquivo.
- O `dddk` faz o mesmo internamente: `dddk/container.py` roda `register(EnvsToml, "toml", True)` assim que é importado, e isso é disparado por `from dddk import (container,)  # noqa: F401` em `settings.py`.

Convenção de marcação: todo import feito só pelo efeito colateral (não usa o símbolo importado diretamente) leva `# noqa: F401` para o `flake8` não reclamar de "import não usado" — e é justamente por isso que rodar `autoflake --remove-all-unused-imports` é proibido no projeto (ver Pipeline Pre-push): ele apagaria esses imports, quebrando silenciosamente todo o registro de DI.

### Tratamento de erro

Todos os erros do `duckdi` (`InterfaceAlreadyRegisteredError`, `AdapterAlreadyRegisteredError`, `InvalidAdapterImplementationError`, `MissingInjectionPayloadError`) são exceptions Python nativas (não `AppError` do `dddk`) com mensagens multi-linha já formatadas explicando a causa provável e sugerindo a correção — pensadas para aparecer direto no traceback de boot da aplicação (erros de configuração de DI acontecem no import/startup, não em request-time, então não faz sentido tratá-los como erro HTTP de domínio).

### CLI (`duckdi init`)

O pacote expõe um `argparse` CLI (`duckdi init [path]`) que gera um `injections.toml` inicial com a seção `[injections]` comentada como exemplo. No Researches esse arquivo separado nunca chegou a ser usado — o projeto optou por consolidar tudo em `envs.toml` (ver acima) em vez de manter dois arquivos TOML paralelos. Vale decidir conscientemente no CORE v2 se compensa manter essa consolidação (menos arquivos de config) ou separar `injections.toml` de `envs.toml` (responsabilidades mais isoladas).

---

## Uso completo do `dddk`

O `dddk` é o núcleo técnico reaproveitável do Researches: tudo que uma nova API Django/DRF precisa para ter DTOs tipados, repositório genérico, soft-delete, resolução de relações em lote e tratamento de erro padronizado, sem reescrever essa infraestrutura a cada projeto. É o candidato natural a ser reaproveitado 1:1 (ou com fork mínimo) no CORE v2, já que **não tem nenhuma dependência do domínio de negócio do Researches** — só depende de `django`, `duckdi`, `pydantic` e `toml`.

**Distribuição:** pacote PyPI `duck-domain-django-kit`, import `dddk`, versão resolvida atual `0.3.2` (pinada no `pyproject.toml` como `^0.3.0`; o texto abaixo já reflete essa versão — a `0.1.1` citada em revisões anteriores deste doc ficou defasada, houve mudanças reais de API entre elas, ver *"Mudanças de API entre `0.1.1` e `0.3.2`"* ao final desta seção). Instalado como dependência normal de versão no `pyproject.toml`, resolvido do índice público (não é mais path dependency local). Repositório próprio (`github.com/PheFreire/DuckDomainDjangoKit`) com suíte de testes unitários e de integração Django própria e `py.typed` (PEP 561) para preservar tipagem no consumidor.

**Superfície pública (`dddk/__init__.py`):** a maior parte do pacote é importada diretamente (`AppError`, `BaseDto`, `Null`, `NullOr`, `RequestDto`, `CreateDto`, `UpdateDto`, `WhereDto`, `IEnvs`, `IRepository`, `QueryResponse`, `populate_fk_relations`, `RelationLoader` e todos os `*RelationConfig`). Já os símbolos que dependem de Django (`SoftDeleteModel`, `SoftDeleteDjangoRepository`, `SoftDeleteAdmin`, `get_if_active`) são carregados **preguiçosamente** via `__getattr__` — só importam Django de fato na primeira vez que são acessados. Isso permite importar `dddk` em contextos de bootstrap (ex: dentro do próprio `settings.py`, antes do Django terminar de inicializar) sem erro de import circular.

### `types/` — DTOs base e o sentinel `Null`

- **`BaseDto`** — wrapper sobre `pydantic.BaseModel` com `arbitrary_types_allowed=True` e um `@field_serializer` que converte o sentinel `Null` para `None` na serialização JSON. Todo DTO de domínio herda dele (direta ou indiretamente). Também expõe `.get(attr, expected_type)` — getter type-safe que lança `AppError(500)` se o atributo não existir ou não bater com o tipo esperado, em vez de deixar um `AttributeError`/`TypeError` cru vazar.
- **`Null` / `NullOr[T]`** — sentinel próprio (não é `None`) para representar 3 estados possíveis de um campo: **valor presente**, **explicitamente nulo** (`Null`) e **ausente** (campo nem enviado). É o mecanismo que resolve o problema clássico de "como diferenciar 'não mandei esse campo' de 'mandei esse campo como null'" em updates parciais e filtros de busca — `None` sozinho não dá conta disso. `Null.__bool__()` é `False` e `Null == Null` é `True`, então dá pra usar em condicionais normalmente.
- **`RequestDto(BaseDto)`** — usado especificamente para validar payload de entrada HTTP: `model_config = ConfigDict(extra="forbid")` (rejeita campos não declarados) e o classmethod `validate_or_error(data: dict) -> Self`, que roda a validação Pydantic e, se falhar, converte o `ValidationError` nativo em `AppError(code=422)` com `details={"provided": ..., "error": [...]}` — assim toda a app trata erro de validação de request de forma uniforme (mesmo formato de erro que qualquer outro `AppError`).

### `crud/` — contrato de repositório e DTOs por operação

- **`CreateDto` / `UpdateDto` / `WhereDto`** (todos `BaseDto`) — DTOs especializados por operação, forçados por convenção de nomenclatura, não por herança de comportamento diferente entre si (exceto `WhereDto`, que já vem com os campos base `uuid`, `uuids`, `created_at`, `updated_at`, `deleted_at`, todos `NullOr`, prontos para filtro).
- **`IRepository[DTO, WHERE, CREATE, UPDATE, RESPONSE]`** — interface ABC genérica (5 type params) que todo repositório de domínio implementa: `create(create) -> DTO`, `create_many(creates) -> QueryResponse[DTO, None]`, `find(where) -> QueryResponse[RESPONSE, WHERE]`, `update(id, update) -> DTO`, `delete(id) -> str`. É o contrato que faz o usecase nunca depender de Django/SQL diretamente — só da interface.
- **`QueryResponse[RESPONSE, WHERE]`** — wrapper iterável em volta do resultado de `find()`, carrega os DTOs + o `WhereDto` usado + o nome do objeto/tabela (pra mensagens de erro). Métodos principais:
  - `.all` → `list[RESPONSE]`, nunca lança.
  - `.first` → `RESPONSE | None`.
  - `.first_or_error(class_pointer)` / `.all_or_error(class_pointer)` → lançam `AppError(404)` padronizado (título/detalhes montados automaticamente a partir do `object_name` e dos filtros usados) quando vazio.
  - `.empty_or_error(class_pointer)` → lança `AppError(409)` se **existir** algum resultado (usado em checagem de duplicata antes de criar).
  - `.exists_or_error(class_pointer)` → o inverso semântico de `all_or_error`, mesma ideia de erro 404.
  - `.to_dict()` → serializa para `{"data": [...], "count": N, "filters": {...}}`.
  - `.parallel_map(func, divisions=4, class_pointer=None)` → processa a lista de DTOs em paralelo usando `AsyncHandler` (thread pool), útil para transformar/enriquecer listas grandes sem laço sequencial; qualquer falha numa thread vira `AppError(500)` padronizado.
  - Suporta `len()`, `for x in`, indexação `[i]` e `bool()` diretamente.
- **`IIncludeProvider[WHERE, RESPONSE]`** — interface para quem implementa "populamento de include" fora do padrão `RelationLoader` (ver abaixo); a docstring é explícita: proíbe query por item dentro de loop, proíbe alterar paginação/filtros originais, só permite enriquecer os DTOs já retornados em batch.
- **`AsyncHandler[T]`** — o motor por trás de `parallel_map`: divide uma lista em N chunks balanceados, roda uma função por chunk num `ThreadPoolExecutor`, junta o resultado preservando ordem, converte qualquer exceção de thread em `AppError` com contexto (chunk, exceção original).
- **`populate_fk_relations(dtos, attr, repository, relation_where)`** — helper standalone mais simples e anterior ao `RelationLoader` (ainda exportado no `__init__`, mas coberto/substituído na prática pelo `RelationLoader` para casos novos — ver abaixo). Resolve uma única relação FK em batch preenchendo `dtos[i].attr` com a entidade relacionada.
- **`populate_m2m_relations(...)`** *(novo desde a versão `0.1.1`, módulo `dddk.crud.tools.populate_m2m_relations`)* — equivalente ao `populate_fk_relations`, mas para many-to-many via tabela pivot: 2 queries em batch (pivot → ids relacionados, depois entidade relacionada → objetos), agrupa por pai e estende (não substitui) o campo de relação já existente no DTO. **Atenção:** ao contrário dos outros helpers/exports, **não está no `__all__` de `dddk/__init__.py`** — precisa ser importado direto do submódulo (`from dddk.crud.tools.populate_m2m_relations import populate_m2m_relations`). Ainda não adotado em nenhum ponto do Researches (o projeto resolve M2M via `RelationLoaderConfig.m2m_relations`/`m2m_with_pivot_relations` no `RelationLoader`, não via este helper solto) — provavelmente um utilitário legado/experimental do pacote, vale confirmar com o autor do `dddk` antes de basear algo novo nele no CORE v2.

### `crud/django/` — implementação concreta sobre o ORM do Django

- **`SoftDeleteTable(models.Model, abstract)`** — mixin base de soft-delete: campos `created_at`/`updated_at`/`deleted_at`; dois managers (`objects` filtra `deleted_at__isnull=True` por padrão, `everything` não filtra nada); métodos `soft_delete()` (seta `deleted_at=now()`) e `restore()` (limpa `deleted_at`); `build_prefetches(relations: list[str])` monta `Prefetch` do Django automaticamente com queryset já filtrado por `deleted_at__isnull=True` quando a relação aponta para outro model soft-delete-aware — evita trazer registros soft-deleted junto de `prefetch_related` comuns.
- **`SoftDeleteModel(SoftDeleteTable, abstract)`** — acrescenta PK própria: `uuid = UUIDField(primary_key=True, default=uuid4, editable=False)`, e declara o método abstrato `as_dto() -> BaseDto` que toda model concreta deve implementar (é o ponto único de conversão model → DTO de domínio).
- **`SoftDeleteDjangoRepository[MODEL, DTO, WHERE, CREATE, UPDATE, RESPONSE]`** — implementação genérica de `IRepository` sobre o ORM, é o que toda `DjangoXxxRepository` do projeto estende:
  - `create()` → `model.objects.create(**create.model_dump())`.
  - `create_many()` → `model.objects.bulk_create(instances, batch_size=500)` — é a base técnica por trás da regra "nunca laço de `create()` individual".
  - `find(where)` → converte o `WhereDto` em filtros Django: ignora automaticamente qualquer campo `Null`; se vier `uuids` (ou `ids`), converte para `{pk_field}__in` usando `model._meta.pk.name` (funciona mesmo se a PK não se chamar `id`); aceita filtro direto por nome de campo do model, por sufixo `_id` (FK) e por sufixo `__in`; e permite mapear campo do DTO → expressão Django arbitrária (ex: joins) via o atributo de classe `where_field_to_filter: dict[str, str]`.
  - `update(id, update)` → busca por PK, ignora campos `Null` do `UpdateDto`, aceita atualizar FK via sufixo `_id`, lança `AppError(404)` se não achar o registro.
  - `delete(id)` → soft-delete via `instance.soft_delete()`, lança `AppError(404)` se não achar.
  - Erros de "não encontrado" em `update`/`delete` já vêm no formato `AppError` padronizado, sem precisar reimplementar em cada repositório concreto.
  - **`select_related_fields: ClassVar[tuple[str, ...]] = ()`** *(novo desde a versão `0.1.1`)* — atributo de classe opcional que todo repositório concreto pode declarar com os nomes dos campos FK que seu `as_dto()` desreferencia (tipicamente via `get_if_active`). Quando preenchido, `find()`, `create_many()` e `update()` aplicam `.select_related(*select_related_fields)` automaticamente antes de montar os DTOs — evita 1 query extra por linha/por FK que aconteceria em `as_dto()` sem esse join (N+1). `create_many()`, que via `bulk_create` só recebe de volta colunas escalares (inclusive `*_id`), rebusca as linhas recém-criadas num único `SELECT ... JOIN` quando `select_related_fields` está setado; `update()` faz o mesmo rebusca após o `save()`. Já adotado nos repositórios concretos do Researches (ex: `DjangoApplicationRepository.select_related_fields = ("applier", "research", "application_setting", "master_key")`) — vale preservar esse padrão no CORE v2 desde o início, em vez de descobrir o N+1 depois.
- **`SoftDeleteAdmin(admin.ModelAdmin)`** — admin base pronto para qualquer model soft-delete: filtro customizado "Soft Delete" (Deleted/Not Deleted) na sidebar, `readonly_fields=["uuid", "deleted_at"]`, `ordering=["-created_at"]`, e 3 actions em massa prontas — `soft_delete_selected`, `restore_selected`, `duplicate_selected` (duplicação detecta sozinha os campos `CharField`/`TextField` únicos do model, incluindo `UniqueConstraint`, e tenta sufixos `" - Copy"`, `" - Copy 2"`, ... até achar um valor livre, com `transaction.atomic()` por tentativa). `get_queryset` usa o manager `everything`, então o admin sempre mostra até os registros soft-deleted.
- **`get_if_active(model)`** — helper de uma linha: retorna `str(model.uuid)` só se o registro não estiver soft-deleted, senão `None`. Útil para popular referências que devem "sumir" quando o alvo foi soft-deleted sem lançar erro.

### `relations_loader/` — resolução declarativa de relações em lote (padrão "include")

Padrão central para resolver o problema de N+1 queries ao popular relações (FK, has-many, M2M) em listas de DTOs vindas de `find()`. Uso: `RelationLoader().load(dtos, include, config)`, onde `include` é o `IncludeDto` da busca (campos booleanos por relação) e `config` é um `RelationLoaderConfig` — dataclass que agrupa 4 tipos de relação, cada uma resolvida **apenas** se o campo booleano correspondente estiver `True` no `include`. *(Mudança desde `0.1.1`:* `.load()` agora retorna um `RelationLoaderResult[DTO]` — dataclass wrapper com um único campo `.items` (a mesma lista de DTOs recebida, mutada in-place) — em vez de não retornar nada; todo call site do Researches já usa `self.relation_loader.load(dtos=..., include=..., config=...).items`, ex: `find_respondents_usecase.py`, `find_application_usecase.py`, `find_research_usecase.py`.)*

- **`FkRelationConfig`** — many-to-one: o DTO pai carrega um id escalar (`source_id_field`) apontando para uma entidade relacionada; 1 query em batch busca todas as entidades referenciadas de uma vez e popula `target_field` em cada DTO.
- **`HasManyRelationConfig`** — one-to-many: os filhos referenciam o pai via FK (`child_parent_id_field`); 1 query busca todos os filhos cujo FK está na lista de ids dos pais, depois agrupa em memória por pai.
- **`M2MRelationConfig`** — many-to-many via tabela pivot: 2 queries (uma na tabela pivot para mapear pai→ids relacionados, outra na entidade relacionada para buscar os objetos); **descarta** o registro de pivot, só devolve a lista de entidades relacionadas.
- **`M2MWithPivotRelationConfig`** — variação do M2M para quando o **próprio registro de pivot** carrega atributos extras que interessam (ex: um campo de valor/ordem/papel associado à relação): mantém o registro de pivot como alvo e o enriquece com a entidade relacionada resolvida (`pivot_target_field`), em vez de descartá-lo.

Regras de design que valem a pena preservar no CORE v2:
- **Toda resolução é em lote** — nunca 1 query por item da lista (é proibido tanto pela implementação quanto pela docstring de `IIncludeProvider`).
- Cada config é validada em runtime: se o `WhereDto` informado não tiver o campo esperado (`where_ids_field`, `where_parent_ids_field`, etc.), lança `AppError(500)` imediatamente — falha cedo numa configuração errada em vez de silenciosamente não popular nada.
- `RelationLoaderConfig` só carrega as sequências de relação que o domain realmente usa — as não usadas default para tupla vazia, sem overhead.

### `error/` — `AppError`, o formato de erro único do sistema

Exception custom (`class_pointer`, `title`, `message`, `details: dict`, `code: int` HTTP-like, default 400) usada em toda a stack — usecases, repositórios, DTOs de request, `RelationLoader`, etc. — nunca se levanta `Exception`/`ValueError` cru na lógica de domínio. Captura automaticamente, via `inspect.stack()`, o arquivo e a linha de onde foi instanciada (`caller_file`/`caller_line`), incluídos na property `.error` (dict serializável: `class_name`, `caller`, `title`, `message`, `details`, `code`) — esse dict é exatamente o body JSON devolvido pelo middleware/exception handler de erro (ver seção de Middlewares). `__str__` formata um bloco de log legível para terminal.

### `envs/` — configuração tipada

*(Seção reescrita — mudança real de API entre `0.1.1` e `0.3.2`, não só cosmética: a superfície de `IEnvs` encolheu.)*

- **`IEnvs`** (interface DuckDI, registrada com `label="env"`) — hoje expõe **apenas uma property abstrata**: `database` (`DatabaseSettingsDto`). As properties `log`/`debug`/`api` e seus DTOs (`LogSettingsDto`, `DebugSettingsDto`, `ApiSettingsDto`) citados em revisões anteriores deste documento **não existem mais no pacote** — o `dddk` deixou de tentar tipar configuração de log/debug/api do consumidor; isso agora é responsabilidade 100% do projeto (Django `settings.py` lê `os.getenv`/constantes diretamente, sem passar por `IEnvs`). Confirmado batendo com o uso real no Researches: `Get(IEnvs, label="env")` só é chamado em `settings.py`, e o único atributo acessado no objeto retornado é `envs.database.url`.
- **`DatabaseSettingsDto`** ganhou um `@field_validator("url")` que valida o formato da `DATABASE_URL` com regex (schemes aceitos: `postgres(ql)?`, `mysql`, `sqlite`, `oracle`, `mssql`, `postgresql+psycopg`) e lança `AppError(400)` se a URL não bater com o padrão — antes a validação de `database` era só o `.model_validate(...)` genérico.
- **`EnvsToml(IEnvs)`** — implementação concreta: monta `database` só a partir da env var `DATABASE_URL` (não lê mais nada do TOML, já que não sobrou nenhuma outra property para preencher). Se a env var não existir, lança `AppError(500)` com o nome da chave faltante.
- **Registro automático:** `dddk/container.py` roda `register(EnvsToml, "toml", True)` (singleton) assim que é importado — é por isso que `settings.py` do Researches faz `from dddk import (container,)  # noqa: F401`: o único propósito desse import é disparar esse side-effect de registro no container do DuckDI antes de qualquer `Get(IEnvs, ...)` ser chamado.
- **Nota para o `envs.toml` do CORE v2:** a seção `[injections]` do `envs.toml` atual do Researches ainda tem `debugger = 'ipdb'` e `logger = 'json'` — como já apontado na observação sobre `duckdi` acima, essas chaves eram config morta mesmo quando `IEnvs` tinha `log`/`debug`; com a redução da interface a documentação de que "podem ter sido usadas no passado" perde ainda mais força. Não replicar essas chaves no `envs.toml` do CORE v2 sem antes confirmar se algum adapter as consome de fato.

### `utils/`

- **`Parser`** — `toml_load(path)` carrega TOML e converte qualquer falha em `AppError(500)` com `{"exception_details", "invalid_path"}`. *(Ponto de atenção para quem for reaproveitar: `json_load(path)` existe mas hoje também chama `toml.load()` internamente — parece um bug/cópia-colada do pacote atual, não um JSON parser de fato; vale corrigir ou simplesmente não usar `json_load` até corrigir.)*
- **`match_filter`** — `match_any_filter(filters: list[dict], value: dict)` / `unmatch_any_filter(...)`: helpers genéricos para checar se um dict bate (ou não bate) com nenhum de uma lista de filtros parciais — útil para regras de inclusão/exclusão configuráveis por dado (ex: a "regra de exclusão" citada em Design e arquitetura é construída em cima desse tipo de helper).

### `logs/` (utilitário interno, não exportado em `__init__`)

- **`jsonify(obj)`** — normaliza tipos não nativamente serializáveis em JSON (`datetime`/`date` → isoformat, `UUID`/`Decimal` → `str`, `Mapping`/`list`/`tuple`/`set` recursivamente, fallback `str(obj)`).
- **`pretty(title, value, ...)`** — impressão colorida/formatada (ANSI) para debug local em terminal, com linhas separadoras e cores configuráveis. Não faz parte da superfície pública do pacote (não está em `__all__`), é utilitário de desenvolvimento.

### `container.py` — bootstrap de DI do próprio pacote

Ao ser importado, `dddk.container` registra `EnvsToml` como a implementação padrão de `IEnvs` sob o label `"toml"` (via `duckdi.register`, singleton). Esse é o único registro que o pacote faz sozinho — todo o resto da injeção de dependência (repositórios, factories, clients, providers) é responsabilidade do projeto consumidor, registrado no `infra/*/container.py` do próprio Researches.

### Mudanças de API entre `0.1.1` e `0.3.2`

Resumo de tudo que mudou de fato no contrato do `dddk` desde a versão citada em revisões anteriores deste documento (`0.1.1`) até a versão resolvida hoje no `poetry.lock` do Researches (`0.3.2`) — útil como checklist de compatibilidade se o CORE v2 decidir fixar uma versão mais antiga por engano, ou para saber o que testar ao fazer bump de versão:

1. **`IEnvs` perdeu 3 das 4 properties** — só sobrou `database`. `log`, `debug`, `api` (e os DTOs `LogSettingsDto`/`DebugSettingsDto`/`ApiSettingsDto`) foram removidos do pacote; ver seção `envs/` acima.
2. **`DatabaseSettingsDto.url` ganhou validação de formato** via regex (`@field_validator`), lançando `AppError(400)` em URL malformada — antes só validava tipo/presença.
3. **`SoftDeleteDjangoRepository` ganhou `select_related_fields`** (`ClassVar[tuple[str, ...]]`) — join automático via `select_related` em `find()`, `create_many()` e `update()` para evitar N+1 ao desreferenciar FKs em `as_dto()`. Não existia na `0.1.1`.
4. **`RelationLoader.load()` mudou o retorno** — antes não retornava nada (mutava a lista in-place e o caller reusava a mesma referência); agora retorna `RelationLoaderResult[DTO]`, e o valor útil está em `.items`. Quebra de compatibilidade silenciosa: código escrito contra `0.1.1` que ignorava o retorno de `.load()` continua funcionando (a lista original ainda é mutada), mas qualquer código que capturasse o retorno esperando `None` ou a lista direta precisa de `.items`.
5. **Novo helper `populate_m2m_relations`** — equivalente M2M do `populate_fk_relations`, mas não exportado em `__init__.py`; import direto do submódulo. Não adotado no Researches até o momento.
6. **`crud/dtos.py` foi quebrado em `create_dto.py`/`update_dto.py`/`where_dto.py`** — reorganização interna, sem impacto de uso (os símbolos continuam re-exportados nos mesmos paths públicos).

Todo o resto do contrato documentado nesta seção (`BaseDto`, `Null`/`NullOr`, `RequestDto`, `AppError`, `IRepository`, `QueryResponse`, `SoftDeleteTable`/`SoftDeleteModel`/`SoftDeleteAdmin`, `get_if_active`, `Parser` — incluindo o bug do `json_load` ainda não corrigido — e `match_any_filter`/`unmatch_any_filter`) foi conferido linha a linha contra o código-fonte instalado (`0.3.2`) e permanece igual ao que já estava documentado.

---

## Testes

**Localização:** `tests/integration/<app_group>/<module>/domain/usecases/<usecase_name>/` (e `domain/flows/<flow_name>/` para flows), espelhando exatamente `src/apps/`. Cada pasta de usecase/flow tem `__init__.py`, `conftest.py` (fixtures `usecase` e `db_state`) e um `test_*.py` por grupo de cenário.

**Execução:** `pytest-django` com `--create-db`, `pytest-order` para execução ordenada quando necessário; `pytestmark = pytest.mark.django_db` no topo do arquivo em vez de decorar cada função. `make test` (tudo), `make test-unit`, `make test-integration`, `make test-coverage` (`--cov=src`).

**`conftest.py` — padrão:**
```python
@pytest.fixture()
def usecase():
    from apps.<path>.infra.adapters.repositories.django_<x>_repository import Django<X>Repository
    from apps.<path>.domain.usecases.<usecase> import <Usecase>
    return <Usecase>(repository=Django<X>Repository())

@pytest.fixture()
def db_state(db):
    # monta o grafo de dependências bottom-up (ver abaixo) + variantes p/ isolamento
    yield {"entity_a": entity_a, "entity_b": entity_b, ...}
```

**Grafo de dependências do DB, ordem de criação:** a fixture `db_state` monta manualmente, na ordem certa, toda a cadeia de entidades-pai exigida pelas FKs da entidade testada — da raiz da hierarquia (tenant/dono do dado) até a entidade específica do teste. Sempre inclui variantes irmãs (mesmo nível hierárquico, mas em outro tenant/pai) para provar isolamento, e registros soft-deleted onde a regra de exclusão lógica for relevante.

**Cenários obrigatórios por tipo de usecase:**
- *Create*: retorna DTO correto (uuid, timestamps, `deleted_at=None`); persiste no DB; variantes válidas não duplicam falsamente (mesmos campos "duplicáveis" mas com um FK de escopo diferente não é duplicata); duplicata exata (mesmo escopo) lança `AppError` 409; soft-deleted existente não bloqueia nova criação.
- *Find*: retorna lista do DTO correto; soft-deleted nunca aparece; filtros por cada campo do `WhereDto`; `should_exist=True` lança `AppError` quando vazio; includes opcionais retornam `None` sem o include e dados populados com o include.

**Convenção de criação em massa:** nunca laço de `create` individual — sempre montar lista de `CreateDto` e chamar `repository.create_many(dtos).all`.

---

## Comentarios de commits

**Formato:** `type(scope): description`, seguindo convenção enxuta observada no `git log` (`feat`, `fix`, `chore`, `style`, `refactor`, `test`, com `scope` = app/módulo afetado e `description` curta no imperativo). Idioma: **inglês**, sempre — nunca português em mensagem de commit, comentário de código ou docstring.

**Processo obrigatório antes de commitar:**
1. Ler `git status`/`git log` para confirmar o padrão vigente.
2. Agrupar arquivos em commits logicamente coesos.
3. Apresentar ao usuário a divisão de arquivos + mensagem de cada commit **antes** de rodar qualquer `git commit`, aguardando aprovação explícita.
4. Após cada commit, rodar `make pre-push` e resolver todos os erros/warnings.

**Restrição crítica:** nenhum commit pode citar a ferramenta de IA usada de nenhuma forma — nem como co-author, nem em comentário de código, nem na mensagem. O commit deve parecer inteiramente autoral do time.

**Nunca `git push`** — quem decide quando publicar é o usuário.
