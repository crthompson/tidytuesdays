# Avatar
library(tidyverse)
library(tvthemes)
library(tidytuesdayR)
library(ggforce)
library(extrafont)
loadfonts()
library(ggforce)
library(ggtext)
library(cowplot)


# Get the data ####
# tt_data <- tt_load(2020, 33)
# readme(tt_data)

# Get the data ready for plotting ####
avatar <- tt_data$avatar %>%
  mutate(character_word_count = sapply(strsplit(character_words, " "), length)) %>%
  group_by(book, chapter) %>%
  summarise(total_chat = sum(character_word_count), 
            chapter = unique(chapter),
            chapter_num = unique(chapter_num), 
            imdb = unique(imdb_rating))

# Plot it! ####

sweetspot <- ggplot(avatar, 
                    aes(x = total_chat, y = imdb)) +
  geom_smooth(colour = "white", alpha = .6) +
  geom_point(aes(colour = book), alpha = .8, size = 3) +
  theme_avatar(title.font = "Slayer",
               text.font = "Slayer",
               title.size = 10) +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_colour_manual(name = "",
                      # using avatar_pal with 4 colours
                      values = c("#015E05", "#FF4500", "#1DB4D3"),
                      labels = c("Earth", "Fire", "Water"),
                      guide = F) +
  labs(title = "Across the three books, IMDB ratings 
drop when the characters say between 
2000 and 2200 words.",
       x = "Total number of words spoken by characters",
       y = "IMDB rating")

## Create function to make 3 plots with different colour scales
plotBook <- function(df = avatar, bookName, loCol, hiCol) {
  df %>% 
    filter(book == bookName) %>%
    # to make ordering on plot more intuitive
    arrange(-chapter_num) %>%
    mutate(id = row_number()) %>%
    ggplot(aes(x = id, y = total_chat, fill = imdb)) +
    geom_bar(stat = "identity") + 
    theme_avatar(title.font = "Slayer",
                 text.font = "Slayer",
                 title.size = 14) +
    ylim(c(0, 2900)) +
    xlim(c(-10, 25)) +
    coord_polar(theta = "y", start = 4.71, clip = "off") +
    labs(title = bookName,
         x = "",
         y = "") +
    # getting pseudo x axis text
    geom_richtext(aes(y = 0, label = chapter_num),
                  size = 0.8,
                  family = "Slayer",
                  fill = NA,
                  label.color = NA,
                  angle = 90,
                  vjust = .5,
                  hjust = 1) +
    scale_fill_continuous(high = hiCol,
                          low = loCol,
                          name = "IMDB Rating",
                          guide = guide_colourbar(
                            direction = "horizontal",
                            title.position = "top")) +
    theme(plot.margin = unit(c(0, 0, 0, 0), "cm"),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          plot.title = element_text(hjust = 0.5, size = 10),
          panel.grid.major = element_line(color = "#ece5d3"), 
          panel.grid.minor = element_line(color = "#ece5d3"),
          legend.position = c(0.2, 0.1),
          legend.text = element_text(size = "6"),
          legend.title = element_text(size = "8"),
          legend.title.align = 0.5,
          legend.background = element_rect(color = "#ece5d3"))
}

# Manually defined high nd low because gradient in 
# tvthemes default changed dark/light direction between plots
firePlot <- plotBook(bookName = "Fire", loCol = "#ecb100", hiCol = "#a10000")
waterPlot <- plotBook(bookName = "Water", loCol = "#1DB4D3", hiCol = "#120976")
earthPlot <- plotBook(bookName = "Earth", loCol = "#C7C45E", hiCol = "#015E05")

avatar_pic <- file.path("../making-of/temp", "avatar.png")

pic <- ggdraw() + 
  draw_image(avatar_pic, scale = 1) +
  theme_avatar()

## Assemble 4 plots plus image
toprow <- plot_grid(sweetspot, pic, nrow = 1, rel_widths = c(0.6, 0.4))
bottomrow <- plot_grid(firePlot, earthPlot, waterPlot, nrow = 1)
title <- ggdraw() +
  draw_label("Avatar: The Last Airbender",
             fontfamily = "Slayer",
             hjust = 0.5,
             size = 24) +
  theme_avatar()
subtitle <- ggdraw() +
  draw_label("The anti sweet spot of chattiness",
             fontfamily = "Slayer",
             hjust = 0.5,
             size = 16) +
  theme_avatar()
subtitle2 <- ggdraw() +
  draw_label("Total words spoken by book and by chapter",
             fontfamily = "Slayer",
             hjust = 0.5,
             size = 16) +
  theme_avatar()

plot_grid(title,
          subtitle,
          toprow,
          subtitle2,
          bottomrow,
          ncol = 1,
          rel_heights = c(0.1, 0.05, 0.45, 0.1, 0.3))


# Export to create making-of gif 
ggsave(filename = file.path("../making-of/temp", paste0("202008-avatar", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")), 
       dpi = 400, width = 9.355, height = 12)

# Export final plot
ggsave(filename = "../plots/202008_avatar.png", dpi = 400, width = 10, height = 10, type = cairo)
