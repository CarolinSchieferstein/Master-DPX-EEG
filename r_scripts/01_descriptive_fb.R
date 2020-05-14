# --- carolin schieferstein & jose c. garcia alanis
# --- utf-8
# --- R 3.6.3
#
# --- fb analysis for DPX R40
# --- version: may 2020
#
# --- descriptives for fb

# ========================================================================

# Load necessary packages
require(plyr)
require(dplyr)
require(ggplot2)
#install.packages("ggmap")
require(ggmap)
#install.packages("viridis")
require(viridis)

###### Get the data #####
fb <- read.table('/run/media/carolin/2672-DC99/dpx_r40/data_fb/fb.txt', header = T)

# COMPUTE SCALE-SCORES
fb_skalen <- mutate(fb, BI = X17 + X18 + X33 + X40 + X44 + X15 + X12 ,
                        ZAP = X05 + X13 + X25 + X39 + X54 + X71 + X84 ,
                        BR = X03 + X09 + X04 + X19 + X30 + X31 + X32 + X38 + X45 + X47 ,
                        Imp = X29 + X35 + X36 + X48 + X53 + X57 + X68 + X70 ,
                        BAS = BI + ZAP + BR + Imp,
                        FFFS = X10 + X24 + X52 + X60 + X61 + X64 + X69 + X77 + X78 + X81 ,
                        BIS = X01 + X02 + X07 + X08 + X11 + X21 + X23 + X28 + X37 + X41 + X42 + X55 + X56 + X62 + X65 + X66 + X74 + X75 + X76 + X79 + X80 + X82 + X83 ,
                        Panik = X16 + X22 + X46 + X58 + X73 + X26 ,
                        DK = X50 + X06 + X14 + X20 + X51 + X27 + X34 + X43)

# ordnen
fb_skalen <- select(fb_skalen, ID:Beruf, BI:DK, X01:X84, Dauergesamt)

##### COMPUTE DESCRIPTIVE STATISTICS FOR QUESTIONNAIRE----

fb_scalemeans<- fb_skalen %>% dplyr::summarise(m_BI = mean(BI) ,
                                               m_ZAP = mean(ZAP) ,
                                               m_BR = mean(BR) ,
                                               m_Imp = mean(Imp) ,
                                               m_BAS = mean(BAS) ,
                                               m_FFFS = mean(FFFS) ,
                                               m_BIS = mean(BIS) ,
                                               m_Panik = mean(Panik) ,
                                               m_DK = mean(DK)
                                               )


fb_allmean<- fb_skalen %>% dplyr::summarise(m_age = mean(age) ,
                                            sd_age = sd(age) ,
                                            m_sex = mean(sex) ,
                                            sd_sex = sd(sex) ,
                                            m_dauer = mean(Dauergesamt) ,
                                            sd_dauer = sd(Dauergesamt) ,
                                            m_BI = mean(BI) ,
                                            sd_BI = sd(BI) ,
                                            m_ZAP = mean(ZAP) ,
                                            sd_ZAP = sd(ZAP) ,
                                            m_BR = mean(BR) ,
                                            sd_BR = sd(BR) ,
                                            m_Imp = mean(Imp) ,
                                            sd_Imp = sd(Imp) ,
                                            m_BAS = mean(BAS) ,
                                            sd_BAS = sd(BAS) ,
                                            m_FFFS = mean(FFFS) ,
                                            sd_FFFS = sd(FFFS) ,
                                            m_BIS = mean(BIS) ,
                                            sd_BIS = sd(BIS) ,
                                            m_Panik = mean(Panik) ,
                                            sd_Panik = sd(Panik) ,
                                            m_DK = mean(DK) ,
                                            sd_DK = sd(DK)
                                            )


fb_groupedmean<- fb_skalen %>% dplyr::group_by(group) %>%dplyr::summarise(m_age = mean(age) ,
                                                                          sd_age = sd(age) ,
                                                                          m_sex = mean(sex) ,
                                                                          sd_sex = sd(sex) ,
                                                                          m_dauer = mean(Dauergesamt) ,
                                                                          sd_dauer = sd(Dauergesamt) ,
                                                                          m_BI = mean(BI) ,
                                                                          sd_BI = sd(BI) ,
                                                                          m_ZAP = mean(ZAP) ,
                                                                          sd_ZAP = sd(ZAP) ,
                                                                          m_BR = mean(BR) ,
                                                                          sd_BR = sd(BR) ,
                                                                          m_Imp = mean(Imp) ,
                                                                          sd_Imp = sd(Imp) ,
                                                                          m_BAS = mean(BAS) ,
                                                                          sd_BAS = sd(BAS) ,
                                                                          m_FFFS = mean(FFFS) ,
                                                                          sd_FFFS = sd(FFFS) ,
                                                                          m_BIS = mean(BIS) ,
                                                                          sd_BIS = sd(BIS) ,
                                                                          m_Panik = mean(Panik) ,
                                                                          sd_Panik = sd(Panik) ,
                                                                          m_DK = mean(DK) ,
                                                                          sd_DK = sd(DK)
                                                                          )

# Spalten und Zeilen tauschen ->generalplot -> over all/ plot -> grouped <- ??wie nach group aufteilen statt group als Variable??
fb_generalplot <- tidyr::gather(fb_scalemeans)
fb_plot <- tidyr::gather(fb_groupedmean)
# fb_plot$key <- gsub(fb_plot$key,pattern = "m_", replacement = "")
# fb_plot$key <-  as.factor(fb_plot$key)
# print(levels(fb_plot$key))

# ## Reorder the levels:
# fb_plot$key <- factor(fb_plot$key,levels(fb_plot$key)[c(2,9,4,7,1,3,6,5,8)])
# print(levels(fb_plot$key))
# 
# #plot fb_scalemeans
# ggplot(fb_plot, aes(x = key, y = value, fill = key)) + 
#   geom_line(position = position_dodge(.5)) +
#   labs(y = "Skalenmittelwerte",
#        x = "RST-PQ Skalen",
#        title = "Mittelwerte der Skalen des RST-PQ") +
#   theme(strip.background = element_blank(), 
#         strip.text= element_text(color= "black", size = 12),
#         axis.text = element_text(color='black', size = 10),
#         axis.title = element_text(color='black', size = 13),
#         plot.title = element_text(hjust = .5),
#         legend.text = element_text(size = 12),
#         legend.title = element_blank()) + 
#   coord_cartesian(ylim = c(10:90)) +
#   scale_y_log10(breaks = seq(10,90,10)) +
#   geom_bar(position = position_dodge(.5), size = 3, stat = "identity") + 
#   scale_fill_viridis(option = "D", discrete = TRUE)
# 
# # Save for later use
# write.table(fb_plot, '/run/media/carolin/2672-DC99/dpx_r40/data_fb/fb_plot.txt', row.names = F, sep = '\t')
# 
# # Save as PDF
# # Open a pdf file
# pdf("/run/media/carolin/2672-DC99/dpx_r40/data_fb/m_fb.pdf", width = 10 , height = 10) 
# # 2. Create a plot (von oben eingefügt)
# ggplot(Fragebogen_plot, aes(x = key, y = value, fill = key)) + 
#   geom_line(position = position_dodge(.5)) +
#   labs(y = "Skalenmittelwerte",
#        x = "RST-PQ Skalen",
#        title = "Mittelwerte der Skalen des RST-PQ") +
#   theme(strip.background = element_blank(), 
#         strip.text= element_text(color= "black", size = 12),
#         axis.text = element_text(color='black', size = 10),
#         axis.title = element_text(color='black', size = 13),
#         plot.title = element_text(hjust = .5),
#         legend.text = element_text(size = 12),
#         legend.title = element_blank()) + 
#   coord_cartesian(ylim = c(10:90)) +
#   scale_y_log10(breaks = seq(10,90,10)) +
#   geom_bar(position = position_dodge(.5), size = 3, stat = "identity") + 
#   scale_fill_viridis(option = "D", discrete = TRUE)
# # Close the pdf file
# dev.off()
# 
# # nach Rew getrennt ######
# # ausgehend von Fragebogen_Skalen
# 
# Fragebogen_Skalen_rew0 <- filter(Fragebogen_Skalen, Rew == 0)
# Fragebogen_Skalen_rew1 <- filter(Fragebogen_Skalen, Rew == 1)
# 
# 
# Fragebogen_sum_scalemeans_rew0<- Fragebogen_Skalen_rew0 %>% dplyr::summarise(m_BI = mean(BI) ,
#                                                                              m_ZAP = mean(ZAP) ,
#                                                                              m_BR = mean(BR) ,
#                                                                              m_Imp = mean(Imp) ,
#                                                                              m_BAS = mean(BAS) ,
#                                                                              m_FFFS = mean(FFFS) ,
#                                                                              m_BIS = mean(BIS) ,
#                                                                              m_Panik = mean(Panik) ,
#                                                                              m_DK = mean(DK)
# )
# 
# Fragebogen_sum_scalemeans_rew1<- Fragebogen_Skalen_rew1 %>% dplyr::summarise(m_BI = mean(BI) ,
#                                                                              m_ZAP = mean(ZAP) ,
#                                                                              m_BR = mean(BR) ,
#                                                                              m_Imp = mean(Imp) ,
#                                                                              m_BAS = mean(BAS) ,
#                                                                              m_FFFS = mean(FFFS) ,
#                                                                              m_BIS = mean(BIS) ,
#                                                                              m_Panik = mean(Panik) ,
#                                                                              m_DK = mean(DK)
# )
# 
# ##### Plot #####
# # dafür Fragebogen_sum_scalemeans_rewX in Spalten statt Zeilen, dass eine Spalte jeweils BAS/BIS etc sagt und die zweite Spalte den Wert
# 
# Fragebogen_plot_rew0 <- tidyr::gather(Fragebogen_sum_scalemeans_rew0)
# Fragebogen_plot_rew0$key <- gsub(Fragebogen_plot_rew0$key,pattern = "m_", replacement = "")
# Fragebogen_plot_rew0$key <-  as.factor(Fragebogen_plot_rew0$key)
# 
# Fragebogen_plot_rew1 <- tidyr::gather(Fragebogen_sum_scalemeans_rew1)
# Fragebogen_plot_rew1$key <- gsub(Fragebogen_plot_rew1$key,pattern = "m_", replacement = "")
# Fragebogen_plot_rew1$key <-  as.factor(Fragebogen_plot_rew1$key)
# 
# 
# ## Reorder the levels:
# Fragebogen_plot_rew0$key <- factor(Fragebogen_plot_rew0$key,levels(Fragebogen_plot_rew0$key)[c(2,9,4,7,1,3,6,5,8)])
# print(levels(Fragebogen_plot_rew0$key))
# 
# Fragebogen_plot_rew1$key <- factor(Fragebogen_plot_rew1$key,levels(Fragebogen_plot_rew1$key)[c(2,9,4,7,1,3,6,5,8)])
# print(levels(Fragebogen_plot_rew1$key))
# 
# require(ggplot2)
# # install.packages("viridis")
# require(viridis)
# # Rew = 0
# ggplot(Fragebogen_plot_rew0, aes(x = key, y = value, fill = key)) + 
#   geom_line(position = position_dodge(.5)) +
#   labs(y = "Skalenmittelwerte",
#        x = "RST-PQ Skalen",
#        title = "Mittelwerte der Skalen des RST-PQ für die Gruppe mit verzögerter Belohnung") +
#   theme(strip.background = element_blank(), 
#         strip.text= element_text(color= "black", size = 12),
#         axis.text = element_text(color='black', size = 10),
#         axis.title = element_text(color='black', size = 13),
#         plot.title = element_text(hjust = .5),
#         legend.text = element_text(size = 12),
#         legend.title = element_blank()) + 
#   coord_cartesian(ylim = c(10:90)) +
#   scale_y_log10(breaks = seq(10,90,10)) +
#   geom_bar(position = position_dodge(.5), size = 3, stat = "identity") + 
#   scale_fill_viridis(option = "D", discrete = TRUE)
# 
# # Rew = 1
# ggplot(Fragebogen_plot_rew1, aes(x = key, y = value, fill = key)) + 
#   geom_line(position = position_dodge(.5)) +
#   labs(y = "Skalenmittelwerte",
#        x = "RST-PQ Skalen",
#        title = "Mittelwerte der Skalen des RST-PQ für die Gruppe mit direkter Belohnung") +
#   theme(strip.background = element_blank(), 
#         strip.text= element_text(color= "black", size = 12),
#         axis.text = element_text(color='black', size = 10),
#         axis.title = element_text(color='black', size = 13),
#         plot.title = element_text(hjust = .5),
#         legend.text = element_text(size = 12),
#         legend.title = element_blank()) + 
#   coord_cartesian(ylim = c(10:90)) +
#   scale_y_log10(breaks = seq(10,90,10)) +
#   geom_bar(position = position_dodge(.5), size = 3, stat = "identity") + 
#   scale_fill_viridis(option = "D", discrete = TRUE)
# 
# # Save for later use
# write.table(fb_plot_group, '/run/media/carolin/2672-DC99/dpx_r40/data_fb/fb_plot_group.txt', row.names = F, sep = '\t')
# 
# # Save as PDF
# # Open a pdf file
# pdf("/run/media/carolin/2672-DC99/dpx_r40/data_fb/m_fb_group.pdf", width = 10 , height = 10) 
# # 2. Create a plot
# ggplot(Fragebogen_plot_rew0, aes(x = key, y = value, fill = key)) + 
#   geom_line(position = position_dodge(.5)) +
#   labs(y = "Skalenmittelwerte",
#        x = "RST-PQ Skalen",
#        title = "Mittelwerte der Skalen des RST-PQ für die Gruppe mit verzögerter Belohnung") +
#   theme(strip.background = element_blank(), 
#         strip.text= element_text(color= "black", size = 12),
#         axis.text = element_text(color='black', size = 10),
#         axis.title = element_text(color='black', size = 13),
#         plot.title = element_text(hjust = .5),
#         legend.text = element_text(size = 12),
#         legend.title = element_blank()) + 
#   coord_cartesian(ylim = c(10:90)) +
#   scale_y_log10(breaks = seq(10,90,10)) +
#   geom_bar(position = position_dodge(.5), size = 3, stat = "identity") + 
#   scale_fill_viridis(option = "D", discrete = TRUE)
# # Close the pdf file
# dev.off()