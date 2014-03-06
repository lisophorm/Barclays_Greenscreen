ping localhost -n 2 > nul
taskkill /IM iexplore.exe /t /f
ping localhost -n 2 > nul
taskkill /IM m2sysplugin.exe /t
start iexplore.exe -new "http://192.168.0.150/bio/identify.html"
ping localhost -n 2 > nul
start iexplore.exe -new "http://192.168.0.150/bio/register.html"
ping localhost -n 2 > nul