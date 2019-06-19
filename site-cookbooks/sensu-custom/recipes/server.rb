include_recipe 'sensu-custom::default'

sensu_backend 'default' do
  action %i[install init]

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
    'subscriptions': %w[linux]
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

sensu_entity 'example-entity' do
  subscriptions ['example-entity']
  entity_class 'proxy'
  labels(environment: 'production', region: 'us-west-2')
  annotations(runbook: 'https://www.xkcd.com/378/')
end

sensu_check 'disk' do
  command 'check-disk-usage.rb -t xfs -w 95 -c 99'
  interval 60
  subscriptions %w[linux]
  handlers %w[slack tcp_handler udp_handler]
  handlers %w[pagerduty splunk]
  publish true
  ttl 100
  runtime_assets %w[sensu-ruby-runtime sensu-plugins-disk-checks]
  action :create
end