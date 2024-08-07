# Waste bricks for tree substrates
# Show Figure A3 F ####
# Markus Bauer
# 2022-03-15



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# A Preparation #############################################################
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


### Packages ###
library(here)
library(tidyverse)
library(ggbeeswarm)
library(lme4)
library(emmeans)
library(ggeffects)

### Start ###
rm(list = c("data", "meandata", "pd", "pdata", "m4"))
setwd(here("data", "processed"))

### Load data ###
(data <- read_csv2("data_processed_acid.csv",
                   col_names = TRUE, na = "na", col_types =
                     cols(
                       .default = col_double(),
                       plot = col_factor(),
                       block = col_factor(),
                       replanted = col_factor(),
                       species = col_factor(),
                       mycorrhiza = col_factor(),
                       substrate = col_factor(),
                       soilType = col_factor(levels = c("poor", "rich")),
                       brickRatio = col_factor(levels = c("5", "30")),
                       acid = col_factor(levels = c("Control", "Acid")),
                       acidbrickRatioTreat =
                         col_factor(
                           levels = c("Control_30", "Acid_5", "Acid_30")
                           )
                     )
                   ) %>%
    select(rmf, plot, block, species, acidbrickRatioTreat, soilType,
           conf.low, conf.high)
  )
data$acidbrickRatioTreat <- dplyr::recode(data$acidbrickRatioTreat,
                                          "Control_30" = "Control 30% bricks",
                                          "Acid_5" = "Acid 5% bricks",
                                          "Acid_30" = "Acid 30% bricks")

#### Chosen model ###
m4 <- lm(rmf ~ species + soilType + acidbrickRatioTreat +
           acidbrickRatioTreat:species + acidbrickRatioTreat:soilType, data)



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# B Plot #####################################################################
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


themeMB <- function() {
  theme(
    panel.background = element_rect(fill = "white"),
    text  = element_text(size = 8, color = "black"),
    axis.line.y = element_line(),
    axis.line.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(angle = 90, hjust = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.position = "right",
    legend.margin = margin(0, 0, 0, 0, "cm"),
    plot.margin = margin(0, 0, 0, 0, "cm")
  )
}

### interaction: acid x brickRatio x species ###
pdata <- ggemmeans(m4, terms = c("acidbrickRatioTreat", "species"),
                   type = "fe")
pdata <- rename(pdata, rmf = predicted, acidbrickRatioTreat = x,
                species = group)
meandata <- filter(pdata, acidbrickRatioTreat == "Control 30% bricks")
pd <- position_dodge(.6)

### plot ###
(rmf <- ggplot(pdata,
               aes(acidbrickRatioTreat, rmf, shape = acidbrickRatioTreat,
                   ymin = conf.low, ymax = conf.high)) +
   geom_quasirandom(data = data, aes(acidbrickRatioTreat, rmf),
                     color = "grey70", dodge.width = .6, size = 0.7) +
    geom_hline(aes(yintercept = rmf), meandata,
               color = "grey70", size = .25) +
    geom_hline(aes(yintercept = conf.low), meandata,
               color = "grey70", linetype = "dashed", size = .25) +
    geom_hline(aes(yintercept = conf.high), meandata,
               color = "grey70", linetype = "dashed", size = .25) +
    geom_errorbar(position = pd, width = 0.0, size = 0.4) +
    geom_point(position = pd, size = 2.5) +
    facet_grid(~ species) +
    annotate("text", label = "n.s.", x = 3.2, y = 0.7) +
    scale_y_continuous(limits = c(0.35, 0.7), breaks = seq(-100, 100, 0.1)) +
    scale_shape_manual(values = c(1, 16, 15)) +
    labs(x = "",
         y = expression(Root~mass~fraction~"["*g~g^-1*"]"),
         shape = "Brick ratio [%]", color = "") +
    themeMB() +
    theme(strip.text = element_blank(),
          strip.background = element_blank(),
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          legend.position = "none")
  )
