include_recipe 'sensu-custom::default'

sensu_backend 'default' do
  action %i[install init]

  # distribution 'source'
  # repo ''
  # gpgkey ''

  config('state-dir': '/var/lib/sensu/sensu-backend')

  username 'admin'
  password 'P@ssw0rd!'

  debug true
end

sensu_agent 'default' do
  config(
    'name': node['hostname'],
    'namespace': 'default',
    'backend-url': ['ws://127.0.0.1:8081'],
    'subscriptions': %w[linux proxy]
  )
end

sensu_ctl 'default' do
  backend_url 'http://127.0.0.1:8080'

  username 'admin'
  password 'P@ssw0rd!'
  action %i[install configure]

  debug true
end

sensu_namespace 'victoria' do
  action :create
end

sensu_check 'cron' do
  command '/bin/true'
  cron '0 * * * *'
  subscriptions %w[dad_jokes production]
  handlers %w(slack tcp_handler udp_handler)
  labels(environment: 'production', region: 'us-west-2')
  annotations(runbook: 'https://www.xkcd.com/378/')
  publish true
  ttl 100
  high_flap_threshold 60
  low_flap_threshold 20
  subdue(days: { all: [{ begin: '12:00 AM', end: '11:59 PM' },
                       { begin: '11:00 PM', end: '1:00 AM' }] })
  runtime_assets  %w[sensu-ruby-runtime]
  action :create
end

assets = data_bag_item('sensu', 'assets')
assets.each do |name, property|
  next if name == 'id'

  sensu_asset name do
    url property['url']
    sha512 property['checksum']
  end
end

sensu_handler 'slack' do
  type 'pipe'
  command 'handler-slack --webhook-url https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX --channel monitoring'
end

sensu_handler 'tcp_handler' do
  type 'tcp'
  socket(
    host: '127.0.0.1',
    port: 4444
  )
  timeout 30
end

sensu_handler 'udp_handler' do
  type 'udp'
  socket(
    host: '127.0.0.1',
    port: 4444
  )
  timeout 30
end

sensu_handler 'notify_the_world' do
  type 'set'
  handlers %w(slack tcp_handler udp_handler)
end

sensu_filter 'production_filter' do
  filter_action 'allow'
  expressions [
    "event.Entity.Environment == 'production'",
  ]
end

sensu_filter 'development_filter' do
  filter_action 'deny'
  expressions [
    "event.Entity.Environment == 'production'",
  ]
end

sensu_filter 'state_change_only' do
  filter_action 'allow'
  expressions [
    'event.Check.Occurrences == 1',
  ]
end

sensu_filter 'filter_interval_60_hourly' do
  filter_action 'allow'
  expressions [
    'event.Check.Interval == 60',
    'event.Check.Occurrences == 1 || event.Check.Occurrences % 60 == 0',
  ]
end

sensu_filter 'nine_to_fiver' do
  filter_action 'allow'
  expressions [
    'weekday(event.Timestamp) >= 1 && weekday(event.Timestamp) <= 5',
    'hour(event.Timestamp) >= 9 && hour(event.Timestamp) <= 17',
  ]
end

sensu_mutator 'example-mutator' do
  command 'example_mutator.rb'
  timeout 60
end

# sensu_entity 'proxy' do
#   subscriptions ['proxy']
#   entity_class 'proxy'
#   labels(environment: 'production', region: 'us-west-2')
#   annotations(runbook: 'https://www.xkcd.com/378/')
# end

sensu_entity 'packagecloud-site' do
  # subscriptions ['proxy']
  entity_class 'proxy'
  labels(
    proxy_type: 'website',
    url: 'https://packagecloud.io'
  )
  annotations(
    runbook: 'https://www.xkcd.com/378/'
  )
end

sensu_hook 'df_h' do
  command 'df -hx /'
  timeout 60
  stdin false
end

sensu_check 'disk' do
  command 'check-disk-usage.rb -t ext4 -w 3 -c 4'
  interval 60
  subscriptions %w[linux]
  handlers %w[slack tcp_handler udp_handler]
  publish true
  ttl 100
  runtime_assets %w[sensu-ruby-runtime sensu-plugins-disk-checks]
  action :create

  check_hooks(
    [
      {
        "warning": [
          'df_h'
        ]
      }
    ]
  )
end

sensu_check 'sensu_site' do
  command 'check-http.rb -u https://sensu.io'
  interval 60
  subscriptions %w[proxy]
  handlers %w[slack tcp_handler udp_handler]
  publish true
  round_robin true
  ttl 100
  runtime_assets %w[sensu-ruby-runtime sensu-plugins-http]
  action :create
end

sensu_check 'website_entities_http' do
  command 'check-http.rb -u {{ .labels.url }}'
  interval 60
  subscriptions %w[proxy]
  handlers %w[slack tcp_handler udp_handler]
  publish true
  round_robin true
  ttl 100
  proxy_requests(
    {
      'entity_attributes' => [
        "entity.entity_class == 'proxy'",
        "entity.labels.proxy_type == 'website'"
      ]
    }
  )
  runtime_assets %w[sensu-ruby-runtime sensu-plugins-http]
  action :create
end
