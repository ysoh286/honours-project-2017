##simple boxplot challenge:

setwd('~/Dropbox/iNZight/iNZightPlots')
devtools::load_all()

income <- read.csv('~/Desktop/datasets/nzincome.csv', header = TRUE)

income100 <- income[1:100, ]

x <- iNZightPlot(weekly_hrs, data = income100, colby = sex)
gridSVG::grid.script(filename = "boxplot-challenge.js", inline = TRUE, name = "script")
gridSVG::grid.export("boxplot.svg")
