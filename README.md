# docker-unrealircd4
Most things lend from Erik Osterman's repository, modified for unrealircd 4

# build
docker build -t unrealircd4 .
docker tag unrealircd4 metabool/unrealircd4:1.0
docker push metabool/unrealircd4:1.0


# configure
mkdir -p /mnt/docker/unrealircd/
chown 1000:1000 /mnt/docker/unrealircd/
copy unrealircd.conf to /mnt/docker/unrealircd/
docker run --rm -v /mnt/docker/unrealircd:/usr/local/unrealircd/conf -p 6667:6667 metabool/unrealircd4

if everything works well, then:
docker run --restart unless-stopped --name unrealircd -d -v /mnt/docker/unrealircd:/usr/local/unrealircd/conf -p 6667:6667 -p 6697:6697 metabool/unrealircd4



# cloning failed container and look in it:
docker commit <container_id> my-broken-container
docker run -it my-broken-container /bin/bash
