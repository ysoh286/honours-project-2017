library(animint)

income <-read.csv('datasets/nzincome.csv', header = TRUE)
plot1 <- ggplot(income) + aes(x = sex, clickSelects = sex) + geom_bar()
plot2 <- ggplot(income) + aes(x = weekly_hrs, y = weekly_income, showSelected = sex) + geom_point()

animint2dir(list(p1 = plot1, p2 = plot2))
