return {
    env = 'dev', -- dev/prod
    domain = 'api-ngx-admin.dev',
    host = '127.0.0.1',
    port = 3306,
    db_name = 'hack',
    user = 'root',
    password = 'root',
    db_timeout = 10000,
    pool_timeout = 10000,
    pool_size = 10000,
    session_lifetime = 720, --minutes
    login_id = 'email' -- login method use email/username/phone...etc
}
