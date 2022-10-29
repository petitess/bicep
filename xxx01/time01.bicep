@description('Date dd/mm/yyyy')
param basedate string = utcNow('d')
@description('Date MM/dd/yyyy HH:mm:ss')
param basedate2 string = utcNow('MM/dd/yyyy HH:mm:ss')
@description('W. Europe Standard Time')
param basetime string = dateTimeAdd(utcNow(), 'PT2H', 't') 
//Add a minute to base time
param basetime string = dateTimeAdd(utcNow(), 'PT1M', 'yyyy-MM-ddTHH:mm:ss') 
//Add a month to base time
param basetime string = dateTimeAdd(utcNow(), 'P1M', 'yyyy-MM-ddTHH:mm:ss') 
//Add a day to base time
param basetime string = dateTimeAdd(utcNow(), 'P1D', 'yyyy-MM-ddTHH:mm:ss') 

output a string = basedate
output b string = basetime
output c string = dateTimeAdd(basedate, 'P1D', 'd') 
output d string = '${dateTimeAdd(basedate, 'P1D', 'd')} 08:30:00'
output e string = basetime >= '08:35' ? '${dateTimeAdd(basedate, 'P1D', 'd')} 08:30:00' : '${basedate} 08:30:00'

//https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
