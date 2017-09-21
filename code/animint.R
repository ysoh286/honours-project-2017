## trying animint: a package that creates animations and interactive graphics
# with ggplot2 - https://github.com/tdhock/animint
# NOTE: you must use ggplot2 2.1.0

# install:
devtools::install_github('tdhock/animint', force = TRUE)

library(animint)

# designer manual: http://members.cbio.mines-paristech.fr/~thocking/animint-book/Ch00-preface.html
# tutorials: http://tdhock.github.io/animint/

# going through some examples:
income <-read.csv('datasets/nzincome.csv', header = TRUE)
plot1 <- ggplot(income) + aes(x = sex, clickSelects = sex) + geom_bar()
plot2 <- ggplot(income) + aes(x = weekly_hrs, y = weekly_income, showSelected = sex) + geom_point()

animint2dir(list(p1 = plot1, p2 = plot2))
# this links the bar plots together with the scatterplot
## takes essentials from SQL queries
# conditioning is layer-specific

# going through the animint designer manual:

#simplistic subsetting:
plot3 <- ggplot(income) + aes(x = weekly_hrs, y = weekly_income, col = highest_qualification) + geom_point()
#change to render on a web page:
scatter.vis <- list(scatter = plot3)
structure(scatter.vis, class = "animint")

#multilayer: play with gapminder
gapminder08 <- read.csv('~/Desktop/datasets/gapminder-2008.csv', header = TRUE)
pl1 <- ggplot(gapminder08) + aes(x = Imports, y = Exports, color = Region) + geom_point()
pl2 <- pl1 + geom_text(aes(label = Country))
gg <- list(scatter = pl2)
structure(gg, class = "animint")

#linking two plots:
visTwo <- gg
visTwo$scatter2 <- ggplot(gapminder08) +
                  aes(x = Populationtotal,
                      y = Populationgrowth,
                      color = Region,
                      group = Country) + geom_point()
summary(visTwo)
structure(visTwo, class = "animint")

#facets?

## testing: could it do the box plot challenge?
# no - but would be possible manually? click + show idea
# ideally, would fail changing trend lines, simply because it's only
# focused on selection + queries. (via direct manipulation)
