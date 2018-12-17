


ui <- fluidPage(
  navbarPage(title = strong("Grab a Bike"),
             collapsible = TRUE,
             windowTitle = 'Grab a Bike',
             tabPanel("About",
                        fluidPage(
                          mainPanel(includeMarkdown("./Doc/about.md"))
                        )),
             
             tabPanel("App",
                      sidebarLayout(
                        mainPanel(leafletOutput("mymap","100%",600),br(),br(),dataTableOutput("results")),
                        sidebarPanel(
                          dateInput("dateI",
                                    label="Select date of trip",
                                    format = "yyyy-mm-dd",
                                    value = "2017-10-25",
                                    min = "2017-01-01",
                                    max = "2017-12-31"),
                          sliderInput("hourI",label = "Select time frame",0,23,c(10,16)),
                          radioButtons("genderI",label = "Select gender",choices = c("Male","Female"),selected = "Male")
                        )
                      )
             )
  )
)

  
                      
                      



