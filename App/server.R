server <- function(input, output, session) {
  
  filtered <- reactive({
    bike %>%
      filter(arr_date == input$dateI,
             arr_hour >= input$hourI[1],
             arr_hour <= input$hourI[2],
             gender == input$genderI)%>%
      group_by(to_station_name,longitude,latitude,gender)%>%
      summarise(total = sum(total_trips))%>%
      arrange(desc(total))
      
    })
  
  
  output$mymap <- renderLeaflet({
    leaflet()%>%
      addTiles() %>%
      setView(lng=-87.6244, lat=41.8756,zoom = 12) %>%
      addLegend(
        position='bottomright',
        colors= c("darkblue", "#3399FF", "#ea00ea", "#ff83ff"),
        labels= c("<=5","<=25","<=50",">50"),
        opacity = 0.75,
        title="Legend")
        })
  

  observe({
    
    data <- filtered()
    
    getColor <- function(data) {
      sapply(filtered()$total, function(total) {
        if(total <= 5) {
          "darkblue"
        } else if(total <= 25) {
          "blue"
        } else if(total <= 50){
          "purple"
        } else {
          "pink" 
        } })
    }
    
    icons <- awesomeIcons(
      icon = 'bicycle',
      library = "fa",
      iconColor = "#FFFFFF",
      markerColor = getColor(proxy)
    )
    
    proxy <- leafletProxy("mymap",data = filtered())
    
    proxy%>%
      addAwesomeMarkers(data = filtered(),
                        lng = ~longitude,
                        lat = ~latitude,
                        icon = icons,
                        label = paste("Station: ",filtered()$to_station_name,
                                      "Total trips: ",
                                      filtered()$total),labelOptions = labelOptions(noHide = F)) 
    })

  
  output$results <- renderDataTable({
    filtered() 
  })
  
  
}
