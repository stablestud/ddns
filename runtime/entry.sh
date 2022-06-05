#! /bin/sh

scriptdir="$(cd "$(dirname "${0}")" && pwd)"

echo "DynDNS container started @ $(date)"
echo "Will update ${HOSTNAME} at ${DOMAIN} every ${FREQUENCY}"

envcheck()
{
	unset err
	if [ -z "${FREQUENCY}" ]; then
		echo "Error: FREQUENCY not set" >&2
		err=1
	fi

	if [ -z "${DOMAIN}" ]; then
		echo "Error: DOMAIN not set" >&2
		err=1
	fi

	if [ -z "${HOSTNAME}" ]; then
		echo "Error: HOSTNAME not set" >&2
		err=1
	fi

	if [ -n "$err" ]; then
		return 1
	fi
}

getmyip()
{
	unset err

	myip1_source="ipify.org"
	myip1="$(curl -s "https://api.ipify.org")"

	if [ "${?}" -ne "0" ]; then
		echo "Error: failed to fetch from ${myip1_source}"
		err=1
	elif ! checkip "${myip1}"; then
		echo "Error: '${myip1}' from '${myip1_source}' is not a valid ip"
		err=1
	fi

	myip2_source="whatsmyipaddress.com"
	myip2="$(curl -s "https://ipv4bot.whatismyipaddress.com")"

	if [ "${?}" -ne "0" ]; then
		echo "Error: failed to fetch from ${myip2_source}"
		err=1
	elif ! checkip "${myip2}"; then
		echo "Error: '${myip2}' from '${myip2_source}' is not a valid ip"
		err=1
	fi

	if [ -n "${err}" ]; then
		return 1
	fi

	if [ "${myip1}" != "${myip2}" ]; then
		{
			echo "Error: ip checks returned different values:"
			echo "${myip1_source}: ${myip1}" 
			echo "${myip2_source}: ${myip2}" 
		} >&2
		return 1
	fi

	myip="${myip1}"
}

loop()
{
	echo "DynDNS started @ $(date)"

	if getmyip; then
		"${scriptdir}/godaddy.sh" "${myip}"
	fi

	sleep "${FREQUENCY}"
}

if ! envcheck; then
	return 1
fi

loop

return "${?}"
