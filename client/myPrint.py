import time

import telnetlib
from reprint import output

def getHealthBar(name, currentHP):

	hashes = '#' * currentHP
	dashes = '-' * (100 - currentHP)
	return "{0: <12}: {1}{2}".format(name, hashes, dashes)

def mainLoop(host, port):

	with output(output_type = "list") as outStream:

		telnet = telnetlib.Telnet()
		telnet.open(host, port)

		while(True):

			command = "b status\n".encode('ascii')
			telnet.write(command)

			breaker = '>'.encode('ascii')

			outStuff = telnet.read_until(breaker, 1).decode('ascii')
			statusLines = outStuff.strip().split('\n')

			statusMap = {}
			for line in statusLines:
				if (line == ">"): break
				statusMap.update({line.split(':')[0] : line.split(':')[1]})

			outList = []

			for key, value in statusMap.items():
				outList.append(getHealthBar(key, int(value)))

			outStream.change(outList)

			time.sleep(0.5)

		telnet.close()

if (__name__ == "__main__"):
	mainLoop("127.0.0.1".encode('ascii'), 6666)
