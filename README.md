# docker-unrealircd4
Most things lend from Erik Osterman's repository, modified for unrealircd 4

# build
docker build -t unrealircd4 .
docker tag unrealircd4 metabool/unrealircd4:1.0
docker push metabool/unrealircd4:1.0


# cloning failed container and look in it:
docker commit <container_id> my-broken-container
docker run -it my-broken-container /bin/bash
