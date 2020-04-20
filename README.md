# Info

Spins two Vagrant instances one with a sensu-backend and one with sensu-agent only.

Ports used in server:

3000 - Sensu web UI
8080 - Sensu API used by sensuctl, some plugins, and any of your custom tooling
8081 - WebSocket API used by Sensu agents


## Docs

https://docs.sensu.io/sensu-go/latest/installation/install-sensu/
https://docs.sensu.io/sensu-go/latest/reference/agent/#communication-between-the-agent-and-backend
https://docs.sensu.io/sensu-go/latest/guides/monitor-server-resources/
https://docs.sensu.io/sensu-go/latest/guides/monitor-external-resources/
https://docs.sensu.io/sensu-go/latest/guides/install-check-executables-with-assets/
https://docs.sensu.io/sensu-go/latest/installation/plugins/#use-bonsai-the-sensu-asset-index
https://docs.sensu.io/sensu-go/latest/guides/deploying/

https://bonsai.sensu.io/

https://github.com/sensu/sensu-go-chef
https://github.com/sensu/sensu-go-chef/blob/master/test/cookbooks/sensu_test/recipes/default.rb
