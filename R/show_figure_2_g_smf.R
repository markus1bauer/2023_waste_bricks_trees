# Waste bricks for tree substrates
# Show Figure 2G ####
# Markus Bauer
# 2022-03-15



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# A Preparation ##############################################################
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


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
data <- read_csv("data_processed_brickRatio.csv",
                  col_names = TRUE, na = "na", col_types =
                        cols(
                          .default = col_double(),
                          plot = col_factor(),
                          block = col_factor(),
                          replanted = col_factor(),
                          species = col_factor(),
                          mycorrhiza =
                            col_factor(levels = c("Control", "Mycorrhiza")),
                          substrate = col_factor(),
                          soilType = col_factor(levels = c("poor", "rich")),
                          brickRatio = col_factor(levels = c("5", "30")),
                          acid = col_factor(),
                          acidbrickRatioTreat = col_factor()
                        )
                  ) %>%
  select(smf, plot, block, species, brickRatio, soilType, mycorrhiza,
         conf.low, conf.high)

#### Chosen model ###
m4 <- lmer(smf ~ (species + brickRatio + soilType + mycorrhiza)^2 +
             species:brickRatio:soilType + species:brickRatio:mycorrhiza +
             (1 | block), data, REML = FALSE)



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

### brickRatio:soilType ###
pdata <- ggemmeans(m4, terms = c("soilType", "brickRatio", "species"),
                   type = "fe")
pdata <- pdata %>%
  rename(smf = predicted, soilType = x, brickRatio = group, species = facet)
meandata <- filter(pdata, soilType == "poor" & brickRatio == "5")
pd <- position_dodge(.6)

### plot ###
(smf <- ggplot(pdata, aes(soilType, smf, shape = brickRatio,
                          ymin = conf.low, ymax = conf.high)) +
  geom_quasirandom(data = data, aes(soilType, smf),
                   color = "grey70", dodge.width = .6, size = .7) +
  geom_hline(aes(yintercept = smf), meandata,
             color = "grey70", size = .25) +
  geom_hline(aes(yintercept = conf.low), meandata,
             color = "grey70", linetype = "dashed", size = .25) +
  geom_hline(aes(yintercept = conf.high), meandata,
             color = "grey70", linetype = "dashed", size = .25) +
  geom_errorbar(position = pd, width = .0, size = .4) +
  geom_point(position = pd, size = 2.5) +
  facet_grid(~ species) +
  annotate("text", label = "n.s.", x = 2.2, y = 0.5) +
  scale_y_continuous(limits = c(0.15, 0.5), breaks = seq(-100, 100, 0.1)) +
  scale_shape_manual(values = c(1, 16)) +
  labs(x = "Soil fertility",
       y = expression(Stem~mass~fraction~"[" * g~g^-1 * "]"),
       shape = "Brick ratio [%]", color = "") +
  themeMB() +
  theme(strip.text = element_blank(),
        strip.background = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        legend.position = "none")
)

ggsave("figure_2_g_smf_800dpi_12x7cm.tiff",
       dpi = 800, width = 12, height = 7, units = "cm",
       path = here("outputs", "figures"))
