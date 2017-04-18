## iPlots: http://rosuda.org/software/iPlots/

## Reliant on JGR (run Java behind it??) - install Java if needed.
install.packages('iplots', dep = TRUE)
install.packages('JGR')

## launch JGR to use this: (it's like another interface that runs R)
library(JGR)
JGR()
## you could try running it from R, but it won't work.

## should take you to new console (that runs R inside)

## load data in:
income <-read.csv('datasets/nzincome.csv', header = TRUE)

## just running through a tutorial from iPlots:

## bar plots:
attach(income)

ibar(ethnicity) # you can click on it, and it highlights the bar.

ibar(ethnicity, isSpine = T)

## parallel co-ordinate plot?
ipcp(income) # an interesting looking plot?

## box plot?
ibox(weekly_hrs)
ibox(weekly_hrs, sex) ## split between male and female

##scatter plots?
iplot(weekly_hrs, weekly_income)

##adding loess smoother?
l <- lowess(weekly_hrs, weekly_income)
ilines(l, col = "red", fill = "red", visible = TRUE)

## removes the line (object):
iobj.rm()

l <- lowess(weekly_hrs, weekly_income, f = 0.5)
ilines(l)

## setting colors and attributes?
iplot.opt(ptDiam = 2.5, col = unclass(sex)) ## colby sex.

## histogram:
ihist(weekly_hrs)
##specify binwidth, anchors?
iplot.opt(anchor = 25, binw = 25) #anchor sets mid/break values, binwidth = width of breaks.

## return what you've selected back into R:
iset.selected() ## states which points are in that group.

## calculating proportions?
length(iset.selected())/nrow(income) ##length(income) returns the no. of variables!

##what if you wish to find a selection on the graph:
iset.select(weekly_hrs > 50)

## complex selections - select data in XOR mode?? Not sure what that is.

## brushing capabilities:
iplot.opt(col = unclass(sex))
iplot.opt(col = unclass(ethnicity)) 
## this is pretty cool - you can actually have more than 1 plot going on, but apply it just by 
# one line of code, and it LINKS automatically.

## objects? - annotate plots with more graphical elements.
## this is looking somewhat similar to what you can do in base plots?
iplot(weekly_hrs, weekly_income)
## outliers?
subs <- iset.selected() ## selected points stored into 'subs'
iabline(lm(weekly_income~weekly_hrs, subset = subs))  ## draw linear regression line with selected points.

iobj.cur() #returns current plot polygon?
iobj.get() # get the object based upon its ID?
#lots of other functions that are looking pretty similar to
# the grid package and grid objects
iobj.list() #returns no. of plots present.
iplot.off() #similar to dev.off() except goes for each plot.

#use of keyboard shortcuts and modifier keys 'to achieve a flat learning curve'
# Crtl-R - rotates plots, Shift-select = XOR mode, Ctrl-mouse over = return object label
#isets(), iplots(), iobjs().
#use arrow keys to increase/reduce transparency.


## remember to detach the dataset after use
detach(income)

## ------------------------ CHALLENGES ----------------------

## I've left some of the challenges that use iPlots in this file here,
## since iPlots runs on a different 'interface' JGR.

## ------------------ TRENDLINE CHALLENGE -------------------
## TODO: trendline challenge.

## ---------------- ARRAY OF PLOTS CHALLENGE ----------------

## using the iris data set to create scatter plot matrix:
attach(iris)
## since there's no facetting function/ need to construct from scratch?

# Sepal Width:
sw1 <- iplot(Sepal.Width, Sepal.Width)
sw2 <- iplot(Sepal.Width, Sepal.Length)
sw3 <- iplot(Sepal.Width, Petal.Width)
sw4 <- iplot(Sepal.Width, Petal.Length)

#Sepal Length;
sl1 <- iplot(Sepal.Length, Sepal.Width)
sl2 <- iplot(Sepal.Length, Sepal.Length)
sl3 <- iplot(Sepal.Length, Petal.Width)
sl4 <- iplot(Sepal.Length, Petal.Length)

#Petal Width:
pw1 <- iplot(Petal.Width, Sepal.Width)
pw2 <- iplot(Petal.Width, Sepal.Length)
pw3 <- iplot(Petal.Width, Petal.Width)
pw4 <- iplot(Petal.Width, Petal.Length)

#Petal Length:
pl1 <- iplot(Petal.Length, Sepal.Width)
pl2 <- iplot(Petal.Length, Sepal.Length)
pl3 <- iplot(Petal.Length, Petal.Width)
pl4 <- iplot(Petal.Length, Petal.Length)

## Add some colors to identify species: This should apply to all existing plots.
iplot.opt(col = unclass(Species))

## now you can do your linked brushing, and zoom in easily and it should apply to all
## existing present plots..
