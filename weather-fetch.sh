#!/bin/sh

# Prepare ------------------------------------------------------------------------------------------

main_color=$(tput setaf 2)
yellow=$(tput setaf 3)
black=$(tput setaf 238)
ascii_colour=$(tput setaf 250)

data=$(curl -fsLS "https://wttr.in/$*?format=j1")

location=$(curl -fsLS "https://wttr.in/$*?format=%l")
description=$(echo "${data}" | jq --raw-output .weather[0].hourly[7].weatherDesc[0].value)
humidity=$(echo "${data}" | jq --raw-output .weather[0].hourly[7].humidity)
temperature=$(echo "${data}" | jq --raw-output .weather[0].hourly[7].tempC)
temperature_feels=$(echo "${data}" | jq --raw-output .weather[0].hourly[7].FeelsLikeC)
wind_speed=$(echo "${data}" | jq --raw-output .weather[0].hourly[7].windspeedKmph)
precipitation=$(echo "${data}" | jq --raw-output .weather[0].hourly[7].precipMM)
pressure=$(echo "${data}" | jq --raw-output .weather[0].hourly[7].pressure)

case "$(echo "${data}" | jq --raw-output .weather[0].hourly[7].winddir16Point)" in
	N)   wind_direction='↓' ;;
	NNE) wind_direction='↓' ;;
	NE)  wind_direction='↙' ;;
	ENE) wind_direction='↙' ;;
	E)   wind_direction='←' ;;
	ESE) wind_direction='←' ;;
	SE)  wind_direction='↖' ;;
	SSE) wind_direction='↖' ;;
	S)   wind_direction='↑' ;;
	SSW) wind_direction='↑' ;;
	SW)  wind_direction='↗' ;;
	WSW) wind_direction='↗' ;;
	W)   wind_direction='→' ;;
	WNW) wind_direction='→' ;;
	NW)  wind_direction='↘' ;;
	NNW) wind_direction='↘' ;;
esac

info="${black}${location}
----------------
${main_color}Description: ${description}
${black}Humidity: ${humidity}%
${main_color}Temperature:${temperature}(${temperature_feels})°C
${black}Wind: ${wind_direction} ${wind_speed}km/h
${black}Precipitation: ${precipitation}mm
${black}Pressure: ${pressure}hPa"${main_color}

case "${description}" in
'Cloudy'*) art_raw='
     .--.
  .-(    ).
 (___.__)__)
' ;;
'Fog'*) art_raw='
_ - _ - _ -
_ - _ - _
_ - _ - _ -
         ' ;;
'Heavy rain'*) art_raw='
   .-.
  (   )
 (___(__)
 ‚ʻ‚ʻ‚ʻ‚ʻ
‚ʻ‚ʻ‚ʻ‚ʻ ' ;;
'Heavy showers'*) art_raw='
    .-.
   (   )
  (___(__)
 ‚ʻ‚ʻ‚ʻ‚ʻ
‚ʻ‚ʻ‚ʻ‚ʻ ' ;;
'Heavy snow showers'*) art_raw='
   .-.
  (   )
 (___(__)
 * * * *
* * * *' ;;
'Heavy snow'*) art_raw='
    .-.
   (   ).
  (___(__)
  * * * *
 * * * *   ' ;;
'Patchy moderate snow'*) art_raw='
    .-.
   (   ).
  (___(__)
  * * * *
 * * * *               ' ;;
'Light rain'*) art_raw='
   .-.
  (   )
 (___(__)
 ʻ ʻ ʻ ʻ
ʻ ʻ ʻ ʻ  ' ;;
'Light showers'*) art_raw='
   .-.
  (   ).
 (___(__)
 ʻ ʻ ʻ ʻ
ʻ ʻ ʻ ʻ ' ;;
'Light sleet showers'*) art_raw='
   .-.
  (   ).
 (___(__)
  ʻ * ʻ *
 * ʻ * ʻ  ' ;;
'Light sleet'*) art_raw='
  .-.
 (   ).
(___(__)
  ʻ  ʻ *
 * ʻ * ʻ   ' ;;
'Light snow showers'*) art_raw='
  .-.
 (   ).
(___(__)
  *  *  *
 *  *  *  ' ;;
'Light snow'*) art_raw='
   .-.
  (   ).
 (___(__)
  *  *  *
  *  *  *   ' ;;
'Partly cloudy'*) art_raw='    
  .-.
 (   ).
(___(__)
             ' ;;
'Sunny'*) art_raw='
   .-.
‒ (   ) ‒
   `-᾿
  /   \    ' ;;
'Thundery heavy rain'*) art_raw='
   .-.
  (   ).
 (___(__)
  ‚ʻ⚡ʻ‚⚡‚ʻ
  ‚ʻ‚ʻ⚡ʻ‚ʻ ' ;;
'Thundery showers'*) art_raw='
	   .--.
  .-(    ).
(___.__)__)
, ⚡ , ⚡ ,
,  ,  ,  ,     ' ;;
'Thundery snow showers'*) art_raw='
   	.--.
 .-(    ).
(___.__)__)
  *⚡ *⚡ *
 *  *  *  ' ;;
'Very cloudy'*) art_raw='
    .--.
 .-(    ).
(___.__)__)
             ' ;;
*) art_raw='
  __)
(
  `-᾿
  •      ' ;;
esac

art=$(gum style --foreground 238 --border-foreground 238 --border double \
	--align center --width 20 --margin "1 2" --padding "2 4" \ "${art_raw}")


# Display ------------------------------------------------------------------------------------------

terminal_size=$(stty size)
terminal_height=${terminal_size% *}
terminal_width=${terminal_size#* }

prompt_height=${PROMPT_HEIGHT:-1}

print_test() {
	no_color=$(printf '%b' "${1}" | sed -e 's/\x1B\[[0-9;]*[JKmsu]//g')

	[ "$(printf '%s' "${no_color}" | wc --lines)" -gt $(( terminal_height - prompt_height )) ] && return 1
	[ "$(printf '%s' "${no_color}" | wc --max-line-length)" -gt "${terminal_width}" ] && return 1

	gum style --align center --width="${terminal_width}" "${1}" ''

	exit 0
}


# Landscape layout
print_test "$(gum join --horizontal --align center "${art}" '  ' "${info}")"

# Portrait layout
print_test "$(gum join --vertical --align center "${art}" '' "${info}")"

# Other layout
print_test "${info}"

exit 1
