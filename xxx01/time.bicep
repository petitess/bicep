param u string = utcNow('d')

output a string = u
output b string = dateTimeAdd(u, 'P1D', 'd') 
output c string = '${dateTimeAdd(u, 'P1D', 'd')} 08:30:00'
