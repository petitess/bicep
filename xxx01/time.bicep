param u string = utcNow('d')
param x string = utcNow('t')

output a string = u
output b string = dateTimeAdd(u, 'P1D', 'd') 
output c string = '${dateTimeAdd(u, 'P1D', 'd')} 08:30:00'
output d string = x
output e string = x >= '08:35' ? '${dateTimeAdd(u, 'P1D', 'd')} 08:30:00' : '${u} 08:30:00'
