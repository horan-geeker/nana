return {
    env = 'dev', -- dev/prod
    host = '127.0.0.1', -- mysql host
    port = 3306, -- mysql port
    db_name = 'nana', -- mysql database name
    user = 'root', -- mysql user
    password = 'root', -- mysql password
    db_timeout = 10000, -- mysql timeout
    pool_timeout = 10000, -- mysql pool timeout
    pool_size = 10000, -- mysql pool size
    redis_host = '172.17.0.5', -- redis host
    redis_port = 6379, -- redis port
    session_lifetime = 3600 * 24 * 356, --sec one year
    max_request_per_second = 3000, -- throttle flow request per second
    user_table_name = 'users',
    login_id = 'phone', -- login method use email/username/phone...etc
    time_zone = 'UTC+8',
    app_directory = '/var/www/nana/',
    ip_binary_file_path = '/var/www/nana/lib/17monipdb.dat',
    app_url = 'www.lua-china.com',
    phone_code_len = 4
}
