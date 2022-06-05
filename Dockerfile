FROM alpine:latest as COMPILE

RUN set -x \
	&& apk add --no-cache g++ make git
RUN set -x \
	&& git clone "https://github.com/stablestud/trainee.git"
RUN set -x \
	&& make -C "trainee/C++/checkIpv4Address"


FROM alpine:latest

RUN set -x \
	&& apk update --no-cache \
	&& apk add --no-cache jq curl libstdc++

COPY "./runtime/*.sh" ./
COPY --from=COMPILE "trainee/C++/checkIpv4Address/bin/checkIpv4Address" "/usr/local/bin/checkip"

ENTRYPOINT [ "/entry.sh" ]
