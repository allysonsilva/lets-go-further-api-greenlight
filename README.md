# Aplicação de Exemplo do Livro [Let's Go Further! Advanced patterns for APIs and web applications in Go](https://lets-go-further.alexedwards.net/)

## 🔧  Setup Inicial

*Para executar o projeto utilizando o **Docker**, é necessário realizar alguns passos, que são*:

1. Executar o comando que realiza o preenchimento de algumas variáveis de ambiente utilizadas no **docker compose**: `make docker/config-env`
2. Manipular as **imagens docker** que são utilizadas na aplicação:
   1. Baixar a imagem de banco de dados **MySQL 8.0**: `docker pull mysql:8.0`
   2. Para a imagem utilizada na aplicação, será necessário realizar o build da mesma, com o comando: `make docker/build`

*Obs: Todos os comandos acima são realizados na pasta root da aplicação!*

## 🚀  Executando / UP na Aplicação

Para executar a aplicação, utilize o comando: **`make docker/up`**.

Para vê as rotas / paths da aplicação, utilize o arquivo [OpenAPI-Greenlight.yaml](OpenAPI-Greenlight.yaml) no editor online do swagger [https://editor.swagger.io](https://editor.swagger.io).

Para utilizar as rotas no Postman, importe o seguinte arquivo: [Greenlight.postman_collection.json](Greenlight.postman_collection.json), edite/configure a variável de ambiente `HTTP_PORT` para o valor de: `docker inspect --format '{{ (index (index .NetworkSettings.Ports "4000/tcp") 0).HostPort }}' greenlight_app`

### Movies Request

Para fazer / realizar o CRUD de filmes, primeiro é necessário:

- *Cadastrar um novo usuário.*
- *Ativar o cadastro desse usuário.*
- *Autenticar o usuário para gerar um token e ser utilizado nas requisições / CRUD de filmes que necessitam desse token.*

#### Cadastro usuário

No cadastro do usuário, **irá ser enviado um email para o usuário**, contendo um token (*que tem o propósito diferente do token de acesso ao CRUD de filmes*) e a data de expiração de uso do token, onde deverá ser utilizado em `v1/users/activated` unicamente para validar se o email pertence mesmo ao usuário e consequentemente ativá-lo para uso nas outras URLs do sistema.

Para enviar o email em um sandbox, e não de forma real, o projeto utiliza o [https://mailtrap.io](https://mailtrap.io), então, é necessário criar uma conta no *mailtrap*, e configurar as variáveis `MAIL_USERNAME` e `MAIL_PASSWORD` do arquivo [docker/golang/.env.container](docker/golang/.env.container) de acordo com as credencias de SMTP da conta criada. Após realizar essa ação, o container da aplicação deverá ser reiniciado. Em um novo terminal, execute `make docker/api/up`.

As credencias (não válidas mais) podem ser vistos na imagem como exemplo:

![Credenciais SMTP Mailtrap](images/credenciais-smtp-mailtrap.png)

Utilize `POST /v1/users` com o seguinte payload para cadastrar um novo usuário:

```json
{
    "name": "Nome usuário",
    "email": "user@example.com",
    "password": "pa55word"
}
```

Por padrão, um novo usuário só vai ter **permissão de leitura** no **CRUD de filmes**. Para adicionar a **permissão de escrita**, utilize o seguinte INSERT:

```sql
INSERT INTO `users_permissions` (`user_id`, `permission_id`) VALUES ((SELECT id FROM users WHERE email = 'user@example.com'), 2);;
```

#### Ativar usuário

Após o `201 Created` (passo acima), então, receberá no **inbox no mailtrap** o email contendo as instruções para ativação do novo usuário. A imagem abaixo mostra o conteúdo do email.

![Email de cadastro do usuário](images/email-cadastro-usuario.png)

Com o valor do token, que está no email, é possível fazer a ativação do usuário para que possa ser utilizado no CRUD de filmes.

Então, deve-se fazer uma requisição para `/v1/users/activated` com o valor de `{"token": "<TOKEN>"}` e receber a resposta `200 Ok` juntamente com o json dos dados do usuário no body da response.

#### Autenticar usuário

O processo de "autenticar" é basicamente para fazer login com os dados do usuário, receber um token na response, e utilizar esse token nas requisições seguinte que necessite de **autenticação e autorização** (CRUD Filmes).

Para se autenticar, deve ser enviado um `POST /v1/tokens/authentication` com o payload de:

```json
{
    "email": "user@example.com",
    "password": "pa55word"
}
```

A response da solicitação acima, deverá ser algum parecido com:

```json
{
    "authentication_token": {
        "token": "2ADM4RSDH4ZTXZTS56R6JSVUP4",
        "expiry": "2022-07-07T04:37:57.933289Z"
    }
}
```

O valor de `2ADM4RSDH4ZTXZTS56R6JSVUP4` deve ser utilizado no header de **`Authorization: Bearer 2ADM4RSDH4ZTXZTS56R6JSVUP4`** nas rotas que necessitem de autenticação (CRUD filmes).

#### CRUD filmes

Agora que você já tem o token necessário para se autenticar e autorizar o acesso ao CRUD de filme, é só utilizar essa valor no header de `Authorization`, com o valor de `Bearer <TOKEN>`.

*Obs: para visualizar o payload, URL e reponses adicionais do CRUD de filmes, veja a documentação do swagger, copiando o conteúdo do arquivo OpenAPI-Greenlight.yaml e colando em https://editor.swagger.io*
