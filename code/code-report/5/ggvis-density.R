library(ggvis)

# load census data:
census <- read.csv("http://new.censusatschool.org.nz/wp-content/uploads/2016/08/CaS2009_subset.csv",
                   header = TRUE)

# remove missing values
census[is.na(census[, 7]) == 0, ] %>%
ggvis(x = ~height) %>%
layer_densities(adjust = input_slider(0.1, 1, value = 0.1, step = 0.05))
