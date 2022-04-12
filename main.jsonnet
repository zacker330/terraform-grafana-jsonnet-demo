local secrets = import 'secrets.libsonnet';
{
  terraform: {
    required_providers: {
      postgresql: {
        source: 'cyrilgdn/postgresql',
        version: '1.15.0',
      },
      grafana: {
        // url: 'http://127.0.0.1:3000',
        // // https://registry.terraform.io/providers/grafana/grafana/latest/docs#auth
        // auth: 'eyJrIjoiOU1neGhsZDM4aFVEU1dVQjBWN0IxZXM5eW5BdEsxNlAiLCJuIjoiYWRtaW4iLCJpZCI6MX0=',
        source: 'grafana/grafana',
        version: '1.21.1',
      },
    },
    backend: {
      pg: {
        conn_str: 'postgres://postgres:postgres@127.0.0.1:5432/grafana_terraform_backend?sslmode=disable',
      },
    },
  },
  provider: {
    postgresql: {
      host: '127.0.0.1',
      port: 5432,
      database: 'postgres',
      username: secrets.postgresql.auth.username,
      password: secrets.postgresql.auth.password,
      sslmode: 'disable',
      connect_timeout: 15,
    },
    grafana: {
      url: 'http://127.0.0.1:3000',
      // // https://registry.terraform.io/providers/grafana/grafana/latest/docs#auth
      auth: 'eyJrIjoiOU1neGhsZDM4aFVEU1dVQjBWN0IxZXM5eW5BdEsxNlAiLCJuIjoiYWRtaW4iLCJpZCI6MX0=',
    },
  },
  resource: {
    grafana_data_source: {
      prometheus: {
        type: 'prometheus',
        name: 'amp',
        url: 'https://aps-workspaces.eu-west-1.amazonaws.com/workspaces/ws-1234567890/',
        json_data: {
          http_method: 'POST',
          sigv4_auth: true,
          sigv4_auth_type: 'default',
          sigv4_region: 'eu-west-1',
        },
      },
    },
    // postgresql
    postgresql_role: {
      app_www: {
        name: 'app_www',
      },
      app_db: {
        name: 'app_db',
      },
      app_releng: {
        name: 'app_releng',
      },
    },
    postgresql_database: {
      my_db: {
        name: 'my_db',
        allow_connections: true,
      },
    },
    postgresql_schema: {
      my_schema: {
        name: 'my_schema',
        owner: 'postgres',
        policy: [
          {
            usage: true,
            role: '${postgresql_role.app_www.name}',
          },
          {
            create: true,
            usage: true,
            role: '${postgresql_role.app_releng.name}',
          },
          {
            create_with_grant: true,
            usage_with_grant: true,
            role: '${postgresql_role.app_db.name}',
          },
        ],
      },
    },
  },
}
