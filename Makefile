update-config:
	docker-compose exec solr1 ./bin/solr zk -z zoo1:2181 upconfig -n $(CONFIG) -d /opt/solr/server/solr/configsets/$(CONFIG)/conf/;

.PHONY: create
create:
	docker-compose exec solr1 ./bin/solr create_collection -c $(NAME) -n $(CONFIG) -s $(SHARDS) -rf $(REPLICAS)

.PHONY: delete
delete:
	docker-compose exec solr1 ./bin/solr delete -c $(NAME)

.PHONY: create-alias
create-alias:
	curl -s "http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=$(ALIAS)&collections=$(NAME)"

.PHONY: build
build:
	bash ./build.sh $(CONFIG)
