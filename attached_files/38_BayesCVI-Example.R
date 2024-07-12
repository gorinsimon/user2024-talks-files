library(BayesCVI)


#install a package for computing an underlying CVI
install.packages("UniversalCVI")
install.packages("BayesCVI")

library(UniversalCVI)
library(BayesCVI)

data = R1_data[,-3]

plot(data)

# Compute WP index by WP.IDX using default gamma
FCM.WP = WP.IDX(scale(data), cmax = 10, cmin = 2, corr = 'pearson', method = 'FCM', fzm = 2,
                iter = 100, nstart = 20, NCstart = TRUE)


# WP.IDX values
result = FCM.WP$WP$WPI


aalpha = c(20,20,20,5,5,5,0.5,0.5,0.5)
B.WP = BayesCVIs(CVI = result,
                 n = nrow(data),
                 kmax = 10,
                 opt.pt = "max",
                 alpha = aalpha,
                 mult.alpha = 1/2)

# plot the BCVI

pplot = plot_BCVI(B.WP)
pplot$plot_index
pplot$plot_BCVI
pplot$error_bar_plot


#_____________________________________


# The data included in this package.
data = B7_data[,1:2]
plot(data)

# alpha
aalpha = c(20,20,20,5,5,5,0.5,0.5,0.5)

B.WP = B_WP.IDX(x = scale(data), kmax =10, corr = "pearson", method = "FCM",
                fzm = 2, sampling = 1, iter = 100, nstart = 20, NCstart = TRUE,
                alpha = aalpha, mult.alpha = 1/2)

# plot the BCVI

pplot = plot_BCVI(B.WP)
pplot$plot_index
pplot$plot_BCVI
pplot$error_bar_plot
