library(aqp)
organic_carbon_pct <- 0.6

thickness_cm <- c(10, 18:50)
bulk_density_gcm3 <- seq(0.6, 1.8, 0.1)
highlight_depths <- c(10, 18, 25, 50)

bulk_density_kgm3 <- bulk_density_gcm3 * 1000 #  kg/m^3
thickness_m <- thickness_cm / 100
organic_carbon_fraction <- organic_carbon_pct / 100

# calculate carbon stock (kg/m^2) by outer product
m <- outer(thickness_m, bulk_density_kgm3, "*") * organic_carbon_fraction

plot(bulk_density_gcm3, type = "n", 
     ylab = "Minimum Epipedon Carbon Stock (kg/m^2)",
     xlab = "Epipedon Bulk Density (g/cm^3)",
     main = "Effect of Bulk Density on Minimum Organic Carbon Stock\nin Epipedons of Varying Thickness",
     sub  = sprintf("Assuming Minimum %s%% Organic Carbon. Multiply Carbon Stock by 10 for t/ha", organic_carbon_pct),
     xlim = c(min(bulk_density_gcm3) - 0.1, 
              max(bulk_density_gcm3)), 
     ylim = c(0, 5))
apply(m, 1, \(y) lines(y ~ bulk_density_gcm3))
apply(m[which(thickness_cm %in% highlight_depths),], 
      1, \(y) lines(y ~ bulk_density_gcm3, lwd = 2, col = "BLUE"))
sapply(highlight_depths, \(d)
       text(x = min(bulk_density_gcm3) - 0.05,
            y = min(m[which(thickness_cm == d),]),
            paste0(d, " cm"), cex = 0.8))
abline(h = 1, lty = 2)
abline(v = 0.9, lty = 2)
text(x = 0.7, y = 4.5, "Here be the ando-like\nsoils (Andisols)")
text(x = 1.1, y = 4.5, "Other Mineral Soils")
