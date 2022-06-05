## DynDNS Container via/for GoDaddy DNS AA/IPv4 entry

This container is used to update the DNS AA entry of a given GoDaddy domain with its own IPv4 address periodically (default every 5min).    
Just like a normal DynDNS service would do.

The own IPv4 address is requested from external services `ipify.org` and `whatsmyipaddress.com`.   
Both must return the same IPv4 address or else updating the DNS entry will fail due to security concerns (hijack of one of service etc).

The effect might not be immediate as the DNS servers must update the DNS entry (see TTL of DNS entry)

### Usage
- Start by building the docker image with `docker-compose build`
- Then you need to configure by editing files inside `./configure/*`
- After that you can run the container with `docker-compose up -d`

### Notes:
The domains TTL best is set to a low value (like 600 = 10 minutes)

You need api keys to be able to update the domain.     
Can be retrieved from here: `https://developer.godaddy.com/`

If running with `docker run` and not via the `docker-compose` comamnd, make sure to add the option `--init`,
or else container can only be killed and not stopped as `sh` doesnt send the signals further to its children processes.
