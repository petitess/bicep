targetScope = 'subscription'

param config object
param environment string
param timestamp string = utcNow('yyyyMM')
param location string = deployment().location

var prefix = toLower('${config.product}-hub-${environment}-${config.location}')

func giveMeNumber() int => int(take(replace(replace(replace(replace(replace(replace(replace(subscription().subscriptionId, 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', ''), '-', ''), 4))

func giveMeNumber2() int => int(take(replace(replace(replace(replace(replace(replace(replace(subscription().subscriptionId, 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', ''), '-', ''), 4)) < 65000 ? int(take(replace(replace(replace(replace(replace(replace(replace(subscription().subscriptionId, 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', ''), '-', ''), 5)) : int(take(replace(replace(replace(replace(replace(replace(replace(subscription().subscriptionId, 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', ''), '-', ''), 4))

func giveMeNumber3() int => int(replace(replace(replace(replace(replace(replace(replace(subscription().subscriptionId, 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', ''), '-', ''))

func giveMeNumber4() string => replace(replace(replace(replace(replace(replace(replace(subscription().subscriptionId, 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', ''), '-', '')

output number int = giveMeNumber()
output number2 int = giveMeNumber2()
output orginal int = int(take(replace(replace(replace(replace(replace(replace(replace(subscription().subscriptionId, 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', ''), '-', ''), 4))
output orginal2 int = int(giveMeNumber4()) > 65000 ? int(take(giveMeNumber4(), 4)) : int(take(giveMeNumber4(), 5))

output compare bool = 65000 > 355 ? true : false

func buildUrl(https bool, hostname string, path string) string => '${https ? 'https' : 'http'}://${hostname}${empty(path) ? '' : '/${path}'}'

output foo string = buildUrl(true, 'google.com', 'search')

func sayHello(name string) string => 'Hi ${name}!'

output hellos array = map([ 'Evie', 'Casper' ], name => sayHello(name))

func objReturnType(name string) object => {
  hello: 'Hi ${name}!'
}

output objReturnType object = objReturnType('karol')

func arrayReturnType(name string) array => [
  name
]

output arrayReturnType array = arrayReturnType('karol')

func asdf(name string) array => [
  'asdf'
  name
]

var name = 'stplatformmonitorprod01'
var add = 'NEW'

@description('Inserts prefix before last two charcters')
func insertPrefix(name string, prefix string) string =>
  '${substring(name, 0, length(name) - 2)}${prefix}${substring(name, length(name) - 2, 2)}'

@description('Generate guid value for password')
func generatePass(x string, y string) string =>
  replace('M${toUpper(substring(guid(x, y), 0, 15))}${substring(guid(x, y), 15, 21)}z', '-', '!')
