library(shiny)
library(gridlayout)
library(ggplot2)
library(data.table)


# Load the combined screening and household dataset
# Replace hardcoded path with your respective path.
scn_DT <- fread("C:/Users/teemo/projects/shiny-pearl/output/scn_betio.csv")

# Reduce the columns. Keep only the columns that are used by the app.
reduce_cols <- c(
  "record_id_scn", "record_id_hh", "en_sex", "en_cal_age",
  "ea_number", "dwelling_fixed", "hh_name", "hh_ea", "hh_screened",
  "hh_longitude", "hh_latitude", "hh_size", "hh_status", "tst_read_positive", "tb_decision"
)
scn_DT <- scn_DT[, ..reduce_cols]


# This is the User Interface for the application
ui <- navbarPage(
  title = "PEARL screening ",
  selected = "Page 1",
  collapsible = TRUE,
  theme = bslib::bs_theme(bootswatch = "darkly"),
  tabPanel(
    title = "Page 1",
    grid_container(
      layout = "Enumeration_Area linePlots",
      row_sizes = "1fr",
      col_sizes = c(
        "250px",
        "1fr"
      ),
      gap_size = "10px",
      grid_card(
        area = "Enumeration_Area",
        selectInput(
          inputId = "p1_select_ea",
          label = "Select Enumeration Area",
          choices = list(
            `71609000` = "71609000",
            `71610020` = "71610020",
            `71610110` = "71610110",
            MISSING = "MISSING",
            `71609732 REMIA` = "71609732 REMIA",
            `71609731 BIG EYE` = "71609731 BIG EYE",
            `71609810 ROADSIDE` = "71609810 ROADSIDE",
            `71609820 SANTO BETERO` = "71609820 SANTO BETERO",
            `71610010 NW CORNER` = "71610010 NW CORNER"
          )
        ),
        sliderInput(
          inputId = "calc_age",
          label = "Select calculated age range (less than or equal)",
          min = 1L,
          max = 100L,
          value = 100L,
          step = 1L,
          width = "100%"
        )
      ),
      grid_card_plot(area = "linePlots")
    )
  ),
  tabPanel(
    title = "Page 2",
    grid_container(
      layout = c(
        "facetOption",
        "dists      "
      ),
      row_sizes = c(
        "180px",
        "1fr"
      ),
      col_sizes = "1fr",
      gap_size = "10px",
      grid_card_plot(area = "dists"),
      grid_card(
        area = "facetOption",
        title = "Distribution Plot Options",
        radioButtons(
          inputId = "distFacet",
          label = "Facet distribution by",
          choices = list(
            Gender = "en_sex",
            `Enumeration area` = "hh_ea",
            `TST results` = "tst_read_positive",
            `TB decision` = "tb_decision"
          )
        )
      )
    )
  ),
  tabPanel(
    title = "Page 3",
    grid_container(
      layout = c(
        "P3_area1 area22323 . .",
        ".        P3_12     . ."
      ),
      row_sizes = c(
        "0.5fr",
        "1.5fr"
      ),
      col_sizes = c(
        "0.75fr",
        "1.95fr",
        "0.3fr",
        "1fr"
      ),
      gap_size = "10px",
      grid_card(
        area = "P3_12",
        plotOutput(
          outputId = "plot",
          width = "100%",
          height = "400px"
        )
      ),
      grid_card(
        area = "P3_area1",
        numericInput(
          inputId = "myNumericInput",
          label = "Numeric Input",
          value = 5L
        )
      ),
      grid_card(
        area = "area22323",
        checkboxGroupInput(
          inputId = "myCheckboxGroup",
          label = "Checkbox Group",
          choices = list(
            `choice a` = "a",
            `choice b` = "b"
          )
        )
      )
    )
  )
)

# This is the Server for the application
server <- function(input, output) {
  output$linePlots <- renderPlot({
    if (input$p1_select_ea == "MISSING") {
      input$p1_select_ea <- ""
    }
    survey <- scn_DT[(ea_number == input$p1_select_ea) & (en_cal_age <= input$calc_age)]

    main_plot <- ggplot(
      survey,
      aes(
        x = hh_longitude,
        y = hh_latitude,
        colour = hh_status,
        size = hh_size
      )
    ) +
      scale_size(range = c(1, 15)) +
      geom_point(alpha = .2, shape = 16) +
      ggtitle("Household by Lat. Long.")

    main_plot +

      geom_text(label = survey$dwelling_fixed, size = 4, color = "black", hjust = -.5)
  })

  output$dists <- renderPlot({
    survey <- scn_DT

    ggplot(
      survey,
      aes(x = en_cal_age)
    ) +
      facet_wrap(input$distFacet) +
      geom_density(fill = "#fa551b", color = "#ee6331") +
      ggtitle("Distribution of ages by facet option")
  })
}

shinyApp(ui, server)
