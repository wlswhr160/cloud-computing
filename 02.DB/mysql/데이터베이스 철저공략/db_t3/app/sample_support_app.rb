# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'eventmachine'
require 'warden'
require 'mysql'
require 'mail'
require 'mail-iso-2022-jp'
require 'pp'

enable :sessions

configure do
  set :db_host, '127.0.0.1'
  set :db_port, 3306
  set :db_user, 'msandbox'
  set :db_password, 'msandbox'
  set :db_dbname, 'sample'
  set :db_retry_count, 3
  set :db_retry_delay, 3
end

def sendmail(to_, subject_, body_)
  mail = Mail.new(:charset => 'EUC-KR') do
    from    'admin@example.com'
    to      to_
    subject subject_
    body    body_
  end

  mail.delivery_method :smtp, {
    :address => "SMTP서버 주소",
    :port => 465,
    :domain => "localhost.localdomain",
    :user_name => "유저명",
    :password => "패스워드",
    :authentication => "plain",
    :openssl_verify_mode => "none",
    :ssl => true
  }

  mail.deliver!
end


Warden::Manager.serialize_from_session do |user|
  user
end

Warden::Manager.serialize_into_session do |user|
  user
end

Warden::Strategies.add :login_test do
  def valid?
    # No password check, because this is a sample program.
    # Must implement it.
    params['email']
  end

  def authenticate!
    if params['email']
      begin
        my = Mysql::new(settings.db_host,
                        settings.db_user,
                        settings.db_password,
                        settings.db_dbname,
                        settings.db_port)
        st = my.prepare(<<SQL)
SELECT
    user_id,
    user_name,
    customer_id IS NOT NULL AS c,
    engineer_id IS NOT NULL AS e
FROM
    users
    LEFT JOIN customers ON user_id = customer_id
    LEFT JOIN engineers ON user_id = engineer_id
WHERE
    email = ?
SQL
        st.execute(params['email'])
        row = st.fetch_hash        
        role = case
               when params['email'] == 'admin'
                 row = {'user_id' => 0}
                 :admin
               when row['c'] == 1
                 :customer_role
               when row['e'] == 1
                 :engineer_role
               else
                 nil
               end
        unless role.nil?
          return success!({
                            :email => params['email'],
                            :role => role,
                            :id => row['user_id'],
                          })
        end
      ensure
        st.close if st
        my.close if my
      end
    end
    fail!('Login failed')
  end
end


use Warden::Manager do |manager|
  manager.default_strategies :login_test
  manager.failure_app = Sinatra::Application
end

before do
  if request.env["warden"].user.nil? and
      request.path != '/' and
      request.path != '/login'
    redirect '/'
  end
end


get '/' do
  user = request.env['warden'].user
  case
  when user.nil?
    redirect '/login'
  when user[:role] == :admin
    erb :top_admin
  when user[:role] == :customer_role
    erb :top_customer
  when user[:role] == :engineer_role
    # Need to implement
    erb :top_engineer
  else
    # something is wrong
    halt
  end
end

get '/login' do
  erb :login
end

post '/login' do
  request.env['warden'].authenticate!
  redirect '/'
end

post '/unauthenticated' do
  erb :fail_login
end

get '/logout' do
  request.env['warden'].logout
  redirect '/'
end

def check_error
  [[:company, (1..100)],
   [:fullname, (1..32)],
   [:email, (3..256)]].
    inject([]) do |e, v|
    instance_variable_set('@' + v[0].to_s, params[v[0]])
    unless v[1].include?(params[v[0]].size)
      e << v[0]
    end
    e
  end
end

get '/customer/register' do
  erb 'customer/register'.to_sym
end

post '/customer/confirm' do
  err_info = check_error

  if err_info.size == 0
    erb 'customer/confirm'.to_sym
  else
    @message = '입력값이 잘못 되었습니다.'
    erb :error_back
  end
end

post '/customer/confirmed' do
  if check_error.size != 0
    halt 403
  end

  begin
    my = Mysql::new(settings.db_host,
                    settings.db_user,
                    settings.db_password,
                    settings.db_dbname,
                    settings.db_port)
    my.autocommit(false)
    st = my.prepare('INSERT INTO users (user_name, email) VALUES(?, ?)')
    st.execute(@fullname, @email)
    st = my.prepare('INSERT INTO customers (customer_id, company_name) VALUES(LAST_INSERT_ID(), ?)')
    st.execute(@company)
    my.commit
  rescue
    halt 500
  ensure
    st.close if st
    my.close if my
  end
  erb '/customer/registered'.to_sym
end

get '/customer/list' do
  redirect '/customer/list/0/10'
end

get '/customer/list/:offset/:num' do
  begin
    @offset = params[:offset].to_i
    @num = params[:num].to_i

    my = Mysql::new(settings.db_host,
                    settings.db_user,
                    settings.db_password,
                    settings.db_dbname,
                    settings.db_port)

    st = my.prepare(<<SQL)
SELECT
    user_id,
    company_name,
    user_name,
    email
FROM
    users
    JOIN customers
    ON user_id = customer_id
ORDER BY
    customer_id
LIMIT ?,?
SQL
    st.execute(@offset, @num)
    @results = Array.new
    while row=st.fetch do
      @results << row
    end
  rescue
    halt 500
  ensure
    st.close if st
    my.close if my
  end
  erb '/customer/list'.to_sym
end

get '/customer/show/:customer_id' do
  @customer_id = params[:customer_id]
  begin
    my = Mysql::new(settings.db_host,
                    settings.db_user,
                    settings.db_password,
                    settings.db_dbname,
                    settings.db_port)
    st = my.prepare(<<SQL)
SELECT
    customer_name,
    customer_email,
    company_name
FROM
    customers
WHERE
    customer_id = ?
SQL
    st.execute(@customer_id)
    @info = st.fetch_hash
  rescue
    halt 500
  ensure
    st.close if st
    my.close if my
  end
  erb '/customer/show'.to_sym
end

get '/service/new' do
  erb '/service/new'.to_sym
end

def check_new_service
  [[:product, (1..100)],
   [:title, (1..255)]].
    inject([]) do |e, v|
    instance_variable_set('@' + v[0].to_s, params[v[0]])
    unless v[1].include?(params[v[0]].size)
      e << v[0]
    end
    e
  end
end

post '/service/new' do
  err_info = check_new_service

  if err_info.size == 0
    user = request.env['warden'].user
    @product = params[:product]
    @title = params[:title]

    retry_count = settings.db_retry_count
    while retry_count > 0
      begin
        my = Mysql::new(settings.db_host,
                        settings.db_user,
                        settings.db_password,
                        settings.db_dbname,
                        settings.db_port)
        my.autocommit(false)
        st = my.prepare(<<SQL)
INSERT INTO service_requests
(customer_id, engineer_id, product_name, request_summary, status)
VALUES(?,0,?,?,'Open')
SQL
        st.execute(user[:id], @product, @title)
        EM.defer do
          sendmail(user[:email], '공지', '새로운 서비스 리퀘스트가 작성되었습니다.')
        end
        my.commit

        return erb 'service/created'.to_sym
      rescue =>e
        pp e
        pp e.backtrace
        retry_count -= 1
        sleep(settings.db_retry_delay)
      ensure
        st.close if st
        my.close if my
      end
    end
  end
  @message = '입력값이 잘못 되었습니다.'
  erb :error_back
end
