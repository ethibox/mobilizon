init:
	@bash docker/message.sh "start"
	make start

start: stop
	@bash docker/message.sh "starting MobiliZon with docker"
	docker-compose up -d
	@bash docker/message.sh "started"
stop:
	@bash docker/message.sh "stopping MobiliZon"
	docker-compose down
	@bash docker/message.sh "stopped"
test: stop
	@bash docker/message.sh "Building front"
	docker-compose -f docker-compose.yml -f docker-compose.test.yml run front yarn run build
	@bash docker/message.sh "Front built"
	@bash docker/message.sh "Running tests"
	docker-compose -f docker-compose.yml -f docker-compose.test.yml run api mix test
	@bash docker/message.sh "Tests runned"

target: init
