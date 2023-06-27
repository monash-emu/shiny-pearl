# Check and install missing packages.
list.of.packages <- c("tidyverse", "ggplot2", "shiny", "data.table", "remotes")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if (length(new.packages)) install.packages(new.packages)

# Explicitly install shinyuieditor using the remotes package
if (!("shinyuieditor" %in% installed.packages())) {
    remotes::install_github("rstudio/shinyuieditor")
}



library(shiny)
library(data.table)

top_level_path <- getwd()

# To run the main shiny application
runApp("shiny-pearl")

# Or uncomment this if you want to run the shiny ui editor
# shinyuieditor::launch_editor(app_loc = "shiny-pearl")
