#! /bin/sh

secretcheck()
{
	if ! . /run/secrets/secrets; then
		return 1
	fi

	unset err

	if [ -z "${gd_apikey}" ]; then
		echo "Error: GoDaddy Api key is empty" >&2
		err=1
	fi

	if [ -z "${gd_apisecret}" ]; then
		echo "Error: GoDaddy Api secret is empty" >&2
		err=1
	fi

	if [ -n "${err}" ]; then
		return 1
	fi
}

getdnsdata()
{
	. /run/secrets/secrets
	json="$(curl -m 20 -s -X GET -H "Authorization: sso-key ${gd_apikey}:${gd_apisecret}" "https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/${HOSTNAME}")"
	if [ "${?}" -ne "0" ]; then
		echo "Error: GoDaddy DNS fetch failed" >&2
		return 1
	fi
}

changeip()
{
	if ! curl -m 20 -s -X PUT "https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/${HOSTNAME}" -H "Authorization: sso-key ${gd_apikey}:${gd_apisecret}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"; then
		echo "Error: failed to update ip to GoDaddy" >&2
		return 1
	fi
}

checkifchanged()
{
	if [ "${myip}" != "${gdip}" ]; then
		echo "Ip has changed: ${gdip} => ${myip}"
		if changeip; then
			echo "DNS entry updated, visible in $(( $(echo "${json}" | jq -r ".[0].ttl") / 60 )) minutes" 
		fi
	else
		return 1
	fi
}

main()
{
	myip="${1}"

	if ! secretcheck; then
		return 1
	fi

	if ! getdnsdata; then
		return 1
	fi


	gdip="$(echo "${json}" | jq -r ".[0].data")"

	if ! checkip "${gdip}"; then
		echo "Error: GoDaddy ip invalid: ${gdip}" >&2
		return 1
	fi

	if ! checkifchanged; then
		echo "No ip change: ${myip}"
	fi
}

ip="${1}"

main "${ip}"
return "${?}"
