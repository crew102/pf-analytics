all: down build-pfproto up

down:
	- docker-compose down # leading `-` allows error
	
build-pfproto:
	docker-compose build --no-cache pfproto
	
up:
	docker-compose up -d
	
build: 
	docker-compose build --no-cache
	
refresh: down build up