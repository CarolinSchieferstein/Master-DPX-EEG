# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 4.0.1
#
# --- rt analysis for DPX R40
# --- version: july 2020
#
# --- questionnaire correlations

# ========================================================================
# ------------------- import relevant extensions -------------------------
# Load necessary packages
require(plyr)
require(dplyr)

# ----- 1) Get dataframes ---------------------
# Hits
RT_corr <- Correct_sum_ID %>% dplyr::select(ID, group, trialtype, reward, m_rt_hit)

RT_corr <- reshape2::dcast(RT_corr, ID + group ~ trialtype + reward, value.var="m_rt_hit")


# FR
FR_corr <- Incorrect_sum_ID %>% dplyr::select(ID, group, trialtype, reward, FR) %>%
  filter(trialtype == "AY")

FR_corr <- reshape2::dcast(FR_corr, ID + group ~ trialtype + reward, value.var="FR")


# FB
FB_corr <- select(fb, ID, BI:DK)

# ----- 2) Merge dataframes ---------------------
# Hits, reward 0 & 1
FB_RT_corr <- merge(FB_corr, RT_corr, "ID")
names(FB_RT_corr)[12:19] <- c("AX 0", "AX 1",
                              "AY 0", "AY 1",
                              "BX 0", "BX 1",
                              "BY 0", "BY 1")


# FR, reward 0 & 1
FB_FR_corr <- merge(FB_corr, FR_corr, "ID")
names(FB_FR_corr)[12:13] <- c("AY 0", "AY 1")



# ----- 3) Compute correlations ---------------------
# Hits, reward 0 & 1
require(psych)
FB_RT_corr_plot <- corr.test(FB_RT_corr[, -c(1,11)], adjust = 'none')
diag(FB_RT_corr_plot$r) = NA
diag(FB_RT_corr_plot$p) = NA


# Plot
require(corrplot)
require(RColorBrewer)
corrplot(FB_RT_corr_plot$r, p.mat = FB_RT_corr_plot$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)


# FR, reward 0 & 1
require(psych)
FB_FR_corr_plot <- corr.test(FB_FR_corr[, -c(1,11)], adjust = 'fdr')
diag(FB_FR_corr_plot$r) = NA
diag(FB_FR_corr_plot$p) = NA

# Plot
require(corrplot)
require(RColorBrewer)
corrplot(FB_FR_corr_plot$r, p.mat = FB_FR_corr_plot$p, 
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1, 
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)

# ----- 4) Compute correlations divided by group 0/1 ---------------------
# Hits, reward 0 & 1
require(psych)
FB_RT_corr0 <- filter(FB_RT_corr, group == "0")
names(FB_RT_corr0)[12:19] <- c("AX 0", "AX 1",
                              "AY 0", "AY 1",
                              "BX 0", "BX 1",
                              "BY 0", "BY 1")

FB_RT_corr_plot0 <- corr.test(FB_RT_corr0[, -c(1,11)], adjust = 'none')
diag(FB_RT_corr_plot0$r) = NA
diag(FB_RT_corr_plot0$p) = NA

FB_RT_corr1 <- filter(FB_RT_corr, group == "1")
names(FB_RT_corr1)[12:19] <- c("AX 0", "AX 1",
                              "AY 0", "AY 1",
                              "BX 0", "BX 1",
                              "BY 0", "BY 1")

FB_RT_corr_plot1 <- corr.test(FB_RT_corr1[, -c(1,11)], adjust = 'none')
diag(FB_RT_corr_plot1$r) = NA
diag(FB_RT_corr_plot1$p) = NA


# Plot
require(corrplot)
require(RColorBrewer)
corrplot(FB_RT_corr_plot0$r, p.mat = FB_RT_corr_plot0$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)

corrplot(FB_RT_corr_plot1$r, p.mat = FB_RT_corr_plot1$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)

# FR, reward 0 & 1
require(psych)
FB_FR_corr0 <- filter(FB_FR_corr, group == "0")
names(FB_FR_corr0)[12:13] <- c("AY 0", "AY 1")

FB_FR_corr_plot0 <- corr.test(FB_FR_corr0[, -c(1,11)], adjust = 'none')
diag(FB_FR_corr_plot0$r) = NA
diag(FB_FR_corr_plot0$p) = NA

FB_FR_corr1 <- filter(FB_FR_corr, group == "1")
names(FB_FR_corr1)[12:13] <- c("AY 0", "AY 1")

FB_FR_corr_plot1 <- corr.test(FB_FR_corr1[, -c(1,11)], adjust = 'none')
diag(FB_FR_corr_plot1$r) = NA
diag(FB_FR_corr_plot1$p) = NA


# Plot
require(corrplot)
require(RColorBrewer)
corrplot(FB_FR_corr_plot0$r, p.mat = FB_FR_corr_plot0$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)

corrplot(FB_FR_corr_plot1$r, p.mat = FB_FR_corr_plot1$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)


# ----- 5) Compute correlations with PBI ---------------------
# dataframe PBI
pbi_rt_corr <- pbi_rt
pbi_fr_corr <- pbi_fr

pbi_rt_corr <- reshape2::dcast(pbi_rt_corr, ID + group ~ reward, value.var="pbi_rt")
pbi_fr_corr <- reshape2::dcast(pbi_fr_corr, ID + group ~ reward, value.var="pbi_fr")


# FB
FB_corr <- select(fb, ID, BI:DK)

# merge
FB_PBI_rt_corr <- merge(FB_corr, pbi_rt_corr, "ID")
names(FB_PBI_rt_corr)[12:13] <- c("PBI 0", "PBI 1")

FB_PBI_fr_corr <- merge(FB_corr, pbi_fr_corr, "ID")
names(FB_PBI_fr_corr)[12:13] <- c("PBI 0", "PBI 1")


## Reaktionszeiten
require(psych)
FB_PBI_rt_corr0 <- filter(FB_PBI_rt_corr, group == "0")
FB_PBI_rt_corr1 <- filter(FB_PBI_rt_corr, group == "1")

FB_PBI_rt_corr0_plot <- corr.test(FB_PBI_rt_corr0[, -c(1,11)], adjust = 'none')
diag(FB_PBI_rt_corr0_plot$r) = NA
diag(FB_PBI_rt_corr0_plot$p) = NA


FB_PBI_rt_corr1_plot <- corr.test(FB_PBI_rt_corr1[, -c(1,11)], adjust = 'none')
diag(FB_PBI_rt_corr1_plot$r) = NA
diag(FB_PBI_rt_corr1_plot$p) = NA


# Plot
require(corrplot)
require(RColorBrewer)
corrplot(FB_PBI_rt_corr0_plot$r, p.mat = FB_PBI_rt_corr0_plot$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)

corrplot(FB_PBI_rt_corr1_plot$r, p.mat = FB_PBI_rt_corr1_plot$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)

## Fehlerraten
require(psych)
FB_PBI_fr_corr0 <- filter(FB_PBI_fr_corr, group == "0")
FB_PBI_fr_corr1 <- filter(FB_PBI_fr_corr, group == "1")

FB_PBI_fr_corr0_plot <- corr.test(FB_PBI_fr_corr0[, -c(1,11)], adjust = 'none')
diag(FB_PBI_fr_corr0_plot$r) = NA
diag(FB_PBI_fr_corr0_plot$p) = NA

FB_PBI_fr_corr1_plot <- corr.test(FB_PBI_fr_corr1[, -c(1,11)], adjust = 'none')
diag(FB_PBI_fr_corr1_plot$r) = NA
diag(FB_PBI_fr_corr1_plot$p) = NA


# Plot
require(corrplot)
require(RColorBrewer)
corrplot(FB_PBI_fr_corr0_plot$r, p.mat = FB_PBI_fr_corr0_plot$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)

corrplot(FB_PBI_fr_corr1_plot$r, p.mat = FB_PBI_fr_corr1_plot$p,
         col = rev(colorRampPalette(brewer.pal(11,'RdBu'))(20)),
         method = "circle", 
         number.cex = 1,
         #order = "hclust",
         addrect = 3,
         type = 'upper',
         #addCoef.col = "black", 
         #sig.level = 0.05, 
         tl.col = "black", 
         tl.srt = 90,
         mar = c(1, 0, 2, 1),
         addgrid.col =  NA,
         insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.5, 
         pch.col = "white", 
         na.label.col = NA, 
         na.label = NA, 
         cl.ratio = .25, cl.length = 11, cl.cex = 1)
