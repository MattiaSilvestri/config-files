#!/bin/bash

api_key=3b8ecfac33b8f7d6378fe8a498792d5a
city_id=6539916
url="api.openweathermap.org/data/2.5/weather?id=${city_id}&appid=${api_key}"
curl ${url} -s -o ~/.cache/eleg-weather.json
