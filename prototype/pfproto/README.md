TO test/develop app code inside docker container but not using docker compose:

```bash
docker build -t pfproto-image .
docker run -e PF_KEY="some_key" -p 8781:8787 -dv `pwd`:/root/pfproto pfproto-image
```
