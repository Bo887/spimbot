default:
	QtSpimbot -file spimbot.s

debug:
	QtSpimbot -debug -file spimbot.s -file2 spimbot.s

tournament:
	QtSpimbot -tournament -file spimbot.s -file2 spimbot.s

seed-233:
	QtSpimbot -file spimbot.s -file2 spimbot.s -mapseed 233

seed-1:
	QtSpimbot -file spimbot.s -file2 spimbot.s -mapseed 1

seed-8:
	QtSpimbot -file spimbot.s -file2 spimbot.s -mapseed 8

seed-16:
	QtSpimbot -file spimbot.s -file2 spimbot.s -mapseed 16
