all: clean build run

clean:
	docker stop pfproto-container; docker rm pfproto-container; docker rmi -f pfproto-image

build:
	docker build -t pfproto-image .

run:
	chmod +x inst/cron/daily-download.sh
	docker run -dv `pwd`:/root/pfproto --name pfproto-container pfproto-image
