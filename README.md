# shiny-pearl

This repository implements a shiny dashboard for the University of Sydney. It brings together the Household Enumeration & PEARL TB screening data for Betio.

Installation steps:

1. Data preprocessing
Run the *[\python\pre_process.py](.\python\pre_process.py)* file or
*[\R\preprocess.r](.\R\preprocess.r)* (work in progress)
This preprocessing will create a file in *[\output\scn_betio.csv](\output\scn_betio.csv)*. 

2. Run the R script file *[shiny-pearl.R](shiny-pearl.R)*
The script file will verify and install the required R packages on the first run. Following this, the Shiny app should launch as a new browser tab.

3. The file *[shiny-pearl\app.r](shiny-pearl\app.r)* contains instructions on how to extend the dashboard pages.