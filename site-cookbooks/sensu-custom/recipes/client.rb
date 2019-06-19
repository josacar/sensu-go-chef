include_recipe 'sensu-custom::default'

sensu_agent 'default' do
  config(
    'name': node['hostname'],
    'namespace': 'default',
    # 'backend-url': ['ws://127.0.0.1:8081'],
    'backend-url': ['ws://192.168.5.2:8081'],
    'subscriptions': %w[linux]
  )
end
