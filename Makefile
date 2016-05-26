build:
	# Build a container the same release as the host.
	echo "Build hash is $(shell git rev-parse HEAD)" > build_output.txt
	./build.sh 2>&1 | tee -a build_output.txt

trusty:
	echo "Building trusty $(shell git rev-parse HEAD)" > build_output.txt
	./build.sh trusty 2>&1 | tee -a build_output.txt

xenial:
	echo "Building xenial $(shell git rev-parse HEAD)" > build_output.txt
	./build.sh xenial 2>&1 | tee -a build_output.txt

publish:
	lxc stop charm-container || true
	# This publishes to your own local lxd system.
	lxc publish --public charm-container --alias=${USER}-charm-container

bash:
	lxc start charm-container || true
	# Get a bash shell on this system and run as the ubuntu user.
	lxc exec charm-container -- /bin/bash -c 'cd /home/ubuntu/ && su ubuntu'

clean:
	./clean.sh
